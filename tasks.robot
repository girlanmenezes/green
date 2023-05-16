*** Settings ***
Documentation       Green.

Library             Collections
Library             DB
Resource            keywords.robot
Resource            Requestkeywords.robot
*** Variables ***    
${nomePDF}=           nome.pdf        #Definir o nome do arquivo dinamicamente
${cdPaciente}
${cdAtendimento}
${nrConta}


*** Tasks ***
RPA Green
    ${results}=        Get Dados    #Busca os dados no banco
        
        FOR  ${robot}     IN    ${results}
        #VALIDAR ESSE DE/PARA
        ${cdPaciente} = robot[1]
        ${cdAtendimento}= robot[2]
        ${nrConta}= robot[6]
        
        #Logar e acessar a tela - Foi utilizado o projeto de automação existente
        Logar e Acessar a tela 

        #Realiza o download do relatorio
        Download do relatorio    ${cdPaciente}    ${cdAtendimento}    ${nrConta}

        #Autentica serviço e realiza a requsição
        Integração WebService    ${nomePDF}    ${cdPaciente}    ${cdAtendimento}    ${nrConta}
        END


