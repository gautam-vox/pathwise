from datetime import datetime
import traceback
from flask import Flask, request, jsonify
import sqlite3
import os
import random

app = Flask(__name__)

# Database file name
DATABASE = 'user_data.db'

# Create SQLite database and table if it doesn't exist
def init_db():
    with sqlite3.connect(DATABASE) as conn:
        cursor = conn.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                full_name TEXT NOT NULL,
                username TEXT NOT NULL UNIQUE,
                password TEXT NOT NULL,
                email TEXT NOT NULL,
                purpose_of_visit TEXT NOT NULL,
                age_group TEXT NOT NULL,
                nature_poi TEXT,
                hotel_poi TEXT,
                food_poi TEXT,
                taxi_poi TEXT
            )
        ''')
        conn.commit()

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS taxi_bookings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT NOT NULL,
                start_point TEXT NOT NULL,
                destination_point TEXT NOT NULL,
                preferred_transport TEXT NOT NULL,
                date TEXT NOT NULL,
                charge TEXT NOT NULL,
                FOREIGN KEY (username) REFERENCES users (username)
            )
        ''')
        conn.commit()


        cursor.execute('''
            CREATE TABLE IF NOT EXISTS hotel_bookings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT NOT NULL,
                hotel_poi TEXT NOT NULL,
                checkin_date TEXT NOT NULL,
                checkout_date TEXT NOT NULL,
                number_of_people INTEGER NOT NULL,
                fare TEXT NOT NULL,  
                FOREIGN KEY (username) REFERENCES users (username)
            )
        ''')
        conn.commit()


init_db()


def get_db_connection():
    conn = sqlite3.connect('user_data.db')
    conn.row_factory = sqlite3.Row
    return conn


@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()  # Get the JSON data from the request
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'status': 'error', 'message': 'Username and password are required'}), 400

    # Connect to the database
    conn = get_db_connection()
    user = conn.execute('SELECT * FROM users WHERE username = ? AND password = ?', (username, password)).fetchone()
    conn.close()

    if user:
        # If user exists, return success response
        return jsonify({'status': 'success', 'message': 'Login successful'})
    else:
        # If user does not exist, return error response
        return jsonify({'status': 'error', 'message': 'Invalid username or password'}), 401
    

