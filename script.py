import serial
import requests
import re
import time

port = "/dev/cu.usbmodem14101"
ser = serial.Serial(port, 9600)  # Remplacez 'COMx' par le port série correspondant à votre Arduino
sensorId = "s1"


server_url = 'http://localhost:3000/sensorCreateCapsule'  # URL de votre route Express.js

while True:
    try:
        # Lire les données série de l'Arduino
        data = ser.readline().decode().strip()

        # Séparer les valeurs des capteurs
        humidity, temperature = data.split(',')

        hum = re.findall(r'\d+\.\d+', humidity)[0]
        temp = re.findall(r'\d+\.\d+', temperature)[0]

        # Créer un dictionnaire avec les données
        sensor_data = {
            'sensorId': sensorId,
            'valueA': hum,
            'valueB': temp
        }

        print(sensor_data)

        # Envoyer les données au serveur Express.js via une requête POST
        response = requests.post(server_url, json=sensor_data)
        response.raise_for_status()

        print('Data sent successfully')
        time.sleep(10)
    except Exception as e:
        print('Error sending data:', str(e))
