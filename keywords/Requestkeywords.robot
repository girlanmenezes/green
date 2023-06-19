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
Resource            Keywords.robot

Resource            Pdf.robot
Resource            LogCsv.robot

*** Variables ***
#${URL_CONNECTION}       https://portal-drp.green-sempapel.com.br/integrationserver/connection
#${URL_GREEN}            https://portal-drp.green-sempapel.com.br/integrationserver/v1

${URL_CONNECTION}       https://greenh9j.adhosp.com.br/integrationserver/connection
${URL_GREEN}            https://greenh9j.adhosp.com.br/integrationserver/v1




*** Keywords ***
Connection
    Run Keyword And Ignore Error    Delete All Sessions
    Log To Console    Request Connection
    Create Session    token    ${URL_CONNECTION}
    ${headers}    Create Dictionary
    ...    X-IntegrationServer-Username=REMESSADIGITAL
    ...    X-IntegrationServer-Password=Green@2022

    ${RESPONSE}    GET On Session    token    url=${URL_CONNECTION}    headers=${headers} 

    LOG    ${RESPONSE.headers}

    Request Should Be Successful
    Status Should Be    200

    ${token}    Get value from JSON    ${RESPONSE.headers}    $..X-IntegrationServer-Session-Hash

    RETURN    ${token}

Document
    [Arguments]    ${token}      ${cdAtendimento}    ${nrConta}    ${pathMain}
    Log To Console    Request Document
    ${body_json}    Load JSON from file    ${pathMain}\\resources\\document.json
    ${uuid}    Evaluate    uuid.uuid4()    modules=uuid
    ${name}    Set Variable    ${uuid}
    ${body_json}    Update value to JSON    ${body_json}    $..name      ${name}
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
    Log To Console    Request Page
    Create Session    page    ${URL_GREEN} 

    ${DOC}=    Get File For Streaming Upload    ${pathMain}\\resources\\PDF\\${nomePDF}
    #${DOC}=    Create Dictionary    file    ${file}   

    # ${DOC}    ${CURDIR}/robo/resources/${nomePDF}
    #${DOC}    Set Variable    ${pathMain}\\resources\\PDF\\${nomePDF}
    
    ${headers}    Create Dictionary
    ...    X-IntegrationServer-Session-Hash=${token}
    ...    X-IntegrationServer-Resource-Name=${nomePDF}
    ...    Content-Type=application/octet-stream

    ${RESPONSE}    POST On Session    document
    ...    document/${ID_DOCUMENT}/page
    ...    headers=${headers}
    ...    data=${DOC} 


    RETURN    ${RESPONSE}



WorkflowItem
    [Arguments]    ${document}    ${token}    ${pathMain}    ${cdAtendimento}    ${nrConta}    ${nomePDF}    ${pathCSV}
    Log To Console    Request WorkFlow
    
    ${body_json}    Load JSON from file    ${pathMain}\\resources\\work.json
    ${body_json}    Update value to JSON    ${body_json}    $..objectId      ${document}

    Log    ${body_json}

    ${headers}    Create Dictionary
    ...    X-IntegrationServer-Session-Hash=${token}
    ...    Content-Type=application/json

    Create Session    document    ${URL_GREEN}
    ...    headers=${headers}

    ${RESPONSE}    POST On Session    document
    ...    /workflowItem
    ...    headers=${headers}
    ...    json=${body_json}
    
    ${validateStatus}    Run Keyword And Return Status    Request Should Be Successful
    ${validateCode}    Run Keyword And Return Status    Status Should Be    201

    IF    (${validateStatus} and ${validateCode}) == ${True}
        Log CSV     ${cdAtendimento}    ${nrConta}    ${nomePDF}    ${pathCSV}    ${True}
        Log To Console    Integração foi realizada
    ELSE
        Log    Integração não foi realizada
    END



Integração WebService
    [Arguments]    ${cdAtendimento}    ${nrConta}    ${pathMain}    ${pathCSV}

    TRY
        # Conecta web service
        ${token}    Connection
        # Cria document JSON
        ${document}    Document    ${token}    ${cdAtendimento}    ${nrConta}    ${pathMain}

        ${date}    Get Current Date    result_format=%d-%m-%Y-%H:%M:%S

        # Obtem nome do arquivo PDF
        ${fileName}    Pdf.Get File Name    ${pathMain}\\resources\\PDF

        # Envia arquivo web service
        ${response}    Page    ${document}    ${token}    ${fileName}    ${pathMain}

        WorkflowItem    ${document}    ${token}    ${pathMain}    ${cdAtendimento}    ${nrConta}    ${fileName}    ${pathCSV}

    EXCEPT
        Log     Falha ao integrar Green
        RETURN    FAILD
    END
