import requests

rota = "http://localhost:3000"

def create():
    rodeiro = {
        "temp_init": 30,
        "temp_final": 50,
        "cycle": 2
    }
    req = requests.post(f"{rota}/send", json=rodeiro)
    print(req)

print(requests.get(f"{rota}/get").text)
