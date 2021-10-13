from flask import Flask

app = Flask(__name__)


@app.route("/")
def root():
    return "Hello"


if __name__ == "__main__":
    app.run(debug=True)
