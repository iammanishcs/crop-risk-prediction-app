# === Phase 2: Final Backend API (app.py) ===

from flask import Flask, request, jsonify
import pickle
import numpy as np

app = Flask(__name__)

# Load the trained model and encoders
model = pickle.load(open('model.pkl', 'rb'))
le_label = pickle.load(open('le_label.pkl', 'rb'))
le_risk_level = pickle.load(open('le_risk_level.pkl', 'rb'))

@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.get_json(force=True)
        
        # Encode the incoming crop label
        crop_label_encoded = le_label.transform([data['label']])

        # Create the feature array in the correct order
        features = [np.array([
            data['N'], data['P'], data['K'], data['temperature'],
            data['humidity'], data['ph'], data['rainfall'], crop_label_encoded[0]
        ])]
        
        # Make prediction
        prediction_encoded = model.predict(features)
        
        # Decode the prediction back to a string
        prediction = le_risk_level.inverse_transform(prediction_encoded)
        
        # Send the result back
        return jsonify({'risk_level': prediction[0]})
    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    # Run the server and make it accessible on your network
    app.run(host='0.0.0.0', port=5000)