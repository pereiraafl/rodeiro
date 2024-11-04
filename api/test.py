import requests
import socketio
from time import sleep
import json

import os
import matplotlib.pyplot as plt



rota = "http://localhost:3000"

def create_highestlowest():
    req = requests.get(f"{rota}/new")
    for i in range(30): 
        rodeiro = {
            "temp_init": i + 10,
            "temp_final": i + 25,
            "cycle": i
        }
        req = requests.post(f"{rota}/highestlowest", json=rodeiro)
    print(req)

def create_continuous():
    req = requests.get(f"{rota}/new")
    for i in range(30):
        rodeiro = {
            "current_temp": i + 3,
            "cycle": i
        }
        req = requests.post(f"{rota}/continuous", json=rodeiro)
    print(req)

def get_highestlowest():
    req = requests.get(f"{rota}/highestlowest")
    print(req.text)

def get_continuous():
    req = requests.get(f"{rota}/continuous")
    print(req.text)

def get_last_highestlowest():
    req = requests.get(f"{rota}/highestlowest/last")
    print(f"last highestlowest: { req.text }")

def get_last_continuous():
    req = requests.get(f"{rota}/continuous/last")
    print(f"last continuous: { req.text }")


def test_sockets():
    sio = socketio.Client()
    @sio.event
    def connect():
        print("Socket connected successfully")


    @sio.on("send")
    def handle_send(data):
        print("Received data:", data)
        message = data["mode"]
        if "on" in message:
            print("DEVO LIGAR")
        if "off" in message:
            print("DEVO DESLIGAR")

    sio.connect("http://localhost:3000")
    while True:
        sleep(3)
        sio.emit("send", "Enviando dados")

def plot_highestlowest():
    highest_lowest_route = "http://150.162.208.160:3000/highestlowest"
    raw_data = requests.get(highest_lowest_route).json()
    arr_temp_init = []
    arr_temp_final = []
    arr_cycles = []
    for data in raw_data: # {'_id': '6728c8709ef8a227fb1aa30f', 'temp_init': 22, 'temp_final': 26.5, 'cycle': 1, '__v': 0}
        arr_temp_init.append(data["temp_init"])
        arr_temp_final.append(data["temp_final"])
        arr_cycles.append(data["cycle"])
    plt.bar(arr_cycles, arr_temp_final, color="red", label="Temperatura Máxima")
    plt.bar(arr_cycles, arr_temp_init, color="blue", label="Temperatura Mínima")
    plt.xlabel("Ciclos [n]")
    plt.ylabel("Temperatura ºC")
    plt.ylim(min(arr_temp_init) - 3, max(arr_temp_final) + 3)
    plt.legend()
    plt.title("Temperatura máxima e mínima em cada ciclo")
    plt.show()

def plot_continuous():
    highest_lowest_route = "http://150.162.208.160:3000/continuous"
    raw_data = requests.get(highest_lowest_route).json()
    arr_temp = []
    arr_cycles = []
    for data in raw_data: #{"_id":"6728ce829ef8a227fb1addae","current_temp":84.75,"cycle":15,"__v":0}
        arr_temp.append(data["current_temp"])
        arr_cycles.append(data["cycle"])
    plt.scatter(arr_cycles, arr_temp, c=arr_temp, cmap="magma_r")
    plt.xlabel("Ciclos [n]")
    plt.ylabel("Temperatura ºC")
    plt.ylim(min(arr_temp) - 3, max(arr_temp) + 3)
    plt.legend()
    plt.title("Temperatura em cada ciclo")
    plt.colorbar()
    plt.show()



# create_highestlowest()
# create_continuous()
# get_highestlowest()
# get_continuous()
# get_last_continuous()
# test_sockets()
plot_highestlowest()
