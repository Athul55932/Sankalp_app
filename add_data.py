import sqlite3

def insert_data_into_certificate_types(certificate_id, certificate_name):
    """
    Function to insert a new certificate type with certificate_id and certificate_name into the CertificateTypes table.
    """
    try:
        # Establish a connection to SQLite database
        conn = sqlite3.connect('certificates.db')
        cursor = conn.cursor()

        # Construct the SQL INSERT query
        insert_query = "INSERT INTO CertificateTypes (certificate_id, certificate_name) VALUES (?, ?);"
        
        # Execute the insert query with certificate_id and certificate_name
        cursor.execute(insert_query, (certificate_id, certificate_name))
        conn.commit()  # Commit the transaction
        
        # Check if the insertion was successful
        if cursor.lastrowid:
            print(f"Successfully inserted certificate type with ID {certificate_id}: {certificate_name}.")
        else:
            print("Failed to insert the certificate type.")
        
    except sqlite3.Error as e:
        print(f"Error inserting data into CertificateTypes: {e}")
    
    finally:
        # Close the database connection
        conn.close()

if __name__ == "__main__":
    # Example: Insert a certificate type with both ID and name
    certificate_id = 16  # You can manually specify the ID, but it's usually auto-incremented
    certificate_name = "Income_Certificate"
    insert_data_into_certificate_types(certificate_id, certificate_name)
