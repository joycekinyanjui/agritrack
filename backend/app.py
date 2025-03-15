import os
import pickle
from flask import Flask, request, jsonify
from flask_cors import CORS

# Initialize Flask App
app = Flask(__name__)
CORS(app)  # Enable CORS for frontend requests

# Set file paths
model_path = os.path.join(os.path.dirname(__file__), "model.pkl")
scaler_path = os.path.join(os.path.dirname(__file__), "sc.pkl")
mx_path = os.path.join(os.path.dirname(__file__), "mx.pkl")

# Load the trained model, scaler, and crop label mapping
try:
    model = pickle.load(open(model_path, "rb"))
    scaler = pickle.load(open(scaler_path, "rb"))
    mx = pickle.load(open(mx_path, "rb"))
    print("✅ Model and scaler loaded successfully")
except FileNotFoundError as e:
    print(f"❌ ERROR: {e}")
    exit()

# Home Route
@app.route("/")
def home():
    return jsonify({"message": "Welcome to AgriTrack API! Use /predict for crop recommendations."})

# Crop Prediction Route
@app.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.get_json()
        input_values = [[
            data["N"], data["P"], data["K"], 
            data["temperature"], data["humidity"], 
            data["ph"], data["rainfall"]
        ]]
        input_scaled = scaler.transform(input_values)
        prediction = model.predict(input_scaled)
        recommended_crop = mx[prediction[0]]
        return jsonify({"recommended_crop": recommended_crop})
    except Exception as e:
        return jsonify({"error": str(e)})

# Run Flask App
if __name__ == '__main__':
    port = int(os.environ.get("PORT", 10000))  # Render assigns a dynamic port
    app.run(host='0.0.0.0', port=port, debug=True)
