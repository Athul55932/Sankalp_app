import sqlite3

def fetch_all_data():
    # Establish a connection to SQLite database
    conn = sqlite3.connect('certificates.db')
    cursor = conn.cursor()

    # Define SQL queries to fetch data from all tables
    queries = {
        "Applications": "select * from complaints "
    }

    # Loop through each table and fetch the data
    for table, query in queries.items():
        try:
            cursor.execute(query)
            rows = cursor.fetchall()

            print(f"\nData from {table} table:")
            for row in rows:
                print(row)
        except sqlite3.Error as e:
            print(f"Error fetching data from {table}: {e}")
    
    # Close the database connection
    conn.close()

if __name__ == "__main__":
    fetch_all_data()
