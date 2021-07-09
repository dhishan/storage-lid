from flask import Flask, render_template, redirect, url_for
import connexion, os
from opencensus.ext.azure.trace_exporter import AzureExporter
from opencensus.ext.flask.flask_middleware import FlaskMiddleware
from opencensus.trace.samplers import ProbabilitySampler
# app = Flask(__name__)

app = connexion.FlaskApp(__name__, specification_dir='./')
# app.add_api('swagger.yml', base_path='/1.0')
app.add_api('swagger.yml')
instrumentation_key = os.environ['APP_IKEY']
middleware = FlaskMiddleware(
    app,
    exporter=AzureExporter(connection_string=instrumentation_key),
    sampler=ProbabilitySampler(rate=1.0),
)

@app.route("/")
def index():
    # return "Welcome to API"
    # return render_template('home.html')
    return redirect('/api/ui/')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)