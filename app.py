from flask import Flask, request
#import pymysql
#     conn = pymysql.connect(
#     host= 'endpoint link', 
#     port = '3306',
#     user = 'master username', 
#     password = 'master password',
#     db = 'db name',
# )

app = Flask(__name__)

@app.route('/')
def home():
    return "Hello, World!"


@app.route('/database')
def database_health():
    return "Database health check"

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5000)
