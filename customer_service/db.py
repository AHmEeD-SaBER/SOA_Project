import mysql.connector
from mysql.connector import Error
from config import DB_CONFIG


def get_db_connection():
    """
    Create and return a database connection.
    
    Note: This application uses raw MySQL connector instead of an ORM like SQLAlchemy.
    The database schema is created by running the database_setup.sql script directly
    against MySQL. No migrations (init/migrate/upgrade) are needed because:
    
    1. The schema is defined in database_setup.sql
    2. Run: mysql -u root -p < database_setup.sql
    3. This creates all tables and inserts sample data
    
    For schema changes, modify database_setup.sql and re-run it (drops and recreates).
    """
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except Error as e:
        print(f"Database connection error: {e}")
        return None