@app.route('/submit_signup', methods=['POST'])
def submit_signup():
    try:
        # Get JSON data from request
        data = request.json

        # Extract data fields (modify field names to match the frontend keys)
        full_name = data.get('full_name')  # Changed from 'fullName'
        username = data.get('username')
        password = data.get('password')
        email = data.get('email')
        purpose_of_visit = data.get('purpose_of_visit')  
        age_group = data.get('age_group')  
        nature_poi = data.get('poi_nature')  
        hotel_poi = data.get('poi_hotel')  
        food_poi = data.get('poi_food')  
        taxi_poi = data.get('poi_taxi')

        # Validate required fields
        if not all([full_name, username, password, email, purpose_of_visit, age_group]):
            return jsonify({'status': 'error', 'message': 'All fields are required'}), 400

        # Save data to database
        with sqlite3.connect(DATABASE) as conn:
            cursor = conn.cursor()
            cursor.execute('''
                INSERT INTO users (
                    full_name, username, password, email, purpose_of_visit,
                    age_group, nature_poi, hotel_poi, food_poi , taxi_poi
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (full_name, username, password, email, purpose_of_visit, age_group, nature_poi, hotel_poi, food_poi, taxi_poi))
            conn.commit()

        # Return success response
        return jsonify({'status': 'success', 'message': 'Signup successful'}), 200

    except sqlite3.IntegrityError:
        # Handle duplicate username
        return jsonify({'status': 'error', 'message': 'Username already exists'}), 400

    except Exception as e:
        # Handle unexpected errors
        return jsonify({'status': 'error', 'message': str(e)}), 500



@app.route('/get_profile', methods=['GET'])
def get_profile():
    try:
        username = request.args.get('username')  # Fetch username from query parameters

        if not username:
            return jsonify({'status': 'error', 'message': 'Username is required'}), 400

        conn = get_db_connection()
        user = conn.execute('SELECT * FROM users WHERE username = ?', (username,)).fetchone()
        conn.close()

        if user:
            print("#####",user['hotel_poi'])
            return jsonify({
                'status': 'success',
                'user': {
                    'full_name': user['full_name'],
                    'username': user['username'],
                    'email': user['email'],
                    'purpose_of_visit': user['purpose_of_visit'],
                    'age_group': user['age_group'],
                    'nature_poi': user['nature_poi'],
                    'hotel_poi': user['hotel_poi'],
                    'food_poi': user['food_poi'],
                    'taxi_poi': user['taxi_poi']
                }
            }), 200
        else:
            return jsonify({'status': 'error', 'message': 'User not found'}), 404

    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500


@app.route('/edit_profile', methods=['PUT'])
def edit_profile():
    try:
        data = request.json
        username = data.get('username')

        if not username:
            return jsonify({'status': 'error', 'message': 'Username is required'}), 400

        with sqlite3.connect(DATABASE) as conn:
            cursor = conn.cursor()
            cursor.execute('''
                UPDATE users
                SET full_name = ?, email = ?, purpose_of_visit = ?, age_group = ?,
                    nature_poi = ?, hotel_poi = ?, food_poi = ?, taxi_poi = ?, password = ?
                WHERE username = ?
            ''', (
                data.get('full_name'),
                data.get('email'),
                data.get('purpose_of_visit'),
                data.get('age_group'),
                data.get('nature_poi'),
                data.get('hotel_poi'),
                data.get('food_poi'),
                data.get('taxi_poi'),
                data.get('password'),  # Ensure hashing for passwords
                username,
            ))
            conn.commit()

        return jsonify({'status': 'success', 'message': 'Profile updated successfully'}), 200

    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500





# Function to fetch POI data from the database
def get_user_pois(username):
    with sqlite3.connect(DATABASE) as conn:
        cursor = conn.cursor()
        
        # Query to fetch POI preferences of the user
        cursor.execute("""
            SELECT nature_poi, hotel_poi, food_poi 
            FROM users 
            WHERE username = ?
        """, (username,))
        
        row = cursor.fetchone()
        print(row)
        
        # If user is found, return their POI preferences
        if row:
            return {
                'nature_poi': row[0],
                'hotel_poi': row[1],
                'food_poi': row[2],
            }
        else:
            return None

# API endpoint to get POIs for a specific user
@app.route('/get_pois/<username>', methods=['GET'])
def get_pois(username):
    pois = get_user_pois(username)
    if pois:
        return jsonify(pois), 200  # Success response
    else:
        return jsonify({'message': 'User not found'}), 404  # Error response if user not found




@app.route('/save_taxi_booking', methods=['POST'])
def save_taxi_booking():
    try:
        data = request.json

        username = data.get('username')
        start_point = data.get('start_point')
        destination_point = data.get('destination_point')
        preferred_transport = data.get('preferred_transport')
        date = data.get('date')

        # Check if all required fields are provided
        if not all([username, start_point, destination_point, preferred_transport, date]):
            return jsonify({'status': 'error', 'message': 'All fields are required'}), 400

        # Determine the charge based on preferred_transport
        if preferred_transport.lower() == "car":
            charge = random.uniform(500, 1000)  # Random float between 500 and 1000
        elif preferred_transport.lower() == "bus transport":
            charge = random.uniform(30, 300)  # Random float between 30 and 300
        else:
            return jsonify({'status': 'error', 'message': 'Invalid transport type'}), 400

        # Save booking to the database
        conn = get_db_connection()
        conn.execute(
            'INSERT INTO taxi_bookings (username, start_point, destination_point, preferred_transport, date, charge) VALUES (?, ?, ?, ?, ?, ?)',
            (username, start_point, destination_point, preferred_transport, date, charge)
        )
        conn.commit()
        conn.close()

        return jsonify({'status': 'success', 'message': 'Taxi booking saved successfully', 'charge': charge}), 201

    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/save_hotel_booking', methods=['POST'])
def save_hotel_booking():
    try:
        # Get JSON data from the request
        data = request.json

        # Extract fields from the JSON payload
        username = data.get('username')
        hotel_poi = data.get('hotel_poi')
        checkin_date = data.get('checkin_date')
        checkout_date = data.get('checkout_date')
        number_of_people = data.get('number_of_people')

        # Validate required fields
        if not all([username, hotel_poi, checkin_date, checkout_date, number_of_people]):
            return jsonify({'status': 'error', 'message': 'All fields are required'}), 400

        # Convert checkin_date and checkout_date to datetime objects using ISO format
        try:
            checkin_date_obj = datetime.fromisoformat(checkin_date)
            checkout_date_obj = datetime.fromisoformat(checkout_date)
        except ValueError:
            return jsonify({'status': 'error', 'message': 'Invalid date format'}), 400
        
        # Calculate the number of days for the booking
        days_stayed = (checkout_date_obj - checkin_date_obj).days

        # If days_stayed is 0 or negative, return an error
        if days_stayed <= 0:
            return jsonify({'status': 'error', 'message': 'Checkout date must be after checkin date'}), 400

        # Fetch hotel_poi from the users table based on username
        with sqlite3.connect(DATABASE) as conn:
            cursor = conn.cursor()
            cursor.execute('''
                SELECT hotel_poi FROM users WHERE username = ?
            ''', (username,))
            user_hotel_poi = cursor.fetchone()

            if not user_hotel_poi:
                return jsonify({'status': 'error', 'message': 'User not found'}), 404

            user_hotel_poi = user_hotel_poi[0]

        # Determine fare based on hotel_poi
        if user_hotel_poi == 'Resorts':
            fare = random.randint(5000, 7000)
        elif user_hotel_poi == 'Budget Stays':
            fare = random.randint(1000, 3000)
        elif user_hotel_poi == 'Homestays':
            fare = random.randint(3000, 5000)
        else:
            return jsonify({'status': 'error', 'message': 'Invalid hotel POI for user'}), 400

        # Double the fare if the booking is more than one day
        if days_stayed > 1:
            fare *= 2

        # Save data to the database
        with sqlite3.connect(DATABASE) as conn:
            cursor = conn.cursor()
            cursor.execute('''
                INSERT INTO hotel_bookings (username, hotel_poi, checkin_date, checkout_date, number_of_people, fare)
                VALUES (?, ?, ?, ?, ?, ?)
            ''', (username, hotel_poi, checkin_date, checkout_date, number_of_people, fare))
            conn.commit()

        # Return success response
        return jsonify({'status': 'success', 'message': 'Hotel booking saved successfully', 'fare': fare}), 201

    except sqlite3.IntegrityError:
        # Handle foreign key constraint or other database integrity errors
        return jsonify({'status': 'error', 'message': 'Invalid username or data'}), 400

    except Exception as e:
        # Log the full stack trace for debugging
        print("Error: ", e)
        return jsonify({'status': 'error', 'message': 'An unexpected error occurred'}), 500


@app.route('/get_bookings', methods=['GET'])
def get_bookings():
    try:
        conn = sqlite3.connect('user_data.db')
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM taxi_bookings')
        bookings = cursor.fetchall()
        conn.close()

        return jsonify([
            {
                'id': row[0],
                'username': row[1],
                'start_point': row[2],
                'destination_point': row[3],
                'preferred_transport': row[4],
                'date': row[5],
                'charge': row[6],  # Include the charge field
                'fare': row[7]  # Include the fare field
            } for row in bookings
        ])
    except Exception as e:
        print(f"Error fetching bookings: {e}")
        return jsonify({'status': 'error', 'message': 'Internal Server Error'}), 500
    

@app.route('/update_bookings', methods=['POST'])
def update_booking():
    try:
        data = request.json

        # Validate input fields including 'fare'
        if not all(key in data for key in ['id', 'start_point', 'destination_point', 'preferred_transport', 'date', 'charge', 'fare']):
            return jsonify({'status': 'error', 'message': 'Missing required fields'}), 400

        conn = sqlite3.connect('user_data.db')
        cursor = conn.cursor()

        # Update the booking with the new details, including charge and fare
        cursor.execute('''
            UPDATE taxi_bookings
            SET start_point = ?, destination_point = ?, preferred_transport = ?, date = ?, charge = ?, fare = ?
            WHERE id = ?
        ''', (data['start_point'], data['destination_point'], data['preferred_transport'], data['date'], data['charge'], data['fare'], data['id']))

        conn.commit()
        conn.close()

        return jsonify({'message': 'Booking updated successfully'})
    except Exception as e:
        print(f"Error updating booking: {e}")
        return jsonify({'status': 'error', 'message': 'Internal Server Error'}), 500

@app.route('/get_hotel_bookings', methods=['GET'])
def get_hotel_bookings():
    try:
        conn = sqlite3.connect('user_data.db')  # Replace with your actual database name
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM hotel_bookings')
        bookings = cursor.fetchall()
        conn.close()

        return jsonify([
            {
                'id': row[0],
                'username': row[1],
                'hotel_poi': row[2],
                'checkin_date': row[3],
                'checkout_date': row[4],
                'number_of_people': row[5],
                'fare': row[6]  # Include the fare field
            } for row in bookings
        ])
    except Exception as e:
        print(f"Error fetching hotel bookings: {e}")
        return jsonify({'status': 'error', 'message': 'Internal Server Error'}), 500


@app.route('/update_hotel_booking', methods=['POST'])
def update_hotel_booking():
    try:
        data = request.json

        # Validate input fields including 'fare'
        if not all(key in data for key in ['id', 'hotel_poi', 'checkin_date', 'checkout_date', 'number_of_people', 'fare']):
            return jsonify({'status': 'error', 'message': 'Missing required fields'}), 400

        conn = sqlite3.connect('user_data.db')  # Replace with your actual database name
        cursor = conn.cursor()

        # Update the booking with the new details, including fare
        cursor.execute('''
            UPDATE hotel_bookings
            SET hotel_poi = ?, checkin_date = ?, checkout_date = ?, number_of_people = ?, fare = ?
            WHERE id = ?
        ''', (data['hotel_poi'], data['checkin_date'], data['checkout_date'], data['number_of_people'], data['fare'], data['id']))

        conn.commit()
        conn.close()

        return jsonify({'message': 'Hotel booking updated successfully'})
    except Exception as e:
        print(f"Error updating hotel booking: {e}")
        return jsonify({'status': 'error', 'message': 'Internal Server Error'}), 500



@app.route('/get_taxi_user', methods=['GET'])
def get_taxi_user():
    username = request.args.get('username')  # Get the username from the query parameters
    if not username:
        return jsonify({"error": "Username is required"}), 400
    
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM taxi_bookings WHERE username = ?', (username,))
    taxi_bookings = cursor.fetchall()
    conn.close()

    # Convert to list of dictionaries
    bookings = []
    for booking in taxi_bookings:
        bookings.append({
            'id': booking['id'],
            'username': booking['username'],
            'start_point': booking['start_point'],
            'destination_point': booking['destination_point'],
            'preferred_transport': booking['preferred_transport'],
            'date': booking['date'],
            'charge': booking['charge']
        })
    
    return jsonify(bookings)


@app.route('/get_hotel_user', methods=['GET'])
def get_hotel_user():
    username = request.args.get('username')  # Get the username from the query parameters
    if not username:
        return jsonify({"error": "Username is required"}), 400
    
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM hotel_bookings WHERE username = ?', (username,))
    hotel_bookings = cursor.fetchall()
    conn.close()

    # Convert to list of dictionaries
    bookings = []
    for booking in hotel_bookings:
        bookings.append({
            'id': booking['id'],
            'username': booking['username'],
            'hotel_poi': booking['hotel_poi'],
            'checkin_date': booking['checkin_date'],
            'checkout_date': booking['checkout_date'],
            'number_of_people': booking['number_of_people'],
            'fare': booking['fare']
        })
    
    return jsonify(bookings)


@app.route('/get_all_users', methods=['GET'])
def get_all_users():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM users')
    users = cursor.fetchall()
    conn.close()
    
    user_list = [{
        "id": user["id"],
        "full_name": user["full_name"],
        "username": user["username"],
        "email": user["email"],
        "purpose_of_visit": user["purpose_of_visit"],
        "age_group": user["age_group"],
        "nature_poi": user["nature_poi"],
        "hotel_poi": user["hotel_poi"],
        "food_poi": user["food_poi"],
        "taxi_poi": user["taxi_poi"]
    } for user in users]
    
    return jsonify(user_list)

@app.route('/get_all_taxi_bookings', methods=['GET'])
def get_all_taxi_bookings():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM taxi_bookings')
    bookings = cursor.fetchall()
    conn.close()

    booking_list = [{
        "id": booking["id"],
        "username": booking["username"],
        "start_point": booking["start_point"],
        "destination_point": booking["destination_point"],
        "preferred_transport": booking["preferred_transport"],
        "date": booking["date"],
        "charge": booking["charge"]
    } for booking in bookings]
    
    return jsonify(booking_list)

@app.route('/get_all_hotel_bookings', methods=['GET'])
def get_all_hotel_bookings():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM hotel_bookings')
    bookings = cursor.fetchall()
    conn.close()

    booking_list = [{
        "id": booking["id"],
        "username": booking["username"],
        "hotel_poi": booking["hotel_poi"],
        "checkin_date": booking["checkin_date"],
        "checkout_date": booking["checkout_date"],
        "number_of_people": booking["number_of_people"],
        "fare": booking["fare"]
    } for booking in bookings]
    
    return jsonify(booking_list)

@app.route('/delete_user/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    try:
        # Connect to the database
        with sqlite3.connect(DATABASE) as conn:
            cursor = conn.cursor()

            # Fetch the username using the user_id
            cursor.execute('''
                SELECT username FROM users WHERE id = ?
            ''', (user_id,))
            user = cursor.fetchone()

            # If user is not found, return an error
            if not user:
                return jsonify({'status': 'error', 'message': 'User not found'}), 404

            username = user[0]

            # Delete associated taxi bookings using username
            cursor.execute('''
                DELETE FROM taxi_bookings WHERE username = ?
            ''', (username,))

            # Delete associated hotel bookings using username
            cursor.execute('''
                DELETE FROM hotel_bookings WHERE username = ?
            ''', (username,))

            # Delete the user from the users table using user_id
            cursor.execute('''
                DELETE FROM users WHERE id = ?
            ''', (user_id,))
            
            # Commit the transaction
            conn.commit()

        return jsonify({'status': 'success', 'message': 'User and associated data deleted successfully'}), 200

    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)
