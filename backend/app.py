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
        # Define the correct mapping of numeric labels to crop names
        crop_dict={

    'rice':1 ,
    'maize':2   ,
    'jute':3     ,
    'cotton':4    ,
    'coconut':5     ,
    'papaya':6      ,
    'orange':7     ,
    'apple' :8     ,
    'muskmelon':9   ,
    'watermelon':10,
    'grapes' :11,
    'mango' :12,
    'banana': 13    ,
    'pomegranate':14 ,
    'lentil' :15    ,
    'blackgram':16   ,
    'mungbean':17  ,
    'mothbeans':18  ,
    'pigeonpeas':19 ,
    'kidneybeans':20  ,
    'chickpea':21     ,
    'coffee':22,

}

# Predict the crop (returns a number)
        prediction = model.predict(input_scaled)[0]
        
        if prediction[0]   in crop_dict:
            crop = crop_dict[prediction[0]]
            recommended_crop= "{} is the reccomended crop".format(crop)
# Convert the prediction number into a crop name
        else:
            recommended_crop="no crop found"
# Return the actual crop name
        return jsonify({'recommended_crop': recommended_crop})
# Get the predicted crop index
       
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 10000))  # Use Render's PORT
    app.run(host="0.0.0.0", port=port, debug=True)

