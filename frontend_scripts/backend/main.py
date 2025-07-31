from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Dict
from pymongo import MongoClient
import pandas as pd

app = FastAPI()

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],  
    allow_headers=["*"], 
)

mongo_uri = "Enter you mongo url"
client = MongoClient(mongo_uri)
db = client["test"]

@app.get("/csvdata", response_model=Dict[str, Dict[str, List]])
def get_csv_data():
    csv_data = {}
    try:
        for machine_name in db.list_collection_names():
            collection = db[machine_name]
            print(collection)
            
            df = pd.DataFrame(list(collection.find({}, {"_id": 0, "current": 1, "temperature": 1, "timestamp": 1})))
            print(df)
            if 'timestamp' in df.columns:
                df["timestamp"] = pd.to_datetime(df["timestamp"], errors='coerce')
            
            df = df.dropna(subset=["current", "temperature", "timestamp"])
            df["current"] = pd.to_numeric(df["current"], errors='coerce')
            df["temperature"] = pd.to_numeric(df["temperature"], errors='coerce')
            print(df)
            machine_data = {
                "current": df["current"].tolist(),
                "temperature": df["temperature"].tolist(),
                "timestamp": df["timestamp"].astype(str).tolist()  
            }
            print(machine_data)

            csv_data[machine_name] = machine_data
        print(csv_data)
        return csv_data
    except Exception as e:
        return {"error": str(e)}
