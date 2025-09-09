# 🔧 Instruções para Corrigir ChromeDriver

## ❌ Problema Atual
```
SessionNotCreatedException: This version of ChromeDriver only supports Chrome version 140
Current browser version is 139.0.7258.155
```

## ✅ Solução Rápida

### Passo 1: Execute o Script Python
Abra o terminal/prompt de comando e execute:
```bash
python download_chromedriver_simple.py
```

### Passo 2: Verifique a Instalação
O script irá:
1. ✅ Baixar ChromeDriver versão 139.0.7258.155 (compatível com seu Chrome)
2. ✅ Instalar em `C:\chrome-win64\chromedriver.exe`
3. ✅ Verificar a versão instalada
4. ✅ Mostrar mensagem de sucesso

### Passo 3: Execute seus Testes
Após a instalação, execute seus testes Robot Framework normalmente.

## 🚀 Alternativa: Download Manual

Se o script não funcionar:

1. **Acesse:** https://storage.googleapis.com/chrome-for-testing-public/139.0.7258.155/win64/chromedriver-win64.zip

2. **Baixe o arquivo** `chromedriver-win64.zip`

3. **Extraia** o arquivo ZIP

4. **Copie** `chromedriver.exe` para `C:\chrome-win64\`

5. **Substitua** o arquivo existente

## 📋 Verificação

Para verificar se funcionou:
```bash
C:\chrome-win64\chromedriver.exe --version
```

Deve mostrar algo como:
```
ChromeDriver 139.0.7258.155
```

## 🔄 Solução Automática

Após corrigir manualmente, o sistema Robot Framework irá:
- ✅ Detectar automaticamente a versão correta
- ✅ Verificar compatibilidade antes de cada execução
- ✅ Baixar automaticamente se necessário no futuro

## 📁 Arquivos Criados

- `download_chromedriver_simple.py` - Script de correção
- `download_chromedriver.ps1` - Script PowerShell alternativo
- `libraries/ChromeDriverManager.py` - Gerenciador automático

## ⚡ Execução Imediata

**Execute agora:**
```bash
python download_chromedriver_simple.py
```

Isso resolverá o problema imediatamente! 🎯
