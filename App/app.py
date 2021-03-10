from flask import Flask
from StorageFunctions.dataaccess import *
app = Flask(__name__)

@app.route("/")
def hello():
    return get_user_object("user1.json")
