import snap7
import time
import paho.mqtt.client as mqtt
import json
import asyncio
from snap7.util import get_bool, get_dint, get_real, set_bool

MQTT_BROKER = "ec2-3-25-193-42.ap-southeast-2.compute.amazonaws.com"
MQTT_PORT = 1883
MQTT_USERNAME = "admin"
MQTT_PASSWORD = "admin"
MQTT_BASE_TOPIC = "/test/"

def connect_to_plc(plc_ip, rack, slot):
    client = snap7.client.Client()
    client.connect(plc_ip, rack, slot)
    if client.get_connected():
        return client
    else:
        raise Exception("Connection failed")

def find_total_dbs(plc_client, max_db_attempts=100):
    db_number = 1
    while db_number <= max_db_attempts:
        try:
            plc_client.db_read(db_number, 0, 1)
            db_number += 1
        except Exception:
            break
    return db_number - 1

def read_and_decode_db(client, db_number):
    db_size = 18
    db_data = client.db_read(db_number, 0, db_size)

    temperature = get_real(db_data, 0)
    coolant_level = get_real(db_data, 4) 
    current=get_real(db_data,14)
    object_count = get_dint(db_data, 8)
    machine_on = get_bool(db_data, 12, 0)
    alarm_1=get_bool(db_data,12,1)
    alarm_2=get_bool(db_data,12,2)
    
    
    
    message_data = {
        "temperature": str(round(temperature/10,1)),
        "coolant_level": str(round(coolant_level,2)),
        "current":str(round(current,1)),
        "object_count": str(object_count),
        "machine_on": str(machine_on),
        'alarm_1':str(alarm_1),
        'alarm_2':str(alarm_2),
        "timestamp": time.strftime('%Y-%m-%d %H:%M:%S')
    }
    print(message_data)
    return message_data

def write_machine_on(client, db_number, value):
    db_size = 16
    db_data = client.db_read(db_number, 0, db_size)
    set_bool(db_data, 12, 0, value)
    client.db_write(db_number, 0, db_data)

async def publish_to_mqtt(client, topic, message):
    message_json = json.dumps(message)
    result = client.publish(topic, message_json)
    result.wait_for_publish()

async def process_db(plc_client, mqtt_client, db_number):
    message_data = read_and_decode_db(plc_client, db_number)
    topic = f"{MQTT_BASE_TOPIC}machine{db_number}"
    await publish_to_mqtt(mqtt_client, topic, message_data)

def on_message(client, userdata, msg):
    data = json.loads(msg.payload.decode())
    machine_name = msg.topic.split('/')[-2]
    db_number = int(machine_name.replace('machine', ''))
    
    if 'machine_on' in data:
        new_status = data['machine_on'].lower() == 'true'
        write_machine_on(userdata['plc_client'], db_number, new_status)

async def main_loop():
    mqtt_client = mqtt.Client(userdata={'plc_client': None})
    mqtt_client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)
    mqtt_client.connect(MQTT_BROKER, MQTT_PORT, 60)
    mqtt_client.loop_start()

    plc_ip = '10.1.45.203'
    rack = 0
    slot = 1
    plc_client = connect_to_plc(plc_ip, rack, slot)
    mqtt_client.user_data_set({'plc_client': plc_client})

    mqtt_client.subscribe(f"{MQTT_BASE_TOPIC}+/status")
    mqtt_client.on_message = on_message

    total_dbs = find_total_dbs(plc_client)

    try:
        while True:
            tasks = []
            for db_number in range(1, total_dbs+1):

                tasks.append(asyncio.create_task(process_db(plc_client, mqtt_client, db_number)))
            await asyncio.gather(*tasks)
            await asyncio.sleep(5)
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        mqtt_client.loop_stop()
        plc_client.disconnect()

if __name__ == "__main__":
    asyncio.run(main_loop())
