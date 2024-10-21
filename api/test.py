import requests

rota = "http://localhost:3000"

def create_highestlowest():
    for i in range(30): 
        rodeiro = {
            "temp_init": i + 10,
            "temp_final": i + 25,
            "cycle": i
        }
        req = requests.post(f"{rota}/highestlowest", json=rodeiro)
    print(req)

def create_continuous():
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



# create_highestlowest()
# create_continuous()
# get_highestlowest()
# get_continuous()

get_last_highestlowest()
get_last_continuous()
