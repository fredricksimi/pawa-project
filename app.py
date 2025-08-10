from flask import Flask, request, jsonify

app = Flask(__name__)

# This is the endpoint that we'll use
@app.route("/analyze", methods=['POST'])
def content_analyzer():

    # Checking if there's JSON data in the request body
    if not request.is_json:
        return jsonify({"Error": "No data inrequest body!"}), 400

    # Extracting the data if found
    data = request.get_json()
    if "text" not in data:
        return jsonify({"Error": "Provide the input with 'text' as the key, and the input as the value"}), 400

    payload = data.get("text")
        
    if payload == '':
        return jsonify({"Error": "Kindly provide input text to be analyzed!"}), 400
    if payload is not None:
        # Analyzing the data we got
        result = {
            "original_text": payload,
            "word_count": len(payload.split(" ")),
            "character_count": len(payload)
        }

        # returning our result in JSON format as well as passing the status code
        return jsonify(result), 200

if __name__ == 'main':
    app.run(debug=True)