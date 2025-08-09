from flask import Flask, request, jsonify

app = Flask(__name__)

# Create the endpoint
@app.route("/analyze", methods=['POST'])
def hello_world():
    if not request.is_json:
        return jsonify({"Error": "No data inrequest body!"}), 400
    
    data = request.get_json()
    payload = data.get("text")

    result = {
        "original_text": payload,
        "word_count": len(payload.split(" ")),
        "character_count": len(payload)
    }
    return jsonify(result), 200

if __name__ == 'main':
    app.run(debug=True)