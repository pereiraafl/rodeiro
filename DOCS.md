# Verificando o funcionamento do sistema
---
# Case de cima
Responsável por obter a temperatura do termopar e enviá-la para o computador via serial. 

### Testando o hardware. 
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

