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
        Log    Falha ao atualizar results    console=True
    END


Busca Atendimento
    [Arguments]    ${cdAtendimento}    ${nrConta}    ${tela}    ${empresa}  
    TRY
        ${token}=    Connection Token

        Create Session    tokenS    ${URL_RPA}

        ${date}    Get Current Date

        ${headers}    Create Dictionary
        ...    Authorization=Bearer ${token}
        
        IF    "${tela}"=="M_LAN_AMB"
            ${nrConta}=    Set Variable    ${null}
        END
        
        ${body}    Create Dictionary
        ...    atendimento=${cdAtendimento}
        ...    conta=${nrConta}
        ...    tela=${tela}
        ...    status=pending
        ...    dataExecucao=${date}
        ...    empresa=${empresa}


            
        ${RESPONSE}    POST On Session    tokenS
        ...    /atendimentoConta
        ...    headers=${headers}
        ...    json=${body}

        Log    ${RESPONSE.json()}

        ${msgJson}    Get value from JSON    ${RESPONSE.json()}    $.mensagem
        ${statusJson}    Get value from JSON    ${RESPONSE.json()}    $.status

        Log     ${msgJson}-${cdAtendimento}/${nrConta}    console=True

        RETURN    ${statusJson}
    EXCEPT
        Log    Busca de atendimento/conta:${cdAtendimento}/${nrConta} não realizada    console=True
        RETURN    ${True} 
    END


Atualiza Atendimento
    [Arguments]    ${cdAtendimento}    ${nrConta}    ${tela}     ${status}     ${empresa}
    TRY
        ${token}=    Connection Token

        Create Session    tokenS    ${URL_RPA}

        ${date}    Get Current Date

        ${headers}    Create Dictionary
        ...    Authorization=Bearer ${token}
        
        IF    "${tela}"=="M_LAN_AMB"
            ${nrConta}=    Set Variable    ${null}
        END

        ${body}    Create Dictionary
        ...    atendimento=${cdAtendimento}
        ...    conta=${nrConta}
        ...    tela=${tela}
        ...    status=${status} 
        ...    dataExecucao=${date}
        ...    empresa=${empresa}


            
        ${RESPONSE}    PUT On Session    tokenS
        ...    /atendimentoConta
        ...    headers=${headers}
        ...    json=${body}

        Log    ${RESPONSE.json()}

        Request Should Be Successful
        Log     Atualização realizada com sucesso:/${cdAtendimento}     console=True

    EXCEPT
        Log    Atualização do atendimento: ${cdAtendimento} não realizada    console=True
    END