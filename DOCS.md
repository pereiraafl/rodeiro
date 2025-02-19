# Verificando o funcionamento do sistema
---
# Case de cima
Responsável por obter a temperatura do termopar e enviá-la para o computador via serial. 

### Testando o hardware 
1. Ligue o multímetro e coloque na opção que aparece um símbolo do diodo.
2. Aperte o botão Func/Hold para aparecer um símbolo de onda no display.
3. Encoste as ponteiras do multímetro. Você deve ser capaz de escutar um *beep* ao tocá-las. 

Agora, você deve realizar o teste de continuidade entre o Arduino Uno e o MAX6675 (Módulo ligado ao termopar) com as seguintes conexões.

```
Arduino Uno                   MAX6675
5V                 ->          VCC
GND                ->          GND
PIN 2              ->          SCK
PIN 3              ->          CS
PIN 4              ->          SO
```

Com o teste de continuidade concluído, coloque o multímetro na opção 'V' e conecte o cabo USB entre o Arduino e o computador. Coloque a ponteira vermelha no VCC e a ponteira preta no GND do MAX6675. A leitura exibida no display do multímetro deve estar em torno de 4.5V a 5.5V. 

### Testando o software
Com o Arduino Uno conectado, abra o VS Code no computador e procure pelo arquivo chamado test.py
No código, estarão presentes as seguintes linhas:
``` 
# Testar bluetooth
#arduino = serial.Serial(port="COM8", baudrate=9600, timeout=10, parity=serial.PARITY_EVEN, stopbits=1)


# Testar serial
#arduino = serial.Serial(port="COM15", baudrate=9600, timeout=10)
```
Para testar a comunicação com o Arduino da temperatura, você deve remover o *#* da linha `#arduino = serial.Serial(port="COM15", baudrate=9600, timeout=10)`. Além disso,
abra o Gerenciador de Dispositivos no Windows e certifique-se de qual porta COM o Arduino está conectado. Caso seja um número diferente de COM15, mude para a porta correspondente no código.

Então, salve o arquivo (*Ctrl S*), abra o terminal (*Ctrl J*) e digite `python test.py`. A temperatura do termopar será exibida.

### Possíveis erros
1. Se ao rodar `python test.py` apareceu no terminal o erro `name arduino is not defined`, você provavelmente esqueceu de tirar o `#` mencionado anteriormente e de salvar o arquivo.
2. Se ao rodar `python test.py` apareceu no terminal o erro `serial.serialutil.SerialException: could not open port 'COM15': FileNotFoundError(2, 'O sistema não pode encontrar o arquivo especificado.', None, 2)`, isso provavelmente significa que a porta COM do código não é a mesma porta em que o Arduino está conectada. Para isso, abra o gerenciador de dispositivos e observe em qual porta COM o Arduino está conectado. Altere no código para a porta correta e tente novamente.
3. Se ao rodar `python test.py` ao invés de aparecer no terminal a temperatura do termopar está aparecendo `nan`, isso provavelmente é uma indicação de má conexão entrer o MAX6675 e o Arduino.
4. Se ao rodar `python test.py` aparece apenas `Conectado ao Arduino` mas nada mais é exibido além disso, isso provavelmente é um sinal de que a comunicação Serial entre o Arduino e o computador está comprometida. Para tentar resolver isso, feche o VS Code e abra a Arduino Ide. Na parte superior esquerda, selecione Arduino Uno com a porta COM previamente observada. Clique na seta apontando para a direita para dar upload no código. Caso no canto inferior direito fique apenas carregando o upload, sem exibir 'Done uploading', isso pode indicar algum problema no Arduino. Troque o Arduino e tente rodar o `python test.py` novamente.

# Case debaixo
Responsável por acionar os relés e enviar o *Start* e *End* via Bluetooth para o computador

### Testando o hardware

#### Testando relés

```
Arduino Uno                   RELÉS
5V                 ->          VCC
GND                ->          GND
PIN 7              ->          RELÉ K1
PIN 6              ->          RELÉ K2
PIN 8              ->          RELÉ INVERSOR
```

