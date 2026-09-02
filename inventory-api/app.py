import logging
import os
from datetime import datetime, timezone
import psycopg2
from flask import Flask, jsonify
app = Flask(__name__)
def get_db_connection():
    return psycopg2.connect(
        host=os.environ["DB_HOST"],
        dbname=os.environ["POSTGRES_DB"],
        user=os.environ["POSTGRES_USER"],
        password=os.environ["POSTGRES_PASSWORD"],
    )
@app.get("/health")

def health():
    return jsonify({"status": "healthy"}), 200
@app.get("/inventory/<int:product_id>")

def get_inventory(product_id):
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT product_id, stock FROM inventory WHERE product_id = %s",
                (product_id,),
            )
            row = cursor.fetchone()
    finally:
        connection.close()
    if row is None:
        return jsonify({"error": "product not found"}), 404
    timestamp = datetime.now(timezone.utc).isoformat()
    logging.info(
        "%s inventory_lookup product_id=%s stock=%s",
        timestamp,
        row[0],
        row[1],
    )
    return jsonify(
        {
            "product_id": row[0],
            "stock": row[1],
        }
    )

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    app.run(host="0.0.0.0", port=5000)
