import requests

rota = "http://localhost:3000"

def create_highestlowest():
    rodeiro = {
        "temp_init": 4,
        "temp_final": 20,
        "cycle": 2
    }
    req = requests.post(f"{rota}/highestlowest", json=rodeiro)
    print(req)

def create_continuous():
    rodeiro = {
        "current_temp": 69,
        "cycle": 2
    }
    req = requests.post(f"{rota}/continuous", json=rodeiro)
    print(req)

def get_highestlowest():
    req = requests.get(f"{rota}/highestlowest")
    print(req.text)

def get_continuous():
    req = requests.get(f"{rota}/continuous")
    print(req.text)

# create_highestlowest()
# create_continuous()
# get_highestlowest()
# get_continuous()
