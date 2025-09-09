#!/usr/bin/env python3
"""
Script para corrigir incompatibilidade entre Chrome e ChromeDriver
Execute este script quando houver erro de versão incompatível
"""

import sys
import os

# Adiciona o diretório libraries ao path
sys.path.append(os.path.join(os.path.dirname(__file__), 'libraries'))

from ChromeDriverManager import ChromeDriverManager

def main():
    print("=== Corrigindo Incompatibilidade Chrome/ChromeDriver ===")
    print("Detectando versões e baixando ChromeDriver compatível...")
    
    # Cria o gerenciador
    manager = ChromeDriverManager()
    
    # Verifica e corrige compatibilidade
    success = manager.ensure_compatible_chromedriver()
    
    if success:
        print("\n✅ ChromeDriver compatível instalado com sucesso!")
        print("Agora você pode executar seus testes Robot Framework.")
        return 0
    else:
        print("\n❌ Erro ao corrigir compatibilidade do ChromeDriver")
        print("Verifique sua conexão com a internet e tente novamente.")
        return 1

if __name__ == "__main__":
    exit_code = main()
    input("\nPressione Enter para sair...")
    sys.exit(exit_code)
