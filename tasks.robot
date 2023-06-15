*** Settings ***
Documentation       Green.

Library             Collections
Library             ReadCSV
Library             DB
Resource            Keywords.robot
Resource            Requestkeywords.robot

*** Variables ***
${pathMain}         C:\\workspace\\green\\resources    # Path raiz do projeto
# ${cdPaciente}       
# ${cdAtendimento}    
# ${nrConta}          

*** Tasks ***
RPA Green
    ${results}        Get Dados Banco    #Busca os dados no banco
 
    IF    "${results}"=="False"
        Skip    Consulta nao retornou dados.
    END

    #${cdAtendimento}    Set Variable    5157868
    #${nrConta}    Set Variable    22868146 


    #Abrir navegador e acessar a tela
    Logar e Acessar a tela 
        
    FOR  ${robot}     IN    @{results}
        #Pegando numero da conta e atendimento
        ${cdAtendimento}    Set Variable    ${robot}[3]
        ${nrConta}    Set Variable    ${robot}[1] 

        IF    ${nrConta}==None    CONTINUE

        Log    ${nrConta}
        Log    ${cdAtendimento}

        ${statusDownload}=     read csv file    ${pathMain}    ${nrConta}
        Log    ${statusDownload}
        Log To Console    read csv file
        
        IF    ${statusDownload}    CONTINUE
        
        # Valida Pesquisa Atendimento
        Valida tela de Pesquisa Atendimento    ${cdAtendimento} 
        

        # Pesquisa o atendimento
        ${statusPesquisaAtendimeto}=    Pesquisa Atendimento    ${cdAtendimento} 

        IF    "${statusPesquisaAtendimeto}"=="FAILD"    CONTINUE
        
        #Busca conta no griD e aciona o checkbox de imprimir
        ${statusBuscaGrid}=    Buscar Conta no Grid    ${nrConta}
       
        IF    "${statusBuscaGrid}"=="FAILD"    CONTINUE
        
        #Realiza o download do relatorio
        ${statusDownload}=    Download do relatorio   ${cdAtendimento}    ${nrConta}    ${pathMain}
        Log    ${statusDownload}

        IF    "${statusDownload}"=="FAILD"    CONTINUE

        IF    "${statusDownload}"=="OK"
            ${statusIntegra}    Integração WebService     ${cdAtendimento}    ${nrConta}    ${pathMain}
            Pagina Relatorio
            IF    "${statusIntegra}"=="FAILD"    CONTINUE
        END

    END
    
    # rcc run --task "Run RPA Green"