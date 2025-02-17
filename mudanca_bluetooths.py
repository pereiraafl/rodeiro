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

import socketio
from requests.exceptions import ConnectionError

from timeit import default_timer as timer

ROTA = "http://localhost:3000"

COM_PORT_BLUETOOTH = "COM8"
COM_PORT_SERIAL = "COM9"

arduino_uno_bluetooth = serial.Serial(port=COM_PORT_BLUETOOTH, baudrate=9600, timeout=0, parity=serial.PARITY_EVEN, stopbits=1)
arduino_nano_serial = serial.Serial(port=COM_PORT_SERIAL, baudrate=9600)

start_req = requests.get(f"{ROTA}/new").status_code
if (start_req == 200):
    print("Inicializando ...")
else:
    print(f"Falha no servidor: {start_req}")
    exit(1)

should_exit = False

def handle_socket():
    global should_exit
    sio = socketio.Client()

    @sio.event
    def connect():
        print("Socket connected successfully")


    @sio.on("send")
    def handle_send(data):
        print("Received data:", data)
        message = data["mode"]
        if "on" == message:
            arduino_uno_bluetooth.write("on".encode())
        elif "offWithoutBreaking" == message:
            arduino_uno_bluetooth.write("offWithoutBreaking".encode())
        elif "off" == message:
            arduino_uno_bluetooth.write("off".encode())

    try:
        sio.connect(ROTA)
        while True:
            if should_exit:
                return
            sleep(1)
    except Exception as e:
        print(f"Error connecting to socket: {e}")


def get_time_formated():
    month = datetime.now().month
    day = datetime.now().day
    hour = datetime.now().hour
    minute = datetime.now().minute
    secs = datetime.now().second
    return f"{day}-{month}@{hour};{minute};{secs}"


lock = threading.Lock()

trigger_lock = threading.Lock()
rodeiro_is_locked = False

current_temp_reading = 0
cycle = 0


def serial_thread():
    global current_temp_reading, should_exit, cycle, arduino_nano_serial
    previous_reading = current_temp_reading
    current_time = get_time_formated()
    file_continous = open(f"{current_time}continous.csv", "a")
    file_continous.write("Temperatura,Ciclo\n")
    while True:
        try:
            if should_exit:
                file_continous.close()
                return
            nano_msg = arduino_nano_serial.readline().decode("utf-8").strip()
            if nano_msg:
                lock.acquire()
                current_temp_reading = float(nano_msg)
                
                if cycle == 0:
                    previous_reading = current_temp_reading

                if abs((current_temp_reading - previous_reading)) < 10:
                    data_obj = {
                        "current_temp": current_temp_reading,
                        "cycle": cycle,
                    }
                    requests.post(f"{ROTA}/continuous", json=data_obj)
                    file_continous.write(f"{current_temp_reading}, {cycle}\n")
                    print(f"Temperatura: {current_temp_reading} | Ciclo: {cycle}")
                    previous_reading = current_temp_reading
                else:
                    print(f"Leitura muito abrupta. Atual: {current_temp_reading}, anterior: {previous_reading}")
                lock.release()
        except Exception as e:
            if isinstance(e, ConnectionError):
                print("[Thread Arduino Nano] Conexao caiu com a internet... Tentando novamente")
            elif isinstance(e, serial.SerialException):
                print("[Thread Arduino Nano] ERRO: Aconteceu uma desconexão com o Arduino Nano")
                sleep(1)
                arduino_nano_serial = reconnect_arduino_nano_serial()
                continue
            else:
                print("Deu problema: ", e.with_traceback)
                file_continous.close()

def reconnect_arduino_nano_serial():
    global arduino_nano_serial
    while True:
        try:
            if arduino_nano_serial and arduino_nano_serial.is_open:
                arduino_nano_serial.close()
            arduino_nano_serial = serial.Serial(port=COM_PORT_SERIAL, baudrate=9600)
            return arduino_nano_serial
        except Exception as e:
            if (isinstance(e, serial.SerialException)):
                sleep(0.5)
                print("Tentando reconectar com Arduino Nano - Serial ...")
            else:
                print("[reconnect_arduino_nano_serial]: Outro erro: ", e.with_traceback)

def bluetooth_thread():
    global cycle, current_temp_reading, should_exit, rodeiro_is_locked
    min_temp = -1
    max_temp = -1

    while True:
        try:
            uno_msg = arduino_uno_bluetooth.readline()
            uno_msg = uno_msg.decode("utf-8").strip()
            if uno_msg:
                lock.acquire()
                if "Start" in uno_msg:
                    min_temp = current_temp_reading
                if "End" in uno_msg:
                    max_temp = current_temp_reading

                if min_temp != -1 and max_temp != -1:
                    cycle += 1
                    print(f"min_temp: {min_temp}, max_temp: {max_temp}, cycle: {cycle}")
                    min_temp = -1
                    max_temp = -1
                    arduino_uno_bluetooth.flush()
                print("Uno: ", uno_msg)
                lock.release()
        except Exception as e:
            if isinstance(e, ConnectionError):
                print("[Thread Arduino Uno] Conexao caiu... Tentando novamente")
            elif isinstance(e, serial.SerialException):
                print("[Thread Arduino Uno] ERRO CONEXAO SERIAL COM ARDUINO. TENTANDO NOVAMENTE")
                continue
            else:
                print("DEU ERRO ARDUINO UNO", e.with_traceback)
                should_exit = True
            
def monitor_trigger_time():
    global rodeiro_is_locked, arduino_uno
    while True:
        try:
            trigger_lock.acquire()
            if rodeiro_is_locked == True:
                arduino_uno.write("off".encode())
                sleep(5)
                arduino_uno.write("on".encode())
                rodeiro_is_locked = False
            trigger_lock.release()
        except Exception as e:
            print('Tentando reconectar com Arduino Uno', e)
            trigger_lock.release()
            continue

def test_serial_reading():
    thread_socket = threading.Thread(target=handle_socket)

    thread_bluetooth = threading.Thread(target=bluetooth_thread)
    thread_serial = threading.Thread(target=serial_thread)
    #thread_trigger_time = threading.Thread(target=monitor_trigger_time)

    thread_socket.start()

    thread_bluetooth.start()
    thread_serial.start()

    #thread_trigger_time.start()

test_serial_reading()