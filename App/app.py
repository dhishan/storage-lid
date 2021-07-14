from flask import Flask, render_template, redirect, url_for
import connexion, os, logging
from applicationinsights.flask.ext import AppInsights 
# from opencensus.ext.azure.trace_exporter import AzureExporter
# from opencensus.ext.flask.flask_middleware import FlaskMiddleware
# from opencensus.trace.samplers import ProbabilitySampler
# middleware = FlaskMiddleware(
#     app,
#     exporter=AzureExporter(connection_string=instrumentation_key),
#     sampler=ProbabilitySampler(rate=1.0),
# )

# app = Flask(__name__)

app = connexion.FlaskApp(__name__, specification_dir='./')
# app.add_api('swagger.yml', base_path='/1.0')

app.add_api('swagger.yml')
instrumentation_key = None
if 'APP_IKEY' in os.environ:
    instrumentation_key = os.environ['APP_IKEY']
    app.config['APPINSIGHTS_INSTRUMENTATIONKEY'] = instrumentation_key
    appinsights = AppInsights(app)

streamHandler = logging.StreamHandler()
application = app.app
# application.logger.addHandler(streamHandler)
application.logger.setLevel(logging.DEBUG)

@app.route("/")
def index():
    application.logger.debug('Redirecting from root')
    # return "Welcome to API"
    # return render_template('home.html')
    return redirect('/api/ui/')

@application.after_request
def after_request(response):
    if instrumentation_key is not None:
        application.logger.debug('sending to app insights')
        appinsights.flush()
    return response

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)