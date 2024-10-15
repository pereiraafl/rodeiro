#include "max6675.h" // Biblioteca utilizada para o amplificador de sinal dos termopares

int thermoD0 = 4; // so
int thermoCS = 3;
int thermoCLK = 2; // sck

MAX6675 thermocouple(thermoCLK, thermoCS, thermoD0);


void setup() {
  Serial.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:

  float temp = thermocouple.readCelsius();

  Serial.println(temp);

  delay(200);
}