import serial
import requests
import re
import time
import threading

sensors = ['s1', 's2', 's3', 's4', 's5', 's6', 's7', 's8', 's9']

server_url = 'http://localhost:3000/sensorCreateCapsule'  # URL de votre route Express.js

def send_data(sensor_data):
    try:
        response = requests.post(server_url, json=sensor_data)
        response.raise_for_status()
        print('Data sent successfully')
    except Exception as e:
        print('Error sending data:', str(e))

for i in range(100):

    threads = []

    for s in sensors: 
        sensor_data = {
            'sensorId': s,
            'valueA': i,
            'valueB': i
        }
        thread = threading.Thread(target=send_data, args=(sensor_data,))
        thread.start()
        threads.append(thread)

    # Attendre la fin de tous les threads
    for thread in threads:
        thread.join()

    time.sleep(0.1)  # Facultatif : ajouter une petite pause entre chaque itération