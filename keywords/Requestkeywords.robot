*** Settings ***
Library    RPA.HTTP
Library    RPA.Browser.Selenium
Library    RPA.JSON
Library    XML
Library    String
Library    RPA.Windows
Variables  variables.py


Documentation       Template keyword resource.

*** Variable ***
${URL_CONNECTION} =     https://portal-drp.green-sempapel.com.br/integrationserver/connection
${URL_GREEN}=           https://portal-drp.green-sempapel.com.br/integrationserver/v1
${name}=                ${ID_NAME}


*** Keywords ***
Connection
    Create Session    token    ${URL_CONNECTION}
    ${headers}=    Create Dictionary    
    ...    X-IntegrationServer-Username=WATI     
    ...    X-IntegrationServer-Password=Wat1$#@!    


    ${RESPONSE}=    GET On Session    token    url=${URL_CONNECTION}    headers=${headers} 

    LOG    ${RESPONSE.headers}
    ${token}=    Get value from JSON      ${RESPONSE.headers}    $..X-IntegrationServer-Session-Hash 

    RETURN    ${token}


Document
    [Arguments]     ${token}    ${cdPaciente}    ${cdAtendimento}    ${nrConta}

    ${body_json}    Load JSON from file      ${CURDIR}/resources/document.json
    ${name} =       ${ID_NAME}
    ${body_json}    Update value to JSON    ${body_json}    $..name      ${name}
    ${body_json}    Update value to JSON    ${body_json}    $..field1    ${cdPaciente}
    ${body_json}    Update value to JSON    ${body_json}    $..field2    ${cdAtendimento}
    ${body_json}    Update value to JSON    ${body_json}    $..field3    ${nrConta}

    Log    ${body_json}

    ${headers}=    Create Dictionary    
    ...    X-IntegrationServer-Session-Hash=${token}
    ...    Content-Type=application/json

    Create Session    document    ${URL_GREEN}
    ...            headers=${headers}

    ${RESPONSE}    POST On Session    document
    ...            /document
    ...            headers=${headers}
    ...            json=${body_json} 


    ${location}=    Get value from JSON      ${RESPONSE.headers}    $..Location
    ${ID_DOCUMENT} =	Get Regexp Matches	${location}    document/(.*)		1
    
    RETURN     ${ID_DOCUMENT}


Page
    [Arguments]    ${ID_DOCUMENT}       ${token}     ${nomePDF}

    Create Session    page    ${URL_GREEN}
    
    ${DOC}=    ${CURDIR}/robo/resources/${nomePDF}
    
    ${headers}=    Create Dictionary    
    ...    X-IntegrationServer-Session-Hash=${token}
    ...    X-IntegrationServer-Resource-Name=`${nomePDF}
    ...    Content-Type=application/octet-stream

    ${RESPONSE}    POST On Session    document    
    ...            /${ID_DOCUMENT}/page
    ...            headers=${headers}
    ...            data=${DOC}  

    RETURN      ${RESPONSE}  


 

Integração WebService
    [Arguments]    ${nomePDF}    ${cdPaciente}    ${cdAtendimento}    ${nrConta}
        ${token}=    Connection    
        ${document}=    Document    ${token}    ${cdPaciente}    ${cdAtendimento}    ${nrConta}
        Page    ${document}    ${token}     ${nomePDF}