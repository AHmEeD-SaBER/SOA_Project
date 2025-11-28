# Start All E-Commerce Microservices
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Starting All Flask Microservices" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$services = @(
    @{Name = "Order Service"; Port = 5001; Path = "order_service" },
    @{Name = "Inventory Service"; Port = 5002; Path = "inventory_service" },
    @{Name = "Pricing Service"; Port = 5003; Path = "pricing_service" },
    @{Name = "Customer Service"; Port = 5004; Path = "customer_service" },
    @{Name = "Notification Service"; Port = 5005; Path = "notification_service" }
)

$processIds = @()

foreach ($service in $services) {
    Write-Host "Starting $($service.Name) on port $($service.Port)..." -ForegroundColor Green
    $proc = Start-Process pwsh -ArgumentList "-NoExit", "-Command", "cd $($service.Path); .\venv\Scripts\Activate.ps1; python app.py" -PassThru
    $processIds += $proc.Id
    Start-Sleep -Seconds 1
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "All services started!" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Waiting 5 seconds for services to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

Write-Host ""
Write-Host "Running connectivity test..." -ForegroundColor Yellow
python test_connectivity.py

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Stopping All Services..." -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan

# # Kill all Flask processes on ports 5001-5005
# foreach ($port in 5001..5005) {
#     $connections = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
#     foreach ($conn in $connections) {
#         $processId = $conn.OwningProcess
#         Write-Host "Stopping service on port $port (PID: $processId)..." -ForegroundColor Yellow
#         Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
#     }
# }

# # Also stop the PowerShell windows we opened
# foreach ($procId in $processIds) {
#     Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
# }

Write-Host ""
Write-Host "All services stopped!" -ForegroundColor Green
Write-Host "Virtual environments deactivated." -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
