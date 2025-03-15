import os
import pickle
import numpy as np
import pandas as pd
from flask import Flask, request, jsonify
from flask_cors import CORS

# Initialize Flask App
app = Flask(__name__)
CORS(app)  # Allow Cross-Origin Requests

# Set paths to the model and scaler files
model_path = os.path.join(os.path.dirname(__file__), 'model.pkl')
scaler_path = os.path.join(os.path.dirname(__file__), 'sc.pkl')
mx_path = os.path.join(os.path.dirname(__file__), 'mx.pkl')

# Load the trained model, scaler, and MinMaxScaler
try:
    model = pickle.load(open(model_path, 'rb'))
    scaler = pickle.load(open(scaler_path, 'rb'))
    mx = pickle.load(open(mx_path, 'rb'))
    print("✅ Model and scalers loaded successfully!")
except Exception as e:
    print(f"❌ Error loading model: {e}")

# Define Home Route to Check If API is Running
@app.route('/')
def home():
    return jsonify({"message": "Welcome to AgriTrack API! Use /predict for crop recommendations."})

# Define API Route for Crop Prediction
@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Ensure the request is in JSON format
        if not request.is_json:
            return jsonify({'error': 'Invalid request format. Must be JSON'}), 400
        
        data = request.get_json()

        # Ensure all required fields are present
        required_fields = ["N", "P", "K", "temperature", "humidity", "ph", "rainfall"]
        if not all(field in data for field in required_fields):
            return jsonify({'error': 'Missing fields in request'}), 400

        # Convert input into DataFrame (ensures correct feature names)
        input_df = pd.DataFrame([[data['N'], data['P'], data['K'], 
                                  data['temperature'], data['humidity'], 
                                  data['ph'], data['rainfall']]], 
                                columns=required_fields)

        # Preprocess the input using the same scalers
        mx_features = mx.transform(input_df)  # MinMaxScaler
        input_scaled = scaler.transform(mx_features)  # StandardScaler

        # Predict the crop
        prediction = model.predict(input_scaled)[0]  # Get the predicted crop index
        
        # Convert the numeric prediction to a crop name
        recommended_crop = prediction  # If using LabelEncoder, map it to a name

        # Return response
        return jsonify({'recommended_crop': str(recommended_crop)})  # Convert to string

    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Run Flask App
if __name__ == '__main__':
    app.run(debug=True)
