import os
import paho.mqtt.client as mqtt
import json
from mongo_connector import write_to_mongo
from firestore_pub import write_to_firestore
from firebase_service import monitor_firestore_changes

MQTT_BROKER = "127.0.0.1"
MQTT_PORT = int(os.getenv("MQTT_PORT", 1883))
MQTT_USERNAME = "admin"
MQTT_PASSWORD = "admin"

def parse_mqtt_topic(topic):
    parts = topic.split('/')
    if len(parts) < 2:
        raise ValueError("Topic must have at least 2 parts: db/collection/")
    db = parts[0]
    collection = parts[1]

    return db, collection

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected successfully to MQTT broker")
        client.subscribe("#")
    else:
        print(f"Failed to connect, return code {rc}")

def on_message(client, userdata, message):
    topic = message.topic
    if topic.startswith('/'):
        topic = topic[1:]
        
    try:
        payload_str = message.payload.decode('utf-8')
        data_dict = json.loads(payload_str)
        db, collection = parse_mqtt_topic(topic)
        result = json.dumps(data_dict, indent=4)
        write_to_mongo(db, collection, result)
        write_to_firestore(db, collection, result)
    except ValueError as e:
        print(e)

def on_log(client, userdata, level, buf):
    return

def main():
    client = mqtt.Client()
    if MQTT_USERNAME and MQTT_PASSWORD:
        client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)
    client.on_connect = on_connect
    client.on_message = on_message
    client.on_log = on_log

    try:
        client.connect(MQTT_BROKER, MQTT_PORT, 60)
        client.loop_forever()
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
