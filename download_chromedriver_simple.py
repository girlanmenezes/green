#!/usr/bin/env python3
"""
Script simples para baixar ChromeDriver compatível com Chrome 139
"""

import os
import requests
import zipfile
import shutil
from pathlib import Path

def get_chrome_version():
    """Detecta automaticamente a versão do Chrome"""
    import subprocess
    
    chrome_paths = [
        r"C:\Program Files\Google\Chrome\Application\chrome.exe",
        r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    ]
    
    for chrome_path in chrome_paths:
        if os.path.exists(chrome_path):
            try:
                result = subprocess.run([chrome_path, "--version"], 
                                      capture_output=True, text=True, timeout=10)
                if result.returncode == 0:
                    import re
                    version_match = re.search(r'(\d+\.\d+\.\d+\.\d+)', result.stdout)
                    if version_match:
                        return version_match.group(1)
            except:
                continue
    return None

def download_chromedriver():
    print("=== Detecção Automática e Download do ChromeDriver ===")
    
    # Detecta versão do Chrome
    chrome_version = get_chrome_version()
    if not chrome_version:
        print("❌ Não foi possível detectar a versão do Chrome")
        return False
    
    print(f"✅ Chrome detectado: {chrome_version}")
    
    # Cria diretório se não existir
    driver_path = Path("C:/chrome-win64")
    driver_path.mkdir(exist_ok=True)
    
    # URL do ChromeDriver baseada na versão detectada
    url = f"https://storage.googleapis.com/chrome-for-testing-public/{chrome_version}/win64/chromedriver-win64.zip"
    zip_path = driver_path / "chromedriver.zip"
    
    print(f"📥 Baixando ChromeDriver {chrome_version}...")
    print(f"URL: {url}")
    
    try:
        # Baixa o arquivo
        response = requests.get(url, timeout=60)
        response.raise_for_status()
        
        with open(zip_path, 'wb') as f:
            f.write(response.content)
        
        print("Download concluído!")
        
        # Extrai o arquivo
        print("Extraindo arquivo...")
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(driver_path)
        
        # Move o chromedriver.exe para o local correto
        extracted_path = driver_path / "chromedriver-win64" / "chromedriver.exe"
        target_path = driver_path / "chromedriver.exe"
        
        if extracted_path.exists():
            # Remove versão anterior se existir
            if target_path.exists():
                target_path.unlink()
            
            # Move o arquivo
            shutil.move(str(extracted_path), str(target_path))
            
            # Remove pasta extraída
            shutil.rmtree(driver_path / "chromedriver-win64")
            
            # Remove arquivo ZIP
            zip_path.unlink()
            
            print(f"✅ ChromeDriver instalado com sucesso em: {target_path}")
            
            # Verifica a versão
            import subprocess
            try:
                result = subprocess.run([str(target_path), "--version"], 
                                      capture_output=True, text=True, timeout=10)
                if result.returncode == 0:
                    print(f"✅ Versão instalada: {result.stdout.strip()}")
                else:
                    print("⚠️ Não foi possível verificar a versão")
            except Exception as e:
                print(f"⚠️ Erro ao verificar versão: {e}")
            
            return True
        else:
            print("❌ Erro: chromedriver.exe não encontrado após extração")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Erro de rede: {e}")
        return False
    except Exception as e:
        print(f"❌ Erro geral: {e}")
        return False

if __name__ == "__main__":
    success = download_chromedriver()
    
    if success:
        print("\n🎉 ChromeDriver compatível instalado com sucesso!")
        print("Agora você pode executar seus testes Robot Framework.")
    else:
        print("\n💥 Falha ao instalar ChromeDriver")
        print("Verifique sua conexão com a internet e tente novamente.")
    
    input("\nPressione Enter para sair...")
