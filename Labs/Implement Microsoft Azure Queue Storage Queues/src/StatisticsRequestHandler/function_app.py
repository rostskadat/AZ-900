import azure.functions as func
import logging

app = func.FunctionApp()

@app.route(route="req")
@app.function_name(name="HttpTrigger1")
@app.read_blob(arg_name="obj", path="samples/{id}", connection="AzureWebJobsStorage")

def main(req: func.HttpRequest,
         obj: func.InputStream)-> str:
    user = req.params.get('user')
    logging.info(f'Python HTTP triggered function processed: {obj.read()}')
    return f'Hello, {user}!'