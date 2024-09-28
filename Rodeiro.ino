int inversor_pin = 8;  // Pino digital conectado ao relé de comando do motor/inversor
int acionar_k1_pin = 7;  // Pino digital conectado ao relé de comando de acionamento da central
int liberar_k2_pin = 6;  // Pino digital conectado ao relé de comando de liberação/comutação da válvula da central
int ciclo = 0;  // Contador de ciclos


void setup() {
  Serial.begin(9600);  // Iniciar leitura serial, definindo baudrate = 9600

  // Definindo todos os pinos de relé como OUTPUT (eles terão a função de enviar informação ao relé)
  pinMode(inversor_pin, OUTPUT);
  pinMode(acionar_k1_pin, OUTPUT);
  pinMode(liberar_k2_pin, OUTPUT);
}

void loop() {

  // Deixar ambos os comandos da central em seu estado padrão:
  digitalWrite(acionar_k1_pin, HIGH);  // Freio não acionado
  digitalWrite(liberar_k2_pin, LOW);  // Válvula comutada permitindo passagem do fluido (para permitir que a pastilha volte mais facilmente diminuindo a resistência)

  int value = analogRead(A4);  // Ler valor da tensão enviada pelo relé interno do inversor (deve estar em 5V até atingir a velocidade desejada, definida em P281 e P002) 
  float voltage = value*(5.0/1023.0);  // Converter o valor codificado em tensão real 

  Serial.println(voltage);  // Mostrar a tensão no leitor serial

  if(voltage < 4.90){  // Se a tensão estiver abaixo de 4,90 (compensa pela flutuação entre 5 e 4,90), então terá atingido a velocidade desejada e a frenagem deve ser iniciada

    if(ciclo == 0){  // Se estiver no primeiro ciclo, esperar por 5 min (300 s ou 300000 ms) para aquecer os rolamentos
      delay(300000);
    }

    // Desliga o motor comandando o relé do inversor e avisa no leitor serial
    digitalWrite(inversor_pin, HIGH);
    Serial.println("VELOCIDADE ATINGIDA, INICIANDO FRENAGEM");

    // Aciona o freio comandando o relé da válvula da central para impedir a liberação de pressão e comandando o relé de acionamento da central
    digitalWrite(liberar_k2_pin, HIGH);
    delay(500);  // Esperar um pouco antes de acionar
    digitalWrite(acionar_k1_pin, LOW);
    Serial.println("Central acionada");

    delay(500);  // Esperar meio segundo antes de tirar o acionamento (não é necessário muito tempo para que a pressão seja atingida)

    // Parar o acionamento (pressão será mantida)
    digitalWrite(acionar_k1_pin, HIGH);
    Serial.println("Central desacionada");

    delay(8000);  // Esperar 8 segundos para a frenagem ser realizada

    // Liberar a pressão (voltar ao estado padrão) comandando o relé que comanda a válvula da central
    digitalWrite(liberar_k2_pin, LOW);
    Serial.println("Central liberada");

    delay(8000);  // Esperar mais 8 segundos para garantir liberação total da pressão e reiniciar o ciclo

    // OPCIONAL: Comutar a válvula novamente para fechar a liberação de pressão
    //digitalWrite(liberar_k2_pin, HIGH);
    //Serial.println("Comandos resetados");

    ciclo = ciclo + 1;  // Acrescentar à contagem de ciclos

  }else{  // Se não tiver atingido a velocidade, manter o motor ligado até atingir
    digitalWrite(inversor_pin, LOW);
    Serial.println("ATINGINDO VELOCIDADE");
  }

  delay(200);

}
