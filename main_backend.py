import serial
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from datetime import datetime
import os
from time import sleep
import threading

import math 
import requests

ROTA = "http://localhost:3000"
arduino_nano = serial.Serial(port='COM14', baudrate=9600, timeout=0, parity=serial.PARITY_EVEN, stopbits=1)
arduino_uno = serial.Serial(port='COM8', baudrate=9600)
start_req = requests.get(f"{ROTA}/new").status_code
if (start_req == 200):
    print("Inicializando ...")
else:
    print(f"Falha no servidor: {start_req}")
    exit(1)

def get_time_formated():
    month = datetime.now().month
    day = datetime.now().day
    hour = datetime.now().hour
    minute = datetime.now().minute
    secs = datetime.now().second
    return f"{day}-{month}@{hour};{minute};{secs}"

def plot_data_continous():
    files = os.listdir()
    csv_filenames = [f for f in files if "csv" and "continous" in f]
    for csv in csv_filenames:
        df = pd.read_csv(csv)
        print(df.columns)
        temp = df["Temperatura"].to_list()
        cycles = df["Ciclo"].to_list()
        t = np.arange(len(cycles))
        plt.scatter(cycles, temp, c=temp, cmap="magma_r")
        plt.xlabel("Ciclos [n]")
        plt.ylabel("Temperatura ºC")
        plt.ylim(min(temp) - 3, max(temp) + 3)
        plt.legend()
        plt.title("Temperatura em cada ciclo")
        plt.colorbar()
        plt.show()
        
def plot_data_highest_lowest():
    files = os.listdir()
    csv_filenames = [f for f in files if "csv" and "highest_lowest" in f]
    for csv in csv_filenames:
        df = pd.read_csv(csv)
        print(df.columns)
        temp_min = df["Temperatura Minima"].to_list()
        temp_max = df["Temperatura Maxima"].to_list()
        cycles = list(set(df["Ciclo"]))
        plt.bar(cycles, temp_max, color="red", label="Temperatura Máxima")
        plt.bar(cycles, temp_min, color="blue", label="Temperatura Mínima")
        plt.xlabel("Ciclos [n]")
        plt.ylabel("Temperatura ºC")
        plt.ylim(min(temp_min) - 3, max(temp_max) + 3)
        plt.legend()
        plt.title("Temperatura máxima e mínima em cada ciclo")
        plt.show()

def plot():
    plt.figure(0)
    plot_data_continous()
    plt.figure(1)
    plot_data_highest_lowest()


lock = threading.Lock()
current_temp_reading = 0
current_temp_list = []
cycle = 0
should_exit = False

def read_from_nano():
    global current_temp_reading, current_temp_list, should_exit
    current_time = get_time_formated()
    file_continous = open(f"{current_time}continous.csv", "a")
    file_continous.write("Temperatura,Ciclo\n")
    while True:
        if should_exit:
            file_continous.close()
            return
        nano_msg = arduino_nano.readline()
        if nano_msg:
            nano_msg = nano_msg.decode("utf-8").strip()
            lock.acquire()
            current_temp_reading = float(nano_msg)
            current_temp_list.append(current_temp_reading)

            if math.isnan(current_temp_reading):
                current_temp_reading = 69.69
            
            data_obj = {
                "current_temp": current_temp_reading,
                "cycle": cycle,
            }
            requests.post(f"{ROTA}/continuous", json=data_obj)

            file_continous.write(f"{current_temp_reading}, {cycle}\n")
 
            print("Nano: ", current_temp_reading)
            lock.release()

def read_from_uno():
    global cycle, current_temp_list, current_temp_reading, should_exit
    current_time = get_time_formated()
    file_highest_lowest = open(f"{current_time}highest_lowest.csv", "a")
    file_highest_lowest.write("Temperatura Minima,Temperatura Maxima,Ciclo\n")
    min_temp = -1
    max_temp = -1
    while True:
        try:
            uno_msg = arduino_uno.readline().decode("utf-8").strip()
            lock.acquire()
            if "Start" in uno_msg:
                min_temp = current_temp_reading
            if "End" in uno_msg:
                max_temp = current_temp_reading
            if min_temp != -1 and max_temp != -1:
                cycle += 1
                max_temp = max(current_temp_list)
                
                if math.isnan(min_temp):
                    min_temp = -2

                if math.isnan(max_temp):
                    max_temp = -2

                data_obj = {
                    "temp_init": min_temp,
                    "temp_final": max_temp,
                    "cycle": cycle,
                }
                requests.post(f"{ROTA}/highestlowest", json=data_obj)

                print(f"min_temp: {min_temp}, max_temp: {max_temp}, cycle: {cycle}")
                file_highest_lowest.write(f"{min_temp}, {max_temp}, {cycle}\n")
                min_temp = -1
                max_temp = -1
                current_temp_list = []
            print("Uno: ", uno_msg)
            lock.release()
        except Exception:
            file_highest_lowest.close()
            should_exit = True
            



def test_serial_reading():
    thread_nano = threading.Thread(target=read_from_nano)
    thread_uno = threading.Thread(target=read_from_uno)
    
    thread_nano.start()
    thread_uno.start()


test_serial_reading()
