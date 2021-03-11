from flask import Flask, render_template
import connexion

# app = Flask(__name__)

app = connexion.App(__name__, specification_dir='./')
app.add_api('swagger.yml')

@app.route("/")
def hello():
    # print(type(get_user_object("user1.json")))
    # return "Welcome to API"
    return render_template('home.html')
    # return redirect(url_for('/api/ui'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)