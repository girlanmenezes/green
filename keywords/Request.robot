*** Settings ***
Documentation       Busca dados RPA

Library             RPA.HTTP
Library             RPA.JSON

*** Keywords ***
Connection Token
    Create Session    tokenS    http://192.168.57.80

    ${body_json}    Create Dictionary
    ...    username=admin
    ...    password=admin
    
    ${headers}    Create Dictionary
    ...    content-type=application/x-www-form-urlencoded
        
    ${RESPONSE}    POST On Session    tokenS
    ...    /token
    ...    headers=${headers}
    ...    data=${body_json}

    ${token}    Get value from JSON    ${RESPONSE.json()}    $..access_token
    
    Request Should Be Successful
    Status Should Be    200

    RETURN    ${token}


Busca Dados RPA
    [Arguments]    ${token}
    Create Session    tokenS    http://192.168.57.80

    ${headers}    Create Dictionary
    ...    Authorization=Bearer ${token}
        
    ${RESPONSE}    GET On Session    tokenS
    ...    /dados
    ...    headers=${headers}

    Log    ${RESPONSE.json()}

    Request Should Be Successful
    Status Should Be    200

    ${SENHA}    Get value from JSON    ${RESPONSE.json()}    $..senha
    ${URL_AMBIENTE}    Get value from JSON    ${RESPONSE.json()}    $..url
    ${DIAS_RETROATIVOS}    Get value from JSON    ${RESPONSE.json()}    $..diasRetroativo
    ${USER}    Get value from JSON    ${RESPONSE.json()}    $..usuario

    Set Global Variable     ${SENHA}      ${SENHA} 
    Set Global Variable     ${URL_AMBIENTE}      ${URL_AMBIENTE} 
    Set Global Variable     ${DIAS_RETROATIVOS}      ${DIAS_RETROATIVOS} 
    Set Global Variable     ${USER}      ${USER}  



Get info
    TRY
        ${token}=    Connection Token
        Busca Dados RPA    ${token}
    EXCEPT
        RETURN    FAILD
    END
