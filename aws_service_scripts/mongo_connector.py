import json
import pymongo
from pymongo import MongoClient

MONGO_URI = "Here goes MONGO DB URL"  

def write_to_mongo(db_name, collection_name, data):
    try:
        client = MongoClient(MONGO_URI)

        db = client[db_name]
        collection = db[collection_name]

        if isinstance(data, str):
            data = json.loads(data)
        
        result = collection.insert_one(data)

        print(f"Data inserted with record ID: {result.inserted_id}")
        
    except pymongo.errors.ConnectionFailure as e:
        print(f"Could not connect to MongoDB: {e}")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        client.close()



