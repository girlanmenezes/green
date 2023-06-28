*** Settings ***
Documentation       Green.

Library             Collections
Library             ReadCSV
Library             DB
Resource            Keywords.robot
Resource            Requestkeywords.robot
Resource            Request.robot
*** Variables ***
${pathMain}         C:\\workspace\\green    # Path raiz do projeto
${pathCSV}          C:\\workspace\\green\\resources\\CSV\\RELATORIO_ENVIOS.csv
${pathCSVat}        C:\\workspace\\green\\resources\\CSV\\RELATORIO_ATENDIMENTO_ENVIOS.csv
${pathPDF}          C:\\workspace\\green\\resources\\PDF
        

*** Tasks ***
RPA Green
    ${data}    Get info
    IF    "${data}"=="FAILD"
        Skip    Erro ao consultar RPA.
    END
    ${results}        Get Conta Banco    ${DIAS_RETROATIVOS}    #Busca os dados no banco
 
    IF    "${results}"=="False"
        Skip    Consulta nao retornou dados.
    END

    #Abrir navegador e acessar a tela
    Logar e Acessar a tela    M_LAN_HOS   Conta Hospitalar    
        
    FOR  ${robot}     IN    @{results}
        #Pegando numero da conta e atendimento
        ${cdAtendimento}    Set Variable    ${robot}[2]
        ${nrConta}          Set Variable    ${robot}[9]     #Busca os dados no banco
    
        IF    ${nrConta}==None    CONTINUE

        Log    ${nrConta}
        Log    ${cdAtendimento}


        ${statusCSV}=     read csv file    ${pathCSV}    ${nrConta}
        Log    ${statusCSV}
        Log To Console    read csv file
        
        IF    ${statusCSV}    CONTINUE
        
        # Valida Pesquisa Atendimento
        ${statusValidaAtendimeto}    Valida tela de Pesquisa Atendimento    ${cdAtendimento} 

        IF    "${statusValidaAtendimeto}"=="FAILD"
            Logar e Acessar a tela    M_LAN_HOS   Conta Hospitalar
        END


        ${statusPesquisaAtendimeto}=    Pesquisa Atendimento conta    ${cdAtendimento} 

        IF    "${statusPesquisaAtendimeto}"=="FAILD"    CONTINUE
        
        
        #Busca conta no griD e aciona o checkbox de imprimir
        ${statusBuscaGrid}=    Buscar Conta no Grid    ${nrConta}
       
        IF    "${statusBuscaGrid}"=="FAILD"    CONTINUE
        
        #Realiza o download do relatorio
        ${statusDownload}=    Download do relatorio   ${cdAtendimento}    ${nrConta}    ${pathMain}
        Log    ${statusDownload}

        IF    "${statusDownload}"=="FAILD"    CONTINUE

        IF    "${statusDownload}"=="OK"
            ${statusIntegra}    Integração WebService     ${cdAtendimento}    ${nrConta}    ${pathMain}    ${pathCSV}
            Pagina Relatorio
            IF    "${statusIntegra}"=="FAILD"    CONTINUE
        END

    END
    

RPA Green Atendimento
    ${data}    Get info
    IF    "${data}"=="FAILD"
        Skip    Erro ao consultar RPA.
    END

    ${results}        Get Atendimento Banco    ${DIAS_RETROATIVOS}    #Busca os dados no banco
 
    IF    "${results}"=="False"
        Skip    Consulta nao retornou dados.
    END

    #Abrir navegador e acessar a tela
    Logar e Acessar a tela    M_LAN_AMB   Conta Atendimento
        
    FOR  ${robot}     IN    @{results}
        #Pegando numero da conta e atendimento
        ${cdAtendimento}    Set Variable    ${robot}[2]

        IF    ${cdAtendimento}==None    CONTINUE

        Log    ${cdAtendimento}


        ${statusCSV}=     read csv atendimento file    ${pathCSVat}    ${cdAtendimento}
        Log    ${statusCSV}
        Log To Console    read csv file
        
        IF    ${statusCSV}    CONTINUE
        
        # Valida Pesquisa Atendimento
        ${statusValidaAtendimeto}    Valida tela de Pesquisa Atendimento    ${cdAtendimento} 

        IF    "${statusValidaAtendimeto}"=="FAILD"
            Logar e Acessar a tela    M_LAN_AMB   Conta Atendimento
        END

        ${statusPesquisaAtendimeto}=    Pesquisa Atendimento    ${cdAtendimento} 

        IF    "${statusPesquisaAtendimeto}"=="FAILD"    CONTINUE
        
        
        #Realiza o download do relatorio
        ${statusDownload}=    Download do relatorio de atendimento   ${cdAtendimento}   ${pathMain}
        Log    ${statusDownload}

        IF    "${statusDownload}"=="FAILD"    CONTINUE
        ${nrConta}    Set Variable    0000
        IF    "${statusDownload}"=="OK"
            ${statusIntegra}    Integração WebService     ${cdAtendimento}    ${nrConta}    ${pathMain}    ${pathCSVat}
            Pagina Relatorio
            IF    "${statusIntegra}"=="FAILD"    CONTINUE
        END

    END
    
    # rcc run --task "Run all tasks"