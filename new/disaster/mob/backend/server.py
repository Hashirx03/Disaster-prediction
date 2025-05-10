from datetime import datetime
from flask import Flask, request, jsonify
from flask_mail import Mail, Message
import sqlite3
import pickle
import pandas as pd
import numpy as np
from sklearn.preprocessing import MinMaxScaler

with open('rfmodelE.pkl', 'rb') as r_file:
    modele = pickle.load(r_file)

with open('label_encoderE.pkl', 'rb') as k_file:
    label_encodere = pickle.load(k_file)   
 

with open('lrF.pkl', 'rb') as lr_file:
    modelF = pickle.load(lr_file)

with open('rf_modelL.pkl', 'rb') as model_file:
    modelL = pickle.load(model_file)
with open('rfmodelC.pkl', 'rb') as file:
    modelc = pickle.load(file)
with open('minmax_scalerC.pkl', 'rb') as file:
    scalerc = pickle.load(file)


app = Flask(__name__)

app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USERNAME'] = 'mediconnectotp@gmail.com'
app.config['MAIL_PASSWORD'] = 'fdio bdqo nhwt pous'
mail = Mail(app)

# Login route
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()  # Parse JSON request body
    username = data.get('username')
    password = data.get('password')

    try:
        conn = sqlite3.connect('users.db')
        cursor = conn.cursor()

        # Retrieve user information from the database
        cursor.execute('SELECT password, role FROM users WHERE username = ?', (username,))
        user = cursor.fetchone()
        conn.close()

        if user:
            stored_password, role = user

            if stored_password == password:  # Check if passwords match
                # Successful login
                return jsonify({'status': 'success', 'message': 'Login successful!', 'role': role}), 200
            else:
                # Incorrect password
                return jsonify({'status': 'error', 'message': 'Invalid password.'}), 401
        else:
            # Username not found
            return jsonify({'status': 'error', 'message': 'User not found.'}), 404

    except Exception as e:
        # Log and return server error
        print(f"Error occurred: {e}")
        return jsonify({'status': 'error', 'message': 'An error occurred during login.'}), 500


# Register route
@app.route('/register', methods=['POST'])
def register():
    # Use request.form to access the form data
    full_name = request.form.get('full_name')
    role = request.form.get('role')
    email = request.form.get('email')
    username = request.form.get('username')
    password = request.form.get('password')

    # Insert data into SQLite database
    try:
        conn = sqlite3.connect('users.db')
        cursor = conn.cursor()
        
        # Insert user data into the users table
        cursor.execute('''
            INSERT INTO users (full_name, role, email, username, password) 
            VALUES (?, ?, ?, ?, ?)
        ''', (full_name, role, email, username, password))
        
        # Commit the transaction and close the connection
        conn.commit()
        conn.close()
        
        return jsonify({'message': 'User registered successfully!'}), 201

    except sqlite3.IntegrityError:
        # Handle duplicate email or username
        return jsonify({'message': 'Email or username already exists.'}), 409

    except Exception as e:
        # Handle other errors
        print(f"Error occurred: {e}")
        return jsonify({'message': 'An error occurred during registration.'}), 500

