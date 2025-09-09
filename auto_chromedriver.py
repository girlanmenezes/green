#!/usr/bin/env python3
"""
Script inteligente para detectar automaticamente a versão do Chrome
e baixar o ChromeDriver correspondente
"""

import os
import re
import requests
import zipfile
import subprocess
import shutil
from pathlib import Path

class AutoChromeDriverManager:
    def __init__(self, driver_path="C:\\chrome-win64"):
        self.driver_path = Path(driver_path)
        self.driver_path.mkdir(exist_ok=True)
        self.chromedriver_exe = self.driver_path / "chromedriver.exe"
        
    def get_chrome_version(self):
        """Detecta automaticamente a versão do Chrome instalado"""
        print("🔍 Detectando versão do Chrome...")
        
        chrome_paths = [
            r"C:\Program Files\Google\Chrome\Application\chrome.exe",
            r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
            r"C:\chrome-win64\chrome.exe"
        ]
        
        for chrome_path in chrome_paths:
            if os.path.exists(chrome_path):
                try:
                    result = subprocess.run(
                        [chrome_path, "--version"], 
                        capture_output=True, 
                        text=True, 
                        timeout=10
                    )
                    if result.returncode == 0:
                        version_match = re.search(r'(\d+\.\d+\.\d+\.\d+)', result.stdout)
                        if version_match:
                            version = version_match.group(1)
                            print(f"✅ Chrome encontrado: {version}")
                            return version
                except Exception as e:
                    print(f"⚠️ Erro ao verificar {chrome_path}: {e}")
                    continue
        
        print("❌ Chrome não encontrado nos caminhos padrão")
        return None
    
    def get_chromedriver_version(self):
        """Obtém a versão do ChromeDriver instalado"""
        if not self.chromedriver_exe.exists():
            return None
            
        try:
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
            print(f"⚠️ Erro ao obter versão do ChromeDriver: {e}")
            return None
    
    def find_compatible_chromedriver(self, chrome_version):
        """Encontra a versão do ChromeDriver compatível com o Chrome"""
        print(f"🔍 Buscando ChromeDriver compatível com Chrome {chrome_version}...")
        
        # Primeiro, tenta a versão exata
        if self._test_chromedriver_url(chrome_version):
            print(f"✅ Versão exata encontrada: {chrome_version}")
            return chrome_version
        
        # Se não encontrar, busca por versão principal
        major_version = chrome_version.split('.')[0]
        print(f"🔍 Versão exata não encontrada, buscando por versão principal {major_version}...")
        
        try:
            # API do Chrome for Testing
            url = "https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json"
            response = requests.get(url, timeout=30)
            response.raise_for_status()
            
            data = response.json()
            
            # Filtra versões compatíveis
            compatible_versions = []
            for version_info in data['versions']:
                version = version_info['version']
                if version.startswith(f"{major_version}."):
                    if 'downloads' in version_info and 'chromedriver' in version_info['downloads']:
                        for download in version_info['downloads']['chromedriver']:
                            if download['platform'] == 'win64':
                                compatible_versions.append(version)
                                break
            
            if compatible_versions:
                # Retorna a versão mais recente
                latest_version = max(compatible_versions, key=lambda x: [int(i) for i in x.split('.')])
                print(f"✅ Versão compatível encontrada: {latest_version}")
                return latest_version
            
            print(f"❌ Nenhuma versão compatível encontrada para Chrome {chrome_version}")
            return None
            
        except Exception as e:
            print(f"❌ Erro ao buscar versão compatível: {e}")
            return None
    
    def _test_chromedriver_url(self, version):
        """Testa se a URL do ChromeDriver existe"""
        try:
            url = f"https://storage.googleapis.com/chrome-for-testing-public/{version}/win64/chromedriver-win64.zip"
            response = requests.head(url, timeout=10)
            return response.status_code == 200
        except:
            return False
    
    def download_chromedriver(self, version):
        """Baixa o ChromeDriver para a versão especificada"""
        try:
            print(f"📥 Baixando ChromeDriver {version}...")
            
            url = f"https://storage.googleapis.com/chrome-for-testing-public/{version}/win64/chromedriver-win64.zip"
            zip_path = self.driver_path / "chromedriver.zip"
            
            response = requests.get(url, timeout=60)
            response.raise_for_status()
            
            with open(zip_path, 'wb') as f:
                f.write(response.content)
            
            print("📦 Extraindo arquivo...")
            with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                zip_ref.extractall(self.driver_path)
            
            # Move o chromedriver.exe
            extracted_path = self.driver_path / "chromedriver-win64" / "chromedriver.exe"
            if extracted_path.exists():
                # Remove versão anterior
                if self.chromedriver_exe.exists():
                    self.chromedriver_exe.unlink()
                
                shutil.move(str(extracted_path), str(self.chromedriver_exe))
                shutil.rmtree(self.driver_path / "chromedriver-win64")
                zip_path.unlink()
                
                print(f"✅ ChromeDriver {version} instalado com sucesso!")
                return True
            else:
                print("❌ Erro: chromedriver.exe não encontrado após extração")
                return False
                
        except Exception as e:
            print(f"❌ Erro ao baixar ChromeDriver: {e}")
            return False
    
    def auto_setup(self):
        """Configuração automática completa"""
        print("🚀 === Configuração Automática do ChromeDriver ===")
        
        # Detecta versão do Chrome
        chrome_version = self.get_chrome_version()
        if not chrome_version:
            print("❌ Não foi possível detectar a versão do Chrome")
            return False
        
        # Verifica versão atual do ChromeDriver
        current_chromedriver = self.get_chromedriver_version()
        if current_chromedriver:
            print(f"📋 ChromeDriver atual: {current_chromedriver}")
        
        # Encontra versão compatível
        compatible_version = self.find_compatible_chromedriver(chrome_version)
        if not compatible_version:
            print("❌ Não foi possível encontrar ChromeDriver compatível")
            return False
        
        # Verifica se precisa baixar
        if current_chromedriver != compatible_version:
            print(f"🔄 Atualizando ChromeDriver de {current_chromedriver} para {compatible_version}")
            return self.download_chromedriver(compatible_version)
        else:
            print("✅ ChromeDriver já está compatível!")
            return True

def main():
    manager = AutoChromeDriverManager()
    success = manager.auto_setup()
    
    if success:
        print("\n🎉 ChromeDriver configurado com sucesso!")
        print("Agora você pode executar seus testes Robot Framework.")
    else:
        print("\n💥 Falha na configuração do ChromeDriver")
        print("Verifique sua conexão com a internet e tente novamente.")
    
    input("\nPressione Enter para sair...")

if __name__ == "__main__":
    main()
