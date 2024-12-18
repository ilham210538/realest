from flask import Flask, request, send_file, jsonify
from rembg import remove
from PIL import Image
import io
# from flask_cors import CORS

app = Flask(__name__)
# CORS(app)  # Enable CORS for all routes

@app.route('/remove-bg', methods=['POST'])
def remove_background():
    """
    Remove background from a single uploaded image.
    """
    try:
        # Check if an image file is included in the request
        if 'file' not in request.files:
            return jsonify({"error": "No file part in the request"}), 400

        file = request.files['file']
        if file.filename == '':
            return jsonify({"error": "No file selected"}), 400

        # Read the file and process it with rembg
        input_image = file.read()
        output_image = remove(input_image)

        # Convert the processed output to a PIL image
        output_pil_image = Image.open(io.BytesIO(output_image)).convert("RGBA")

        # Save the output image to an in-memory file
        output_io = io.BytesIO()
        output_pil_image.save(output_io, format="PNG")
        output_io.seek(0)

        # Return the processed image
        return send_file(output_io, mimetype='image/png')

    except Exception as e:
        return jsonify({"error": f"Failed to process the image: {str(e)}"}), 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
