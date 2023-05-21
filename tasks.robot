*** Settings ***
Documentation       Green.

Library             Collections
# Library    DB
Resource            Keywords.robot
Resource            Requestkeywords.robot

*** Variables ***
${cdAtendimento}    67139
${cdPaciente}       ${EMPTY}
${nrConta}          7660

*** Tasks ***
# rcc run --task "Run RPA Green"
RPA Green
    # Download    ${PDF_URL}
    # Logar e acessar a tela - Foi utilizado o projeto de automação existente
    Logar e Acessar a tela

    #Realiza o download do relatorio
    # Download do relatorio    ${cdPaciente}    ${cdAtendimento}    ${nrConta}
    Download do relatorio    ${cdAtendimento}    ${cdPaciente}    ${nrConta}    ${CURDIR}\\resources\\PDF

    #Autentica serviço e realiza a requsição
    # Integração WebService    ${nomePDF}    ${cdPaciente}    ${cdAtendimento}    ${nrConta}
    # Integração WebService    ${cdPaciente}    ${cdAtendimento}    ${nrConta}