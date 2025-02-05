## Sistema para automação de testes para pastilhas de freio

#### Esse repositório contém o código desenvolvido durante a iniciação científica na UFSC para testes de pastilhas de freio em um dinanômetro inercial. 

[Estrutura do Hardware](#estrutura-do-hardware)

[Estrutura do Software](#estrutura-do-software)

[Como utilizar](#como-utilizar)

## Estrutura do Hardware

#### Arduino Nano
Um Arduino Nano é responsável por obter a temperatura da pastilha de freio utilizando termopares com o módulo MAX-6675. Os dados da temperatura são enviados via Bluetooth por meio do módulo HC-05. Para alimentação, é utilizado uma fonte externa de 5V no Arduino Nano. Ressalta-se a importância de colocar um capacitor de desacoplamento de 0.1uF no MAX-6675 para filtragem de eventuais ruídos, conforme indicado em seu datasheet. A figura a seguir apresenta um diagrama das conexões envolvendo o Nano. O firmware presente no Arduino Nano está localizado em `/Nano/arduino_nano.ino`.

![NanoConnections](/assets/nano_connection.png)

#### Arduino Uno
Um Arduino Uno controla uma central hidráulica, responsável pelo acionamento do freio do rodeiro, e um inversor, que por sua vez controla o motor trifásico do sistema. Os acionamentos são realizados por meio de três relés, sendo um para o inversor e os outros dois para o acionamento da central e liberação/comutação da válvula da central. É utilizado uma fonte externa de 12V para alimentação do Arduino Uno.
As conexões elétrica envolvendo a central hidraulica, o inversor e o Arduino Uno estão indicadas na figura a seguir. O firmware está localizado em `/Uno/arduino_uno.ino`. 

![UnoConnections](/assets/uno_connection.jpeg)
(Créditos e agradecimento ao André Filipe Lambert Pereira pela construção desse ótimo esquemático e desenvolvimento das conexões elétricas)

É necessário a comunicação serial entre o Uno e o computador para a contagem dos ciclos e também para o acionamento/desativação do Arduino Uno remotamente, por meio de um aplicativo desenvolvido.

## Estrutura do Software

O aplicativo desenvolvido permite a visualização da temperatura em tempo real, visualizar as temperaturas mínimas e máximas de cada ciclo, realizar o download do CSV do teste atual e dos testes anteriores e frear o rodeiro em eventuais situações de emergências. 

O arquivo `main_backend.py` contém uma parte essencial da aplicação desenvolvida em Python. Esse código é o responsável por "coordenar" os dados do sistema, de modo que obtém os dados de temperatura do Arduino Nano e também a contagem dos ciclos e comunicação com o Arduino Uno.

O backend da aplicação foi desenvolvido em TypeScript com Express, utilizando MongoDB como banco de dados. Optou-se a escolha pelo MongoDB pois não há necessidade em possuir um banco de dados relacional, e também devido ao fato de que dessa forma os dados também estão salvos na nuvem. O script em Python mencionando anteriormente envia os dados de temperatura para o backend. Como há a necessidade de frear/acionar o rodeiro, existe uma conexão via socket entre o backend e o script em Python.

O frontend da aplicação foi desenvolvido em Dart, utilizando o framework Flutter. Como o Flutter possui capacidades multiplataforma, foi desenvolvido tanto um aplicativo desktop quanto um mobile. A figura a seguir apresenta a visualização dos dados no aplicativo.

![AppScreenshot](/assets/app_screenshot.png)

Como um dos requisitos do sistema é a visualização dos dados e controle do acionamento/desativação remotamente, foi utilizado o serviço *zrok*, que permite com que a API possa ser acessada publicamente, de modo que ao utilizar a URL gerada pelo *zrok*, o aplicativo pode ser acessado em qualquer lugar do mundo e não somente em *localhost*

## Como utilizar

Partindo do pressuposto de que todas as conexões estão feitas e os dois Arduinos devidamente alimentados, é necessario certificar-se que o Arduino Nano está conectado com o computador e que o Arduino Uno está conectado via USB com o computador. Após isso, siga os seguintes passos:

1. Clone o repositório
```
git clone https://github.com/lucas-bernardino/rodeiro.git
```

2. Entre na pasta 
```
cd rodeiro
```

3. Inicie o backend (Lembre-se de substituir as credencias do MongoDB e porta no arquivo .env, localizado no diretório `/api`)
```
cd api
npm run server
```

4. Com o backend rodando, inicie o script em Python. 
```
# Abra uma nova janela do terminal e entre na raiz do projeto (pasta rodeiro)
python main_backend.py
```
Caso apareça algum erro de comunicação serial, certifique-se de ajustar corretamente a porta serial utilizada pelo Arduino Uno e verifique a conexão via Bluetooth com o Arduino Nano.

5. Inicie o serviço de zrok com a API em uma nova janela do terminal.
```
# Substitua $PORT pela porta utilizada no .env
zrok share public $PORT
```
Após isso, copie a URL que será gerada. Ela será utilizada no arquivo .env no *client*

Até aqui, o servidor está rodando e os dados de temperatura estão sendo salvos no banco de dados. Para *buildar* o frontend, abra uma nova janela e siga os próximos passos. (Lembre-se que é necessário ter o Dart/Flutter devidamente instalados)
```
cd client

flutter pub get

# Supondo aplicativo para windows
flutter build windows 
```
Com isso, será gerado um executável em `build\windows\runner\Release`

