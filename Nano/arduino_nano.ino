#include "max6675.h" // Biblioteca utilizada para o amplificador de sinal dos termopares
#include <SoftwareSerial.h>

int RX = 10;
int TX = 11;

int thermoD0 = 4; // so
int thermoCS = 3;
int thermoCLK = 2; // sck

MAX6675 thermocouple(thermoCLK, thermoCS, thermoD0);
SoftwareSerial bt(RX, TX);

void setup() {
  Serial.begin(9600);
  bt.begin(9600);
}

void loop() {
  // put your main code here, to run repeatedly:

  float temp = thermocouple.readCelsius();

  //Serial.println(temp);
  bt.println(temp);

  delay(200);
}

