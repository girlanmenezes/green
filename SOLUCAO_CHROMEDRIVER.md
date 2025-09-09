# Solução para Incompatibilidade Chrome/ChromeDriver

## Problema
```
SessionNotCreatedException: Message: session not created: This version of ChromeDriver only supports Chrome version 140
Current browser version is 139.0.7258.155
```

## Solução Automática

### Opção 1: Executar Script Python
```bash
python fix_chromedriver.py
```

### Opção 2: Executar Manualmente
```bash
python libraries/ChromeDriverManager.py
```

## Solução Manual

### 1. Baixar ChromeDriver Compatível
- Acesse: https://googlechromelabs.github.io/chrome-for-testing/
- Procure pela versão **139.x.x.x** (compatível com seu Chrome 139.0.7258.155)
- Baixe o arquivo `chromedriver-win64.zip`

### 2. Instalar ChromeDriver
1. Extraia o arquivo ZIP
2. Copie `chromedriver.exe` para `C:\chrome-win64\`
3. Substitua o arquivo existente

### 3. Verificar Instalação
```bash
C:\chrome-win64\chromedriver.exe --version
```

## Solução Automática no Robot Framework

O sistema agora verifica automaticamente a compatibilidade antes de abrir o navegador:

1. **Detecta a versão do Chrome** (139.0.7258.155)
2. **Busca ChromeDriver compatível** (139.x.x.x)
3. **Baixa automaticamente** se necessário
4. **Instala no diretório correto** (C:\chrome-win64\)

## Arquivos Criados

- `libraries/ChromeDriverManager.py` - Gerenciador automático
- `fix_chromedriver.py` - Script de correção
- Keyword `Verificar Compatibilidade ChromeDriver` - Integração com Robot Framework

## Como Funciona

1. **Detecção**: Identifica versão do Chrome instalado
2. **Busca**: Procura versão compatível do ChromeDriver
3. **Download**: Baixa automaticamente da API oficial
4. **Instalação**: Extrai e instala no local correto
5. **Verificação**: Confirma compatibilidade

## Logs Esperados

```
Verificando compatibilidade entre Chrome e ChromeDriver...
Versão do Chrome: 139.0.7258.155
Versão do ChromeDriver: 140.0.xxxx.xxxx
Versão compatível do ChromeDriver: 139.0.xxxx.xxxx
Baixando ChromeDriver compatível...
ChromeDriver 139.0.xxxx.xxxx baixado com sucesso!
ChromeDriver compatível verificado com sucesso!
```

## Próximos Passos

1. Execute o script de correção
2. Execute seus testes Robot Framework
3. O sistema funcionará automaticamente

## Troubleshooting

### Se o script não funcionar:
1. Verifique conexão com internet
2. Execute como administrador
3. Verifique permissões da pasta C:\chrome-win64\

### Se ainda houver erro:
1. Delete o arquivo chromedriver.exe atual
2. Execute o script novamente
3. Verifique se o Chrome está atualizado
