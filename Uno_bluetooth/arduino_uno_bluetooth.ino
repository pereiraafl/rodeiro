#include <SoftwareSerial.h>
#include "max6675.h" // Biblioteca utilizada para o amplificador de sinal dos termopares
#include "LiquidCrystal_I2C.h" // Biblioteca da tela LCD
#include "Wire.h" // Biblioteca para realizar as comunicações com a tela LCD
int inversor_pin = 8; // Pino digital conectado ao relé de comando do motor/inversor
int acionar_k1_pin = 7; // Pino digital conectado ao relé de comando de acionamento da central
int liberar_k2_pin = 6; // Pino digital conectado ao relé de comando de liberação/comutação da válvula da central
int ciclo = 0; // Contador de ciclos
// Definindo o termopar e suas conexões
int thermoD0 = 3; // so
int thermoCS = 4;
int thermoCLK = 5; // sck

int RX = 12;
int TX = 11;

SoftwareSerial bluetooth(RX, TX); // RX, TX

float temp;

String pythonMessage = "";
bool rodeiroStatus = true;
bool doOnce = true;
bool offWithoutBreaking = false;

int cycle = 0;

void setup() {
  //Serial.begin(9600); // Iniciar leitura serial, definindo baudrate = 9600
  bluetooth.begin(9600);
  while (!bluetooth) {
  }
  // Definindo todos os pinos de relé como OUTPUT (eles terão a função de enviar informação ao relé)
  pinMode(inversor_pin, OUTPUT);
  pinMode(acionar_k1_pin, OUTPUT);
  pinMode(liberar_k2_pin, OUTPUT);
  digitalWrite(acionar_k1_pin, HIGH); // Freio não acionado
  digitalWrite(liberar_k2_pin, LOW);
}

void loop() {
  
    if (bluetooth.available()) {
      pythonMessage = bluetooth.readString();
      bluetooth.print("ECO: ");
      bluetooth.println(pythonMessage);   
      if (pythonMessage.indexOf("on") > -1) {
        rodeiroStatus = true;
      }
      if (pythonMessage.indexOf("off") > -1) {
        bluetooth.print("YYYYYYY");
        rodeiroStatus = false;
        doOnce = true;
        if (pythonMessage.startsWith("offWithoutBreaking")) {
          offWithoutBreaking = true;    
        }
      }
    }

    if (rodeiroStatus) {
      // Deixar ambos os comandos da central em seu estado padrão:
      digitalWrite(acionar_k1_pin, HIGH); // Freio não acionado
      digitalWrite(liberar_k2_pin, LOW); // Válvula comutada permitindo passagemdo fluido (para permitir que a pastilha volte mais facilmente diminuindo aresistência)
      int value = analogRead(A0); // Ler valor da tensão enviada pelo relé interno do inversor (deve estar em 5V até atingir a velocidade desejada, definida em P281 e P002)
      float voltage = value*(5.0/1023.0); // Converter o valor codificado em tensão real
      if(voltage < 4.5){ // Se a tensão estiver abaixo de 4,90 (compensa pela flutuação entre 5 e 4,90), então terá atingido a velocidade desejada e a frenagem deve ser iniciada
          // if(ciclo == 0){ // Se estiver no primeiro ciclo, esperar por 5 min (300 s ou 300000 ms) para aquecer os rolamentos
          //     // Mostrando na tela que está no período de aquecimento
          //     // Espera por 5 min
          //     delay(3000);
          // }
          digitalWrite(inversor_pin, HIGH); // Desliga o motor comandando o relé do inversor

          delay(100);
          // Aciona o freio comandando o relé da válvula da central para impedir a    liberação de pressão e comandando o relé de acionamento da central
          digitalWrite(liberar_k2_pin, HIGH);
          delay(100); // Esperar um pouco antes de acionar
          digitalWrite(acionar_k1_pin, LOW);
          //Serial.println("Central acionada");
          delay(500); // Esperar meio segundo antes de tirar o acionamento (não énecessário muito tempo para que a pressão seja atingida)
          // Parar o acionamento (pressão será mantida)
          digitalWrite(acionar_k1_pin, HIGH);

          long time_before_while = millis();

          // Serial.println("Start");
          bluetooth.println("Start");

          // Aguardar 8 segundos (dentro do while) para a frenagem ser realizada.
          while ((millis() - time_before_while) < 6000) {
              delay(150);
          }

          
          // Liberar a pressão (voltar ao estado padrão) comandando o relé que comanda a válvula da central
          digitalWrite(liberar_k2_pin, LOW);

          time_before_while = millis();

          // Aguardar mais 8 segundos dentro do while para garantir liberação total da pressão e reiniciar o ciclo
          while ((millis() - time_before_while) < 5000) {
              delay(150);
          }

          // Serial.println("End");
          bluetooth.println("End");

          cycle++;

          bluetooth.println(cycle);

          ciclo = ciclo + 1; // Acrescentar à contagem de ciclos
          } else { // Se não tiver atingido a velocidade, manter o motor ligado até atingir
          digitalWrite(inversor_pin, LOW);
          // Mostra a temperatura atual (neste caso, em tempo real) e o ciclo atual
      }
      delay(200); // Tempo necessário para leitura adequada do termopar
    } 
    if (!rodeiroStatus && doOnce) {
      digitalWrite(inversor_pin, HIGH); // Desliga o motor comandando o relé do inversor
      if (!offWithoutBreaking) {
        delay(500);
        // Aciona o freio comandando o relé da válvula da central para impedir a    liberação de pressão e comandando o relé de acionamento da central
        digitalWrite(liberar_k2_pin, HIGH);
        delay(500); // Esperar um pouco antes de acionar
        digitalWrite(acionar_k1_pin, LOW);
        //Serial.println("Central acionada");
        delay(500); // Esperar meio segundo antes de tirar o acionamento (não énecessário muito tempo para que a pressão seja atingida)
        // Parar o acionamento (pressão será mantida)
        digitalWrite(acionar_k1_pin, HIGH);
      } else {
        offWithoutBreaking = false;
      }
      doOnce = false;
    }
}