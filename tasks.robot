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
        Log To Console    Lendo o CS Conta:${nrConta}


        ${buscaAtendimento}=    Busca Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_HOS
        IF    ${buscaAtendimento}    CONTINUE

        IF    ${statusCSV}    CONTINUE
        
        # Valida Pesquisa Atendimento
        ${statusValidaAtendimeto}    Valida tela de Pesquisa Atendimento    ${cdAtendimento} 

        IF    "${statusValidaAtendimeto}"=="FAILD"
            Logar e Acessar a tela    M_LAN_HOS   Conta Hospitalar
        END


        ${statusPesquisaAtendimeto}=    Pesquisa Atendimento conta    ${cdAtendimento} 

        IF    "${statusPesquisaAtendimeto}"=="FAILD" 
            Run Keyword And Ignore Error    Atualiza Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_HOS     error   
            CONTINUE
        END
        
        #Busca conta no griD e aciona o checkbox de imprimir
        ${statusBuscaGrid}=    Buscar Conta no Grid    ${nrConta}
       
        IF    "${statusBuscaGrid}"=="FAILD" 
            Run Keyword And Ignore Error    Atualiza Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_HOS     error   
            CONTINUE
        END

        #Realiza o download do relatorio
        ${statusDownload}=    Download do relatorio   ${cdAtendimento}    ${nrConta}    ${pathMain}
        Log    ${statusDownload}

        IF    "${statusDownload}"=="FAILD" 
            Run Keyword And Ignore Error    Atualiza Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_HOS     error   
            CONTINUE
        END

        IF    "${statusDownload}"=="OK"
            ${statusIntegra}    Integração WebService     ${cdAtendimento}    ${nrConta}    ${pathMain}    ${pathCSV}    M_LAN_HOS
            Pagina Relatorio
            IF    "${statusIntegra}"=="FAILD"    CONTINUE
        END

    END

    Atualizar results    SUCCESS
    

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
        ${nrConta}          Set Variable    ${robot}[9]
        IF    ${cdAtendimento}==None    CONTINUE
        
        Log    ${cdAtendimento}    console=True

        ${statusCSV}=     read csv atendimento file    ${pathCSVat}    ${cdAtendimento}
        Log To Console    Lendo o CSV atendimento:${cdAtendimento}

        ${buscaAtendimento}=    Busca Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_AMB

        IF    ${buscaAtendimento}    CONTINUE
        IF    ${statusCSV}    CONTINUE
        
        # Valida Pesquisa Atendimento
        ${statusValidaAtendimeto}    Valida tela de Pesquisa Atendimento    ${cdAtendimento} 

        IF    "${statusValidaAtendimeto}"=="FAILD"
            Logar e Acessar a tela    M_LAN_AMB   Conta Atendimento
        END

        ${statusPesquisaAtendimeto}=    Pesquisa Atendimento    ${cdAtendimento} 

        IF    "${statusPesquisaAtendimeto}"=="FAILD"    
            Run Keyword And Ignore Error    Atualiza Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_AMB      error  
            CONTINUE
        END
        
        #Realiza o download do relatorio
        ${statusDownload}=    Download do relatorio de atendimento   ${cdAtendimento}   ${pathMain}
        Log    ${statusDownload}

        IF    "${statusDownload}"=="FAILD"    
            Run Keyword And Ignore Error    Atualiza Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_AMB      error 
            CONTINUE
        END

        
        IF    "${statusDownload}"=="OK"
            ${statusIntegra}    Integração WebService     ${cdAtendimento}    ${nrConta}    ${pathMain}    ${pathCSVat}    M_LAN_AMB
            Pagina Relatorio
            IF    "${statusIntegra}"=="FAILD"    CONTINUE
        END

    END

    Atualizar results    SUCCESS
    
    # rcc run --task "Run all tasks"

