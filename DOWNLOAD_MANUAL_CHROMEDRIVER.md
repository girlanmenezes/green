# 📥 Download Manual do ChromeDriver

## 🎯 Instruções para Download Manual

### 1. **Identificar Versão do Chrome**
Execute no prompt de comando:
```cmd
"C:\Program Files\Google\Chrome\Application\chrome.exe" --version
```

### 2. **Baixar ChromeDriver Compatível**

#### **Opção A: Site Oficial**
1. Acesse: https://googlechromelabs.github.io/chrome-for-testing/
2. Procure pela versão do seu Chrome (ex: 139.0.7258.155)
3. Baixe o arquivo `chromedriver-win64.zip`

#### **Opção B: Download Direto**
Para Chrome 139.0.7258.155:
```
https://storage.googleapis.com/chrome-for-testing-public/139.0.7258.155/win64/chromedriver-win64.zip
```

### 3. **Instalar ChromeDriver**
1. Extraia o arquivo ZIP baixado
2. Copie `chromedriver.exe` para `C:\chrome-win64\`
3. Substitua o arquivo existente se houver

### 4. **Verificar Instalação**
Execute no prompt de comando:
```cmd
C:\chrome-win64\chromedriver.exe --version
```

Deve mostrar algo como:
```
ChromeDriver 139.0.7258.155
```

## ✅ Configuração Atual

O projeto está configurado para:
- **Chrome:** `C:\Program Files\Google\Chrome\Application\chrome.exe`
- **ChromeDriver:** `C:\chrome-win64\chromedriver.exe`
- **PATH:** Inclui ambos os diretórios

## 🔄 Quando Atualizar

Sempre que o Chrome for atualizado:
1. Verifique a nova versão do Chrome
2. Baixe o ChromeDriver correspondente
3. Substitua o arquivo em `C:\chrome-win64\`

## 📋 Exemplo Prático

Se seu Chrome for **139.0.7258.155**:
1. Baixe: `chromedriver-win64.zip` da versão 139.0.7258.155
2. Extraia e copie `chromedriver.exe` para `C:\chrome-win64\`
3. Execute seus testes Robot Framework normalmente

## 🎯 Resultado

Após o download manual, seus testes Robot Framework funcionarão sem verificações automáticas, usando o ChromeDriver que você instalou.
