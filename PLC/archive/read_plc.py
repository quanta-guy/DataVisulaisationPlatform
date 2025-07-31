import snap7
import time
import paho.mqtt.client as mqtt
import json
from snap7.util import get_bool, get_word, get_real, get_dint

MQTT_BROKER = "127.0.0.1"
MQTT_PORT = 1883
MQTT_USERNAME = "admin"
MQTT_PASSWORD = "admin"
MQTT_BASE_TOPIC = "/test/"

def connect_to_plc(plc_ip, rack, slot):
    client = snap7.client.Client()
    client.connect(plc_ip, rack, slot)
    if client.get_connected():
        print(f"Connected to PLC at {plc_ip}")
    else:
        raise Exception("Connection to PLC failed")
    return client

def read_and_decode_db(client, db_number):
    db_size = 20  
    db_data = client.db_read(db_number, 0, db_size)

    current_error_stat = get_bool(db_data, 0, 0)
    current_stat = get_word(db_data, 2)
    current_sub_stat = get_word(db_data, 4)
    frequency = get_dint(db_data, 6)
    current = get_real(db_data, 10)
    voltage = get_real(db_data, 14)
    status = get_bool(db_data, 18, 0)

    message_data = {
        "current_error_stat": str(current_error_stat),
        "current_stat": str(current_stat),
        "current_sub_stat": str(current_sub_stat),
        "frequency": str(frequency),
        "current": (current),
        "voltage": voltage,
        "status": status,
        "timestamp": time.strftime('%Y-%m-%d %H:%M:%S')
    }
    
    return message_data

def publish_to_mqtt(client, topic, message):
    message_json = json.dumps(message)
    result = client.publish(topic, message_json)
    result.wait_for_publish()
    if result.rc != mqtt.MQTT_ERR_SUCCESS:
        print(f"Error: Failed to publish message to topic {topic}")
    else:
        print(f"Published data to {topic}: {message_json}")

def main():
    mqtt_client = mqtt.Client()
    mqtt_client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)
    mqtt_client.connect(MQTT_BROKER, MQTT_PORT, 60)
    mqtt_client.loop_start()

    plc_ip = '10.1.45.201'
    rack = 0
    slot = 1
    plc_client = connect_to_plc(plc_ip, rack, slot)

    db_number = 1

    try:
        while True:
            
            message_data = read_and_decode_db(plc_client, db_number)

            topic = f"{MQTT_BASE_TOPIC}machine{db_number}"
            publish_to_mqtt(mqtt_client, topic, message_data)

            
            db_number += 1
            time.sleep(5)  

    except Exception as e:
        print(f"An error occurred: {e}")

    finally:
        mqtt_client.loop_stop()
        plc_client.disconnect()

if __name__ == "__main__":
    main()
