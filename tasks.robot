*** Settings ***
Documentation       Green.

Library             Collections
Library             DB
Resource            Keywords.robot
Resource            Requestkeywords.robot

*** Variables ***
${pathMain}         ${CURDIR}    # Path raiz do projeto
# ${cdPaciente}       
# ${cdAtendimento}    
# ${nrConta}          

*** Tasks ***
RPA Green
    ${results}        Get Dados Banco    #Busca os dados no banco
    Log     ${results}

    IF    "${results}"=="False"
        Skip    Consulta nao retornou dados.
    END


    Logar e Acessar a tela 
        
    FOR  ${robot}     IN    ${results}
        ${cdAtendimento}= robot[4]
        ${nrConta}= robot[2]

        #Realiza o download do relatorio
        Download do relatorio   ${cdAtendimento}    ${nrConta}    ${pathMain}

        #Autentica serviço e realiza a requsição
        Integração WebService     ${cdAtendimento}    ${nrConta}    ${pathMain}
    END
    
    # rcc run --task "Run RPA Green"
    # Logar e acessar a tela - Foi utilizado o projeto de automação existente
    # Logar e Acessar a tela
    # Realiza o download do relatorio
    # Download do relatorio    ${cdPaciente}    ${cdAtendimento}    ${nrConta}    ${pathMain}
    #    Autentica serviço e realiza a requisição
    # Integração WebService    ${cdPaciente}    ${cdAtendimento}    ${nrConta}    ${pathMain}