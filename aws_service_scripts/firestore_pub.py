import firebase_admin
from firebase_admin import credentials, firestore
import json
# Firebase credentials and initialization
cred = credentials.Certificate("key.json")
firebase_admin.initialize_app(cred)
firestore_db = firestore.client()

def write_to_firestore(collection_name, document_id, data):
    try:
        if isinstance(data, str):
            data = json.loads(data)

        doc_ref = firestore_db.collection(collection_name).document(document_id)
        doc_ref.update(data)

        print(f"Data published to Firestore: {document_id}")
    except Exception as e:
        print(f"An error occurred while writing to Firestore: {e}")

def monitor_firestore_changes(mqtt_client,db):
    
    def on_snapshot(doc_snapshot, changes, read_time):
        for doc in doc_snapshot:
            doc_data = doc.to_dict()
            machine_name = doc.id
            topic = f"/test/{machine_name}/machine_on"
            data = {
                "machine_on": doc_data.get("machine_on"),
                "timestamp": doc_data.get("timestamp", "")
            }
            mqtt_client.publish(topic, json.dumps(data))
    
    doc_ref = firestore_db.collection('test')
    doc_ref.on_snapshot(on_snapshot)