@app.route('/predictf', methods=['POST'])
def predictf():
    try:
        # Get JSON data from the request
        data = request.get_json()
        
        # Extract the features and convert them to a list of floats
        features = [
            float(data['monsoon_intensity']),
            float(data['topography_drainage']),
            float(data['river_management']),
            float(data['dams_quality']),
            float(data['siltation']),
            float(data['disaster_preparedness']),
            float(data['watersheds']),
            float(data['infrastructure']),
            float(data['population_score']),
            float(data['political_factors'])
        ]
        
        # Convert to numpy array for prediction
        features_array = np.array([features])
        
        # Make prediction using the loaded model
        prediction = modelF.predict(features_array)[0]
        
        # Return the prediction result as JSON
        return jsonify({
            'flood_probability': prediction
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 400
    
@app.route('/predictl', methods=['POST'])
def predictl():
    try:
        # Get JSON data from the request
        data = request.get_json()
        if not data:
            return jsonify({'error': 'No input data provided'}), 400
            
        print("Received data:", data)

        # Extract features from the request data
        required_keys = ['Curvature', 'Earthquake', 'Elevation', 'Flow', 
                         'Lithology', 'NDVI', 'NDWI', 'Precipitation', 
                         'Profile', 'Slope']

        # Check if all required keys are present
        for key in required_keys:
            if key not in data:
                return jsonify({'error': f'Missing required key: {key}'}), 400

        # Extract features as floats
        features = [float(data[key]) for key in required_keys]
        print("Extracted features:", features)

        # Convert to numpy array for prediction
        features_array = np.array([features])
        print("Features array:", features_array)

        # Make prediction using the loaded model
        prediction = modelL.predict(features_array)[0]
        print("Raw prediction:", prediction)

        # Ensure prediction is a standard Python type (float or int)
        prediction_value = float(prediction) if isinstance(prediction, (np.float64, np.int64)) else prediction

        return jsonify({
            'landslide_probability': prediction_value
        })

    except Exception as e:
        print("Error occurred:", e)
        return jsonify({'error': 'An error occurred while processing the request'}), 500
    

@app.route('/predictc', methods=['POST'])
def predict():
    data = request.json
    print(data)
    
    # List of features used during model training
    model_columns =  ['latitude','longitude','maximum_wind','low_wind_ne','low_wind_se','low_wind_sw','low_wind_nw','moderate_wind_ne','moderate_wind_se','moderate_wind_nw']

   
    # Retrieve the values from the dictionary for each feature
    input_features = []
    for column in model_columns:
        if column in data:
            input_features.append(data[column])
        
            
    print(f"Input features: {input_features}")
    input_scaled = scalerc.transform([input_features])  
    print(f"Scaled input: {input_scaled}")
    predictions = modelc.predict(input_scaled)
    prediction_class = predictions[0] 
    print(f"Prediction class: {prediction_class}")

    return jsonify({'prediction': prediction_class})




@app.route('/predicte', methods=['POST'])
def predicte():
    
    if not request.is_json:
        return jsonify({"error": "Invalid input, expected JSON"}), 400

    data = request.get_json()
    print(data)

    cdi = float(data.get('cdi'))
    mmi = float(data.get('mmi'))
    alert = data.get('alert')  # Alert is categorical, so we'll encode it
    tsunami = float(data.get('tsunami'))
    sig = float(data.get('sig'))
    net = data.get('net')  # Net is categorical, so we'll encode it
    dmin = float(data.get('dmin'))
    gap = float(data.get('gap'))
    depth = float(data.get('depth'))
    longitude = float(data.get('longitude'))

    if isinstance(alert, str) and label_encodere:
        alert = label_encodere.transform([alert])[0]
    else:
        alert = float(alert)

    if isinstance(net, str) and label_encodere:
        net = label_encodere.transform([net])[0]
    else:
        net = float(net)

    # Prepare input for prediction (e.g., using a model)
    input_data = np.array([[cdi, mmi, alert, tsunami, sig, net, dmin, gap, depth, longitude]])

    if modele:
        # Make a prediction using the model (this could be your ML model or some logic)
        prediction = modele.predict(input_data)

        # You can modify the prediction format as needed
        result = {'prediction': str(prediction[0])}
        return jsonify(result), 200
    else:

        return jsonify({"error": "Model not found or failed to load"}), 500

@app.route('/emergency', methods=['POST'])
def emergency_request():
    try:
        # Extract the data from the request
        data = request.form
        disaster_type = data.get('disaster_type')
        help_type = data.get('help_type')
        description = data.get('description')
        latitude = data.get('latitude')
        longitude = data.get('longitude')
        username = data.get('username')

        # Check if all required fields are provided
        if not all([disaster_type, help_type, description, latitude, longitude, username]):
            return jsonify({"error": "All fields are required"}), 400

        # Save the request details to the existing 'users.db' database
        conn = sqlite3.connect('users.db')  # Use the existing users.db
        cursor = conn.cursor()

        # Insert the emergency request data into the existing 'emergency' table
        cursor.execute('''
            INSERT INTO emergency_help (disaster_type, help_type, description, latitude, longitude, username, timestamp)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (disaster_type, help_type, description, latitude, longitude, username, datetime.now()))

        conn.commit()
        conn.close()

        # Send email notification to the admin
        msg = Message('Emergency Request Received',
                      sender='mediconnectotp@gmail.com',
                      recipients=['jithujyoty@gmail.com'])
        msg.body = f"""
        Emergency Request Details:
        Disaster Type: {disaster_type}
        Help Type: {help_type}
        Description: {description}
        Location: Lat: {latitude}, Lng: {longitude}
        Username: {username}
        """
        mail.send(msg)

        return jsonify({"message": "Emergency request submitted successfully and email sent."}), 200

    except Exception as e:
        print(f"Error occurred: {e}")
        return jsonify({"error": "An error occurred while processing the request"}), 500



def get_user_profile(username):
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    cursor.execute("SELECT full_name, role, email, username FROM users WHERE username = ?", (username,))
    user = cursor.fetchone()
    conn.close()
    return user

@app.route('/profile', methods=['GET'])
def profile():
    username = request.args.get('username')
    user = get_user_profile(username)
    if user:
        return jsonify({
            'full_name': user[0],
            'role': user[1],
            'email': user[2],
            'username': user[3]
        })
    else:
        return jsonify({'error': 'User not found'}), 404
    


def fetch_notifications():
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM emergency_help ORDER BY timestamp DESC")
    notifications = cursor.fetchall()
    conn.close()

    # Convert the notifications to a JSON serializable format
    notification_list = [
        {
            'disaster_type': row[1],
            'help_type': row[3],
            'description': row[6],
            'latitude': row[4],
            'longitude': row[5],
            'username': row[2],
            'timestamp': format_timestamp(row[7]) 
        }
        for row in notifications
    ]
    return notification_list

def format_timestamp(timestamp):
    # Timestamp format: '2024-11-06 07:22:25.306750'
    try:
        # Use strptime to parse the timestamp with microseconds
        dt = datetime.strptime(timestamp, '%Y-%m-%d %H:%M:%S.%f')
    except ValueError:
        # If there's an issue parsing, handle it (optional)
        dt = datetime.strptime(timestamp, '%Y-%m-%d %H:%M:%S')  # Without microseconds if needed
    
    # Return formatted date string (e.g., '06-11-2024 07:22')
    return dt.strftime('%d-%m-%Y %H:%M')

@app.route('/notifications', methods=['GET'])
def get_notifications():
    notifications = fetch_notifications()
    return jsonify(notifications)

DATABASE = 'users.db'

def get_db():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn

@app.route('/users', methods=['GET'])
def get_users():
    """Fetch all users"""
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE role = 'user'")
    rows = cursor.fetchall()
    
    users = []
    for row in rows:
        user = {
            'id': row['id'],
            'full_name': row['full_name'],
            'role': row['role'],
            'email': row['email'],
            'username': row['username'],
            'password': row['password']
        }
        users.append(user)
    conn.close()
    
    return jsonify(users)


@app.route('/verify-username', methods=['GET'])
def verify_username():
    """Verify if the username exists"""
    username = request.args.get('username')
    print(username)
    if not username:
        return jsonify({'error': 'Username is required'}), 400
    
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE username = ?", (username,))
    user = cursor.fetchone()
    conn.close()
    
    if user:
        return jsonify({'status': 'success', 'message': 'Username found'})
    else:
        return jsonify({'status': 'error', 'message': 'Username not found'}), 404

@app.route('/update-password', methods=['POST'])
def update_password():
    """Update the user's password"""
    data = request.get_json()
    
    username = data.get('username')
    print(username)
    new_password = data.get('new_password')
    print(new_password)
    confirm_password = data.get('confirm_password')
    print(confirm_password)
    
    if not username or not new_password or not confirm_password:
        return jsonify({'error': 'Username, new password, and confirm password are required'}), 400
    
    if new_password != confirm_password:
        return jsonify({'error': 'New password and confirm password do not match'}), 400
    
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM users WHERE username = ?", (username,))
    user = cursor.fetchone()
    
    if user:
        # Here you would typically hash the new password before saving it
        cursor.execute("UPDATE users SET password = ? WHERE username = ?", (new_password, username))
        conn.commit()
        conn.close()
        
        return jsonify({'status': 'success', 'message': 'Password updated successfully'})
    else:
        conn.close()
        return jsonify({'status': 'error', 'message': 'Username not found'}), 404


@app.route('/alerts', methods=['GET'])
def get_alerts():
    """Fetch all alerts from the database"""
    conn = get_db()
    cursor = conn.cursor()
    
    # Query to fetch alerts from the database
    cursor.execute("SELECT * FROM admin_alerts")
    
    # Fetch all rows from the query result
    rows = cursor.fetchall()
    
    alerts = []
    for row in rows:
        alert = {
            'id': row['id'],
            'disaster_type': row['disaster_type'],
            'affected_location': row['location'],
            'description': row['details'],
            'date_reported': row['timestamp'],
        }
        alerts.append(alert)
    
    conn.close()
    
    # Return the list of alerts as JSON
    return jsonify(alerts)

@app.route('/share_alert', methods=['POST'])
def share_alert():
    """Save disaster alert details into the database."""
    try:
        # Get the JSON data from the request
        data = request.get_json()

        # Extract data from the JSON payload
        disaster_type = data.get('disaster_type')
        print(f"Disaster Type: {disaster_type}")
        affected_location = data.get('affected_location')
        print(f"Affected Location: {affected_location}")
        description = data.get('description')
        print(f"Description: {description}")

        # Check if mandatory fields are present
        if not disaster_type or not affected_location:
            return jsonify({'error': 'Disaster type and affected location are required'}), 400

        try:
            # Connect to the database
            conn = get_db()
            cursor = conn.cursor()

            # Insert the alert into the admin_alerts table
            cursor.execute(''' 
                INSERT INTO admin_alerts (disaster_type, location, details, timestamp)
                VALUES (?, ?, ?, CURRENT_TIMESTAMP)
            ''', (disaster_type, affected_location, description))

            # Commit the changes and close the connection
            conn.commit()
            conn.close()

            return jsonify({'message': 'Alert shared successfully'}), 201
        except Exception as e:
            return jsonify({'error': f"Database Error: {str(e)}"}), 500

    except Exception as e:
        return jsonify({'error': f"Request Error: {str(e)}"}), 500


@app.route('/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    """Delete a user by ID"""
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute('DELETE FROM users WHERE id = ?', (user_id,))
    conn.commit()
    conn.close()
    
    return jsonify({'message': 'User deleted successfully'}), 200



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