O Arduino envia o sinal de acionamento para os relés através dos pinos 6, 7 e 8. Primeiramente, verifique se eles estão devidamente conectados na placa de expansão. Você pode verificar o acionamento dos relés da seguinte forma:
    1. Com o inversor desligado, o Arduino deve enviar o comando para ficar ligando e desligando a central. Esse acionamento é feito pelos dois relés pretos presentes em um módulo. Verifique se ao acionar a desacionar a central, os LEDs do relé K1 e K2 estão acendendo e apagando. Caso uma delas nunca apague ou nunca acenda, isso pode indiciar um mau contato. Caso o K1 nunca acenda ou apague, verifique se há continuidade entre o jumper do pino IN1 do relé e o jumper do pino 7 do Arduino. De maneira análoga, realize o teste de continuidade entre o jumoer do pino IN2 do relé e o jumper do pino 6 do Arduino caso o problema seja no relé K2. Além disso, verifique se os terminais de VCC e GND do módulo do relé possuem uma leitura de 5V no display do multímetro ao colocá-lo na opção 'V', quando o Arduino está conectado com a fonte na tomada.
    2. Com o inversor ligado, verifique se o inversor está parando normalmente (exibindo o comando RDY ao frear). Caso isso não aconteça, isso pode indicar um problema com o relé do inversor. Faça os mesmos testes mencionados anteriormente, mas agora com o jumper do pino de sinal IN do relé e o jumper do pino 8 do Arduino.

#### Testando bluetooth
O Arduino se comunica com o módulo bluetooth (HC-05), que por sua vez envia o sinal da frenagem para o computador.

```
Arduino Uno                         HC-05
3.3V                   ->            VCC
GND                    ->            GND
PIN 11                 ->            RX
PIN 12                 ->            TX
```

Faça os testes de continuidade entre os pinos do HC-05 e o Arduino e verifique se o HC-05 está alimentado com uma tensão de 3.3V, com o Arduino conectado com a fonte na tomada.

### Testando o software
O teste de bluetooth é feito de maneira simular ao teste da serial. Para isso, abra o arquivo `test.py` onde estarão as seguintes linhas:
``` 
# Testar bluetooth
#arduino = serial.Serial(port="COM8", baudrate=9600, timeout=10, parity=serial.PARITY_EVEN, stopbits=1)


# Testar serial
#arduino = serial.Serial(port="COM15", baudrate=9600, timeout=10)
```
Para testar o bluetooth, remova o *#* da linha `#arduino = serial.Serial(port="COM8", baudrate=9600, timeout=10, parity=serial.PARITY_EVEN, stopbits=1)`. Em seguida, abra o gerenciador de dispositivos e verifque nas portas COM, qual é o maior valor da porta COM com bluetooth. Então, caso seja um número diferente, troque a porta COM no código. Não esqueça de salvar o arquivo com *Ctrl S*. Se ainda não estiver conectado no bluetooth, siga os seguintes passos:
    1. Certifique-se de que o módulo bluetooth no Arduino está piscando (deve haver alimentação e uma tensão de 3.3V entre os terminais do módulo)
    2. Abra as configurações do Windows em bluetooth e conecte no HC-05. Por algum motivo, aparecerão dois HC-05, e você deve clicar em esquecer as duas conexões e conectar somente naquele HC-05 que pedir uma senha. A senha será *1234*.
Então, rode o código, abrindo o terminal *Ctrl J* e digitando `python test.py`. Você deve visualizar o *Start* e *End* no terminal após cada frenagem. 

### Possíveis erros
1. Caso ocorra o erro `serial.serialutil.SerialException: could not open port 'COM15': FileNotFoundError(2, 'O sistema não pode encontrar o arquivo especificado.', None, 2)` isso pode indicar que o Bluetooth não está conectado corretamente. Dessa maneira, aba as configurações do bluetooth no Windows, e clique no botão de esquecer o HC-05 e tente conectar novamente. As vezes, tirar o Arduino da tomada e colocar novamente também ajuda.
2. 