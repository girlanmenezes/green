*** Settings ***
Documentation       Busca dados RPA

Library             RPA.HTTP
Library             RPA.JSON

*** Variable ***
${URL_RPA}    http://192.168.57.80

*** Keywords ***
Connection Token
    Create Session    tokenS    ${URL_RPA}

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
    Create Session    tokenS    ${URL_RPA}

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
    ${RPA_NAME}    Get value from JSON    ${RESPONSE.json()}    $..roboName

    Set Global Variable     ${SENHA}      ${SENHA} 
    Set Global Variable     ${URL_AMBIENTE}      ${URL_AMBIENTE} 
    Set Global Variable     ${DIAS_RETROATIVOS}      ${DIAS_RETROATIVOS} 
    Set Global Variable     ${USER}      ${USER}  
    Set Global Variable     ${RPA_NAME}      ${RPA_NAME}


Get info
    TRY
        ${token}=    Connection Token
        Busca Dados RPA    ${token}
    EXCEPT
        RETURN    FAILD
    END

Atualizar results
    [Arguments]    ${status}
    TRY
        ${token}=    Connection Token

        Create Session    tokenS    ${URL_RPA}

        ${headers}    Create Dictionary
        ...    Authorization=Bearer ${token}
        
        ${body}    Create Dictionary
        ...    name=${RPA_NAME}
        ...    status=${status}

            
        ${RESPONSE}    PUT On Session    tokenS
        ...    /updateresults
        ...    headers=${headers}
        ...    json=${body}

        Log    ${RESPONSE.json()}

        Request Should Be Successful
        Status Should Be    200
    EXCEPT
        Log    Falha ao atualizar results
    END