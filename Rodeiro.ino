int inversor_pin = 8;
int acionar_k1_pin = 7;
int liberar_k2_pin = 6;
int ciclo = 0;


void setup() {
  Serial.begin(9600);
  pinMode(inversor_pin, OUTPUT);
  pinMode(acionar_k1_pin, OUTPUT);
  pinMode(liberar_k2_pin, OUTPUT);
}

void loop() {

  digitalWrite(acionar_k1_pin, HIGH);
  digitalWrite(liberar_k2_pin, HIGH);

  int value = analogRead(A4);
  float voltage = value*(5.0/1023.0);

  Serial.println(voltage);

  if(voltage < 4.90){

    if(ciclo == 0){
      delay(300000);
    }

    digitalWrite(inversor_pin, HIGH);
    Serial.println("VELOCIDADE ATINGIDA, INICIANDO FRENAGEM");

    digitalWrite(acionar_k1_pin, LOW);
    Serial.println("Central acionada");

    delay(500);

    digitalWrite(acionar_k1_pin, HIGH);
    Serial.println("Central desacionada");

    delay(15000);

    digitalWrite(liberar_k2_pin, LOW);
    Serial.println("Central liberada");

    delay(8000);

    digitalWrite(liberar_k2_pin, HIGH);
    Serial.println("Comandos resetados");

    ciclo = ciclo + 1;

  }else{
    digitalWrite(inversor_pin, LOW);
    Serial.println("ATINGINDO VELOCIDADE");
  }

  delay(200);

}
