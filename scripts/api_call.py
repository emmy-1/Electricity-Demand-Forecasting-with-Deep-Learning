from flask import Flask, jsonify, request
from flask_cors import CORS
import pyodbc
import pandas as pd
import os
from dotenv import load_dotenv

app = Flask(__name__)
CORS(app)

# Database connection 
DATABASE = os.getenv("ElectricConsumption")
SERVER = os.getenv("DB_SERVER")
USERNAME = os.getenv("DB_USER")
PASSWORD = os.getenv("DB_PASSWORD")
DRIVER = "{ODBC Driver 17 for SQL Server}"

def run_query(query):
    """Fetch data from SQL Server and return as JSON."""
    conn = pyodbc.connect(
        f"DRIVER={DRIVER};SERVER={SERVER};DATABASE={DATABASE};"
        f"UID={USERNAME};PWD={PASSWORD}"
    )
    cursor = conn.cursor()
    cursor.execute(query)
    rows = cursor.fetchall()
    columns = [column[0] for column in cursor.description]
    data = [dict(zip(columns, row)) for row in rows]
    conn.close()
    return data

API_KEY = "TensorFlowAccess123"  # e.g., "TensorFlowAccess123"

@app.route("/api/data", methods=["GET"])
def get_data():
    if request.args.get("key") != API_KEY:
        return jsonify({"error": "Invalid API key"}), 401
    query = "SELECT * FROM gold.household_power_consumption_at_15_min_interval"
    data = run_query(query)
    return jsonify(data)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)  # Run on local network