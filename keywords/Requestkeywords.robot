*** Settings ***
Documentation       Template keyword resource.

Library             RPA.HTTP
Library             RPA.Browser.Selenium
Library             RPA.JSON
Library             XML
Library             RPA.Windows
Library             OperatingSystem
Library             DateTime
Variables           variables.py

Resource            Pdf.robot
Resource            LogCsv.robot

*** Variables ***
${URL_CONNECTION}       https://portal-drp.green-sempapel.com.br/integrationserver/connection
${URL_GREEN}            https://portal-drp.green-sempapel.com.br/integrationserver/v1


*** Keywords ***
Connection
    Create Session    token    ${URL_CONNECTION}
    ${headers}    Create Dictionary
    ...    X-IntegrationServer-Username=WATI
    ...    X-IntegrationServer-Password=Wat1$#@!

    ${RESPONSE}    GET On Session    token    url=${URL_CONNECTION}    headers=${headers}

    LOG    ${RESPONSE.headers}

    Request Should Be Successful
    Status Should Be    200

    ${token}    Get value from JSON    ${RESPONSE.headers}    $..X-IntegrationServer-Session-Hash

    RETURN    ${token}

Document
    [Arguments]    ${token}    ${cdPaciente}    ${cdAtendimento}    ${nrConta}    ${pathMain}

    ${body_json}    Load JSON from file    ${pathMain}\\resources\\document.json
    ${name}    Set Variable    ${ID_NAME}
    ${body_json}    Update value to JSON    ${body_json}    $..name    ${name}
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
    
    Request Should Be Successful
    Status Should Be    201

    ${location}    Get value from JSON    ${RESPONSE.headers}    $..Location
    ${ARR_ID_DOCUMENT}    Get Regexp Matches    ${location}    document/(.*)    1
    ${ID_DOCUMENT}    Set Variable    ${ARR_ID_DOCUMENT}[0]

    RETURN    ${ID_DOCUMENT}

Page
    [Arguments]    ${ID_DOCUMENT}    ${token}    ${nomePDF}    ${pathMain}

    Create Session    page    ${URL_GREEN}

    # ${DOC}    ${CURDIR}/robo/resources/${nomePDF}
    ${DOC}    Set Variable    ${pathMain}\\resources\\PDF\\${nomePDF}

    ${headers}    Create Dictionary
    ...    X-IntegrationServer-Session-Hash=${token}
    ...    X-IntegrationServer-Resource-Name=${nomePDF}
    ...    Content-Type=application/octet-stream

    ${RESPONSE}    POST On Session    document
    ...    document/${ID_DOCUMENT}/page
    ...    headers=${headers}
    ...    data=${DOC} 

    ${validateStatus}    Run Keyword And Return Status    Request Should Be Successful
    ${validateCode}    Run Keyword And Return Status    Status Should Be    201

    IF    (${validateStatus} and ${validateCode}) == ${True}
        Log CSV    ${cdPaciente}    ${cdAtendimento}    ${nrConta}    ${nomePDF}    ${pathMain}\\resources\\CSV    ${True}
    ELSE
        Log CSV    ${cdPaciente}    ${cdAtendimento}    ${nrConta}    ${nomePDF}    ${pathMain}\\resources\\CSV    ${False}
    END

    Log    

    # IF    (${validateStatus} and ${validateCode}) == ${True}
    #     Log CSV    ${cdPaciente}    ${cdAtendimento}    ${nrConta}    ${nomePDF}    C:\\Users\\server-thiago\\Documents\\WATI\\MV\\Automacoes\\RPA\\green\\resources\\CSV    ${True}
    # ELSE
    #     Log CSV    ${cdPaciente}    ${cdAtendimento}    ${nrConta}    ${nomePDF}    C:\\Users\\server-thiago\\Documents\\WATI\\MV\\Automacoes\\RPA\\green\\resources\\CSV   ${False} 
    # END

    RETURN    ${RESPONSE}

Integração WebService
    [Arguments]    ${cdPaciente}    ${cdAtendimento}    ${nrConta}    ${pathMain}

    Set Suite Variable    ${cdPaciente}    ${cdPaciente}
    Set Suite Variable    ${cdAtendimento}    ${cdAtendimento}
    Set Suite Variable    ${nrConta}    ${nrConta}

    # Conecta web service
    ${token}    Connection
    # Cria document JSON
    ${document}    Document    ${token}    ${cdPaciente}    ${cdAtendimento}    ${nrConta}    ${pathMain}
    # Obtem nome do arquivo PDF
    ${fileName}    Pdf.Get File Name    ${pathMain}\\resources\\PDF
    # Envia arquivo web service
    ${response}    Page    ${document}    ${token}    ${fileName}    ${pathMain}