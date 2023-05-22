*** Settings ***
Documentation       Template keyword resource.

Library             RPA.HTTP
Library             RPA.Browser.Selenium
Library             RPA.JSON
Library             XML
Library             String
Library             RPA.Windows
Library             RPA.FileSystem
Library             OperatingSystem
Library             RPA.Tables
Library             DateTime
Variables           variables.py

*** Variables ***
${URL_CONNECTION}       https://portal-drp.green-sempapel.com.br/integrationserver/connection
${URL_GREEN}            https://portal-drp.green-sempapel.com.br/integrationserver/v1
${name}                 ${ID_NAME}

*** Keywords ***
Connection
    Create Session    token    ${URL_CONNECTION}
    ${headers}    Create Dictionary
    ...    X-IntegrationServer-Username=WATI
    ...    X-IntegrationServer-Password=Wat1$#@!

    ${RESPONSE}    GET On Session    token    url=${URL_CONNECTION}    headers=${headers}

    LOG    ${RESPONSE.headers}
    ${token}    Get value from JSON    ${RESPONSE.headers}    $..X-IntegrationServer-Session-Hash

    RETURN    ${token}

Document
    [Arguments]    ${token}    ${cdPaciente}    ${cdAtendimento}    ${nrConta}    ${pathMain}

    ${body_json}    Load JSON from file    ${pathMain}\\resources\\document.json
    ${name} =    ${ID_NAME}
    ${body_json}    Update value to JSON    ${body_json}    $..name      ${name}
    ${body_json}    Update value to JSON    ${body_json}    $..field1    ${cdPaciente}
    ${body_json}    Update value to JSON    ${body_json}    $..field2    ${cdAtendimento}
    ${body_json}    Update value to JSON    ${body_json}    $..field3    ${nrConta}

    Log    ${body_json}

    ${headers}    Create Dictionary
    ...    X-IntegrationServer-Session-Hash=${token}
    ...    Content-Type=application/json

    Create Session    document    ${URL_GREEN}
    ...    headers=${headers}

    ${RESPONSE}    POST On Session    document
    ...    /document
    ...    headers=${headers}
    ...    json=${body_json}

    ${location}    Get value from JSON    ${RESPONSE.headers}    $..Location
    ${ID_DOCUMENT}    Get Regexp Matches    ${location}    document/(.*)    1

    RETURN    ${ID_DOCUMENT}

Page
    [Arguments]    ${ID_DOCUMENT}    ${token}    ${nomePDF}    ${pathMain}

    Create Session    page    ${URL_GREEN}

    # ${DOC}    ${CURDIR}/robo/resources/${nomePDF}
    ${DOC}    ${pathMain}\\resources\\PDF\\${nomePDF}

    ${headers}    Create Dictionary
    ...    X-IntegrationServer-Session-Hash=${token}
    ...    X-IntegrationServer-Resource-Name=`${nomePDF}
    ...    Content-Type=application/octet-stream

    ${RESPONSE}    POST On Session    document
    ...    /${ID_DOCUMENT}/page
    ...    headers=${headers}
    ...    data=${DOC}

    RETURN    ${RESPONSE}

Integração WebService
    [Arguments]    ${cdPaciente}    ${cdAtendimento}    ${nrConta}    ${pathMain}
    # [Arguments]    ${nomePDF}    ${cdPaciente}    ${cdAtendimento}    ${nrConta}

    # ${token}    Connection
    # ${document}    Document    ${token}    ${cdPaciente}    ${cdAtendimento}    ${nrConta}    ${pathMain}
    
    # Verifica se existe apenas um arquivo na pasta
    ${files}    RPA.FileSystem.List Files In Directory    ${pathMain}\\resources\\PDF
    ${fileCount}    Get Length    ${files}

    IF    ${fileCount} != ${1}    Fail    Arquivo PDF não foi localizado

    ${files}    Convert To String    ${files}
    ${attrFile}    Split String    ${files}    ,
    ${fileName}    Replace String    ${attrFile}[1]    name='    ${EMPTY}
    ${fileName}    Replace String    ${fileName}    '    ${EMPTY}
    ${fileName}    Set Variable    ${fileName.strip()}

    ${date}    Get Current Date    result_format=%d-%m-%Y-%H:%M:%S
    # ${response}    Set Variable    Sucesso

    # Envia arquivo web service
    # ${response}    Page    ${document}    ${token}    ${fileName}    ${pathMain}
    # Log To Console   Resposta: ${response}

    # Cria novo registo
    # ${csvData}    Convert To String
    # ...    ${cdAtendimento},${cdPaciente},${nrConta},${fileName},${date},${response},Envia do com sucesso
    ${csvData}    Convert To String
    ...    ${cdAtendimento},${cdPaciente},${nrConta},${fileName},${date},sucesso,Envia do com sucesso

    # Verifica se já existe o arquivo RELATORIO_ENVIOS.csv
    ${createdCsv}    Run Keyword And Return Status    File Should Exist    ${pathMain}\\resources\\CSV\\RELATORIO_ENVIOS.csv

    # Cria arquivo se não existir
    IF    ${createdCsv} != ${True}
        RPA.FileSystem.Create File    ${pathMain}\\resources\\CSV\\RELATORIO_ENVIOS.csv
        RPA.FileSystem.Append To File
        ...    ${pathMain}\\resources\\CSV\\RELATORIO_ENVIOS.csv
        ...    cod_atendimento,cod_paciente,nr_conta,arquivo,data_envio,status_envio,msg_envio\n
    END

    # Adiciona novo registro ao arquivo
    RPA.FileSystem.Append To File    ${pathMain}\\resources\\CSV\\RELATORIO_ENVIOS.csv    ${csvData}\n
