# README for the robot

Robo de download de relatorio e integração com o sistema Green

## Development guide

Execute o robô localmente:

Instruções para instalar o RCC [RCC docs] (https://github.com/robocorp/rcc#installing-rcc-from-command-line)

- Open the command prompt
- Download: curl -o rcc.exe https://downloads.robocorp.com/rcc/releases/latest/windows64/rcc.exe
- Add to system path: Open Start -> Edit the system environment variables
- Test: rcc


Execução dos testes
```
rcc run --task "Run RPA Green"
```

- `devdata`: Um local para todos os dados/materiais relacionados ao desenvolvimento, por exemplo, dados de teste. Não coloque nenhum dado sensível aqui!
- `keywords`: Keyword de davegação no sistema extraido do projeto de automação padrão.
- `libraries`: código da biblioteca Python com a conexão com o banco de dados.
- `Requestkeywords`: Integração com a aplicação Green
- `resources`: Defina seus recursos em um local centralizado. Por exemplo, as variáveis ​​do robô podem ser definidas aqui.
- `conda.yaml`: Arquivo de configuração do ambiente.
- `robot.yaml`: Arquivo de configuração do robô.
- `tasks.robot`: Conjunto de tarefas do Robot Framework - definição de processo de alto nível.


### Configuration

### Additional documentation

See [Robocorp Docs](https://robocorp.com/docs/) for more documentation.
