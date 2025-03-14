import os
import pickle
from flask import Flask, request, jsonify
from flask_cors import CORS

# Initialize Flask App
app = Flask(__name__)
CORS(app)  # Allow Cross-Origin Requests

# Set paths to the model and scaler files
model_path = os.path.join(os.path.dirname(__file__), 'model.pkl')
scaler_path = os.path.join(os.path.dirname(__file__), 'sc.pkl')
mx_path = os.path.join(os.path.dirname(__file__), 'mx.pkl')

# Load the trained model, scaler, and crop label mapping
model = pickle.load(open(model_path, 'rb'))
scaler = pickle.load(open(scaler_path, 'rb'))
mx = pickle.load(open(mx_path, 'rb'))

# Define Home Route to Check If API is Running
@app.route('/')
def home():
    return jsonify({"message": "Welcome to AgriTrack API! Use /predict for crop recommendations."})


# Define API Route for Crop Prediction
@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Get JSON input
        data = request.get_json()

        # Extract input values from request
        input_values = [[
            data['N'], data['P'], data['K'], 
            data['temperature'], data['humidity'], 
            data['ph'], data['rainfall']
        ]]

        # Preprocess the input using the same scaler
        input_scaled = scaler.transform(input_values)

        # Predict the crop
        prediction = model.predict(input_scaled)
        recommended_crop = mx[prediction[0]]

        # Return response
        return jsonify({'recommended_crop': recommended_crop})

    except Exception as e:
        return jsonify({'error': str(e)})

# Run Flask App
if __name__ == '__main__':
    app.run(debug=True)
