# Script PowerShell para baixar ChromeDriver compatível com Chrome 139
Write-Host "=== Baixando ChromeDriver Compatível com Chrome 139 ===" -ForegroundColor Green

# Cria diretório se não existir
$driverPath = "C:\chrome-win64"
if (!(Test-Path $driverPath)) {
    New-Item -ItemType Directory -Path $driverPath -Force
    Write-Host "Diretório criado: $driverPath" -ForegroundColor Yellow
}

# URL do ChromeDriver para Chrome 139 (versão mais recente compatível)
$chromeDriverUrl = "https://storage.googleapis.com/chrome-for-testing-public/139.0.7258.155/win64/chromedriver-win64.zip"
$zipPath = "$driverPath\chromedriver.zip"

Write-Host "Baixando ChromeDriver 139.0.7258.155..." -ForegroundColor Cyan

try {
    # Baixa o arquivo
    Invoke-WebRequest -Uri $chromeDriverUrl -OutFile $zipPath -UseBasicParsing
    Write-Host "Download concluído!" -ForegroundColor Green
    
    # Extrai o arquivo
    Write-Host "Extraindo arquivo..." -ForegroundColor Cyan
    Expand-Archive -Path $zipPath -DestinationPath $driverPath -Force
    
    # Move o chromedriver.exe para o local correto
    $extractedPath = "$driverPath\chromedriver-win64\chromedriver.exe"
    if (Test-Path $extractedPath) {
        # Remove versão anterior se existir
        $targetPath = "$driverPath\chromedriver.exe"
        if (Test-Path $targetPath) {
            Remove-Item $targetPath -Force
        }
        
        Move-Item $extractedPath $targetPath -Force
        
        # Remove pasta extraída
        Remove-Item "$driverPath\chromedriver-win64" -Recurse -Force
        
        # Remove arquivo ZIP
        Remove-Item $zipPath -Force
        
        Write-Host "ChromeDriver instalado com sucesso em: $targetPath" -ForegroundColor Green
        
        # Verifica a versão
        $version = & "$targetPath" --version
        Write-Host "Versão instalada: $version" -ForegroundColor Green
        
    } else {
        Write-Host "Erro: Arquivo chromedriver.exe não encontrado após extração" -ForegroundColor Red
    }
    
} catch {
    Write-Host "Erro ao baixar ChromeDriver: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Tentando URL alternativa..." -ForegroundColor Yellow
    
    # URL alternativa para Chrome 139
    $altUrl = "https://storage.googleapis.com/chrome-for-testing-public/139.0.7258.155/win64/chromedriver-win64.zip"
    try {
        Invoke-WebRequest -Uri $altUrl -OutFile $zipPath -UseBasicParsing
        Write-Host "Download alternativo concluído!" -ForegroundColor Green
        
        # Extrai o arquivo
        Expand-Archive -Path $zipPath -DestinationPath $driverPath -Force
        
        # Move o chromedriver.exe
        $extractedPath = "$driverPath\chromedriver-win64\chromedriver.exe"
        if (Test-Path $extractedPath) {
            $targetPath = "$driverPath\chromedriver.exe"
            if (Test-Path $targetPath) {
                Remove-Item $targetPath -Force
            }
            Move-Item $extractedPath $targetPath -Force
            Remove-Item "$driverPath\chromedriver-win64" -Recurse -Force
            Remove-Item $zipPath -Force
            
            Write-Host "ChromeDriver instalado com sucesso!" -ForegroundColor Green
            $version = & "$targetPath" --version
            Write-Host "Versão: $version" -ForegroundColor Green
        }
    } catch {
        Write-Host "Erro no download alternativo: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nPressione qualquer tecla para continuar..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
