import os
import re
import requests
import zipfile
import subprocess
import json
from pathlib import Path
import shutil

class ChromeDriverManager:
    def __init__(self, driver_path="C:\\chrome-win64"):
        self.driver_path = Path(driver_path)
        self.driver_path.mkdir(exist_ok=True)
        self.chromedriver_exe = self.driver_path / "chromedriver.exe"
        
    def get_chrome_version(self):
        """Obtém a versão do Chrome instalado"""
        try:
            # Tenta diferentes caminhos do Chrome
            chrome_paths = [
                r"C:\Program Files\Google\Chrome\Application\chrome.exe",
                r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
                r"C:\chrome-win64\chrome.exe"
            ]
            
            for chrome_path in chrome_paths:
                if os.path.exists(chrome_path):
                    result = subprocess.run(
                        [chrome_path, "--version"], 
                        capture_output=True, 
                        text=True, 
                        timeout=10
                    )
                    if result.returncode == 0:
                        version_match = re.search(r'(\d+\.\d+\.\d+\.\d+)', result.stdout)
                        if version_match:
                            return version_match.group(1)
            
            print("Chrome não encontrado nos caminhos padrão")
            return None
            
        except Exception as e:
            print(f"Erro ao obter versão do Chrome: {e}")
            return None
    
    def get_chromedriver_version(self):
        """Obtém a versão do chromedriver instalado"""
        try:
            if not self.chromedriver_exe.exists():
                return None
                
            result = subprocess.run(
                [str(self.chromedriver_exe), "--version"], 
                capture_output=True, 
                text=True, 
                timeout=10
            )
            
            if result.returncode == 0:
                version_match = re.search(r'(\d+\.\d+\.\d+\.\d+)', result.stdout)
                if version_match:
                    return version_match.group(1)
            
            return None
            
        except Exception as e:
            print(f"Erro ao obter versão do chromedriver: {e}")
            return None
    
    def get_compatible_chromedriver_version(self, chrome_version):
        """Obtém a versão do chromedriver compatível com o Chrome"""
        try:
            # Extrai a versão principal do Chrome (ex: 139.0.7258.155 -> 139)
            major_version = chrome_version.split('.')[0]
            
            # API do Chrome for Testing para obter versões disponíveis
            url = f"https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json"
            
            response = requests.get(url, timeout=30)
            response.raise_for_status()
            
            data = response.json()
            
            # Filtra versões compatíveis com a versão principal do Chrome
            compatible_versions = []
            for version_info in data['versions']:
                version = version_info['version']
                if version.startswith(f"{major_version}."):
                    # Verifica se tem download para Windows
                    if 'downloads' in version_info and 'chromedriver' in version_info['downloads']:
                        for download in version_info['downloads']['chromedriver']:
                            if download['platform'] == 'win64':
                                compatible_versions.append(version)
                                break
            
            if compatible_versions:
                # Retorna a versão mais recente
                return max(compatible_versions, key=lambda x: [int(i) for i in x.split('.')])
            
            return None
            
        except Exception as e:
            print(f"Erro ao obter versão do chromedriver: {e}")
            return None
    
    def download_chromedriver(self, version):
        """Baixa o chromedriver para a versão especificada"""
        try:
            # URL para baixar o chromedriver
            url = f"https://storage.googleapis.com/chrome-for-testing-public/{version}/win64/chromedriver-win64.zip"
            
            print(f"Baixando chromedriver versão {version}...")
            response = requests.get(url, timeout=60)
            response.raise_for_status()
            
            # Salva o arquivo ZIP
            zip_path = self.driver_path / "chromedriver.zip"
            with open(zip_path, 'wb') as f:
                f.write(response.content)
            
            # Extrai o arquivo ZIP
            with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                zip_ref.extractall(self.driver_path)
            
            # Move o chromedriver.exe para o local correto
            extracted_path = self.driver_path / "chromedriver-win64" / "chromedriver.exe"
            if extracted_path.exists():
                # Remove versão anterior se existir
                if self.chromedriver_exe.exists():
                    self.chromedriver_exe.unlink()
                shutil.move(str(extracted_path), str(self.chromedriver_exe))
                # Remove a pasta extraída
                shutil.rmtree(self.driver_path / "chromedriver-win64")
            
            # Remove o arquivo ZIP
            zip_path.unlink()
            
            print(f"ChromeDriver {version} baixado com sucesso!")
            return True
            
        except Exception as e:
            print(f"Erro ao baixar chromedriver: {e}")
            return False
    
    def ensure_compatible_chromedriver(self):
        """Garante que o chromedriver é compatível com o Chrome"""
        try:
            print("Verificando compatibilidade entre Chrome e ChromeDriver...")
            
            # Obtém versão do Chrome
            chrome_version = self.get_chrome_version()
            if not chrome_version:
                print("Não foi possível obter a versão do Chrome")
                return False
            
            print(f"Versão do Chrome: {chrome_version}")
            
            # Obtém versão do chromedriver
            chromedriver_version = self.get_chromedriver_version()
            if chromedriver_version:
                print(f"Versão do ChromeDriver: {chromedriver_version}")
            else:
                print("ChromeDriver não encontrado")
            
            # Obtém versão compatível do chromedriver
            compatible_version = self.get_compatible_chromedriver_version(chrome_version)
            if not compatible_version:
                print("Não foi possível obter uma versão compatível do ChromeDriver")
                return False
            
            print(f"Versão compatível do ChromeDriver: {compatible_version}")
            
            # Verifica se precisa baixar/atualizar
            if chromedriver_version != compatible_version:
                print("Baixando ChromeDriver compatível...")
                if self.download_chromedriver(compatible_version):
                    print("ChromeDriver compatível baixado com sucesso!")
                    return True
                else:
                    print("Falha ao baixar ChromeDriver compatível")
                    return False
            else:
                print("ChromeDriver já está compatível!")
                return True
                
        except Exception as e:
            print(f"Erro ao verificar compatibilidade: {e}")
            return False

# Função para uso no Robot Framework
def ensure_compatible_chromedriver():
    """Função para ser chamada no Robot Framework"""
    manager = ChromeDriverManager()
    return manager.ensure_compatible_chromedriver()

if __name__ == "__main__":
    manager = ChromeDriverManager()
    manager.ensure_compatible_chromedriver()
