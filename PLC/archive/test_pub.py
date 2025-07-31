import paho.mqtt.client as mqtt
import time
import json  
import random

# MQTT broker details
MQTT_BROKER = "127.0.0.1"
MQTT_PORT = 1883
MQTT_USERNAME = "admin"
MQTT_PASSWORD = "admin"
MQTT_BASE_TOPIC = "/test/"
PUBLISH_INTERVAL = 5  

# List of machines to publish to
machines = ["machine1", "machine2", "machine3"]

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected successfully to broker")
    else:
        print(f"Failed to connect, return code {rc}")

def on_publish(client, userdata, mid):
    print(f"Message published")

def on_log(client, userdata, level, buf):
    print(f"Log: {buf}")

def main():
    client = mqtt.Client()

    client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)

    client.on_connect = on_connect
    client.on_publish = on_publish
    client.on_log = on_log

    try:
        client.connect(MQTT_BROKER, MQTT_PORT, 60)

        client.loop_start()

        while True:
            # Publish data to each machine's topic
            for machine in machines:
                temperature = random.randrange(0, 50)
                # Create JSON data to publish
                message_data = {
                    "temperature": temperature,
                    "status": "active",
                    "timestamp": time.strftime('%Y-%m-%d %H:%M:%S')  # Add current timestamp
                }

                # Convert the data to a JSON string
                message_json = json.dumps(message_data)

                # Define the topic for each machine
                topic = f"{MQTT_BASE_TOPIC}{machine}"

                # Publish the JSON message
                result = client.publish(topic, message_json)

                result.wait_for_publish()

                if result.rc != mqtt.MQTT_ERR_SUCCESS:
                    print(f"Error: Failed to publish the message to {machine}.")
                else:
                    print(f"Message successfully published to {machine}: {message_json}")

            # Wait for the specified interval before publishing again
            time.sleep(PUBLISH_INTERVAL)

    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        client.loop_stop()

if __name__ == "__main__":
    main()
