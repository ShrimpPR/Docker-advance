from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return {
        "message": "Meow.",
        "gif": "https://media.giphy.com/media/JIX9t2j0ZTN9S/giphy.gif"
    }

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8000))
    app.run(host='0.0.0.0', port=port)
