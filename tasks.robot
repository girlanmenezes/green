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
    ${data}    Get info    #FILTRAR POR EMPRESA
    IF    "${data}"=="FAILD"
        Skip    Erro ao consultar RPA.
    END
    ${results}        Get Conta Banco    ${DIAS_RETROATIVOS}    1     #Busca os dados no banco #PASSAR PARAMETRO DA EMPRESA
 
    IF    "${results}"=="False"
        Skip    Consulta nao retornou dados.
    END

    #Abrir navegador e acessar a tela
    Logar e Acessar a tela    M_LAN_HOS   Conta Hospitalar    HOSPITAL NOVE DE JULHO    
        
    FOR  ${robot}     IN    @{results}
        #Pegando numero da conta e atendimento
        ${cdAtendimento}    Set Variable    ${robot}[2]
        ${nrConta}          Set Variable    ${robot}[9]     #Busca os dados no banco
    
        IF    ${nrConta}==None    CONTINUE

        Log    ${nrConta}
        Log    ${cdAtendimento}

        Log To Console    Processando Conta:${nrConta}


        ${buscaAtendimento}=    Busca Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_HOS    1
        IF    ${buscaAtendimento}    CONTINUE

        
        # Valida Pesquisa Atendimento
        ${statusValidaAtendimeto}    Valida tela de Pesquisa Atendimento    ${cdAtendimento} 

        IF    "${statusValidaAtendimeto}"=="FAILD"
            Logar e Acessar a tela    M_LAN_HOS   Conta Hospitalar    HOSPITAL NOVE DE JULHO  
        END


        ${statusPesquisaAtendimeto}=    Pesquisa Atendimento conta    ${cdAtendimento} 

        IF    "${statusPesquisaAtendimeto}"=="FAILD" 
            Run Keyword And Ignore Error    Atualiza Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_HOS     error    1  
            CONTINUE
        END
        
        #Busca conta no griD e aciona o checkbox de imprimir
        ${statusBuscaGrid}=    Buscar Conta no Grid    ${nrConta}
       
        IF    "${statusBuscaGrid}"=="FAILD" 
            Run Keyword And Ignore Error    Atualiza Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_HOS     error    1   
            CONTINUE
        END

        #Realiza o download do relatorio
        ${statusDownload}=    Download do relatorio   ${cdAtendimento}    ${nrConta}    ${pathMain}
        Log    ${statusDownload}

        IF    "${statusDownload}"=="FAILD" 
            Run Keyword And Ignore Error    Atualiza Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_HOS     error    1   
            CONTINUE
        END

        IF    "${statusDownload}"=="OK"
            ${statusIntegra}    Integração WebService     ${cdAtendimento}    ${nrConta}    ${pathMain}    ${pathCSV}    M_LAN_HOS    1
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

    ${results}        Get Atendimento Banco    ${DIAS_RETROATIVOS}    1    #Busca os dados no banco
 
    IF    "${results}"=="False"
        Skip    Consulta nao retornou dados.
    END

    #Abrir navegador e acessar a tela
    Logar e Acessar a tela    M_LAN_AMB   Conta Atendimento    HOSPITAL NOVE DE JULHO  
        
    FOR  ${robot}     IN    @{results}
        #Pegando numero da conta e atendimento
        ${cdAtendimento}    Set Variable    ${robot}[2]
        ${nrConta}          Set Variable    ${robot}[9]
        IF    ${cdAtendimento}==None    CONTINUE
        
        Log    ${cdAtendimento}    console=True

        Log To Console    Processamdp Atemdo,emtp atendimento:${cdAtendimento}

        ${buscaAtendimento}=    Busca Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_AMB    1

        IF    ${buscaAtendimento}    CONTINUE

        
        # Valida Pesquisa Atendimento
        ${statusValidaAtendimeto}    Valida tela de Pesquisa Atendimento    ${cdAtendimento} 

        IF    "${statusValidaAtendimeto}"=="FAILD"
            Logar e Acessar a tela    M_LAN_AMB   Conta Atendimento    HOSPITAL NOVE DE JULHO  
        END

        ${statusPesquisaAtendimeto}=    Pesquisa Atendimento    ${cdAtendimento} 

        IF    "${statusPesquisaAtendimeto}"=="FAILD"    
            Run Keyword And Ignore Error    Atualiza Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_AMB      error    1  
            CONTINUE
        END
        
        #Realiza o download do relatorio
        ${statusDownload}=    Download do relatorio de atendimento   ${cdAtendimento}   ${pathMain}
        Log    ${statusDownload}

        IF    "${statusDownload}"=="FAILD"    
            Run Keyword And Ignore Error    Atualiza Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_AMB      error    1 
            CONTINUE
        END

        
        IF    "${statusDownload}"=="OK"
            ${statusIntegra}    Integração WebService     ${cdAtendimento}    ${nrConta}    ${pathMain}    ${pathCSVat}    M_LAN_AMB    1
            Pagina Relatorio
            IF    "${statusIntegra}"=="FAILD"    CONTINUE
        END

    END

    Atualizar results    SUCCESS
    
    # rcc run --task "Run all tasks"

RPA Green ALPHAVILLE HOSPITAL NOVE DE JULHO
    ${data}    Get info    #FILTRAR POR EMPRESA
    IF    "${data}"=="FAILD"
        Skip    Erro ao consultar RPA.
    END
    ${results}        Get Conta Banco    ${DIAS_RETROATIVOS}    2     #Busca os dados no banco #PASSAR PARAMETRO DA EMPRESA
 
    IF    "${results}"=="False"
        Skip    Consulta nao retornou dados.
    END

    #Abrir navegador e acessar a tela
    Logar e Acessar a tela    M_LAN_HOS   Conta Hospitalar    ALPHAVILLE HOSPITAL NOVE DE JULHO   
        
    FOR  ${robot}     IN    @{results}
        #Pegando numero da conta e atendimento
        ${cdAtendimento}    Set Variable    ${robot}[2]
        ${nrConta}          Set Variable    ${robot}[9]     #Busca os dados no banco
    
        IF    ${nrConta}==None    CONTINUE

        Log    ${nrConta}
        Log    ${cdAtendimento}

        Log To Console    Processando Conta:${nrConta}


        ${buscaAtendimento}=    Busca Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_HOS    2
        IF    ${buscaAtendimento}    CONTINUE

        
        # Valida Pesquisa Atendimento
        ${statusValidaAtendimeto}    Valida tela de Pesquisa Atendimento    ${cdAtendimento} 

        IF    "${statusValidaAtendimeto}"=="FAILD"
            Logar e Acessar a tela    M_LAN_HOS   Conta Hospitalar    ALPHAVILLE HOSPITAL NOVE DE JULHO 
        END


        ${statusPesquisaAtendimeto}=    Pesquisa Atendimento conta    ${cdAtendimento} 

        IF    "${statusPesquisaAtendimeto}"=="FAILD" 
            Run Keyword And Ignore Error    Atualiza Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_HOS     error    2   
            CONTINUE
        END
        
        #Busca conta no griD e aciona o checkbox de imprimir
        ${statusBuscaGrid}=    Buscar Conta no Grid    ${nrConta}
       
        IF    "${statusBuscaGrid}"=="FAILD" 
            Run Keyword And Ignore Error    Atualiza Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_HOS     error    2   
            CONTINUE
        END

        #Realiza o download do relatorio
        ${statusDownload}=    Download do relatorio   ${cdAtendimento}    ${nrConta}    ${pathMain}
        Log    ${statusDownload}

        IF    "${statusDownload}"=="FAILD" 
            Run Keyword And Ignore Error    Atualiza Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_HOS     error    2   
            CONTINUE
        END

        IF    "${statusDownload}"=="OK"
            ${statusIntegra}    Integração WebService     ${cdAtendimento}    ${nrConta}    ${pathMain}    ${pathCSV}    M_LAN_HOS    2
            Pagina Relatorio
            IF    "${statusIntegra}"=="FAILD"    CONTINUE
        END

    END

    Atualizar results    SUCCESS
    

RPA Green Atendimento ALPHAVILLE HOSPITAL NOVE DE JULHO
    ${data}    Get info
    IF    "${data}"=="FAILD"
        Skip    Erro ao consultar RPA.
    END

    ${results}        Get Atendimento Banco    ${DIAS_RETROATIVOS}    2    #Busca os dados no banco
 
    IF    "${results}"=="False"
        Skip    Consulta nao retornou dados.
    END

    #Abrir navegador e acessar a tela
    Logar e Acessar a tela    M_LAN_AMB   Conta Atendimento    ALPHAVILLE HOSPITAL NOVE DE JULHO
        
    FOR  ${robot}     IN    @{results}
        #Pegando numero da conta e atendimento
        ${cdAtendimento}    Set Variable    ${robot}[2]
        ${nrConta}          Set Variable    ${robot}[9]
        IF    ${cdAtendimento}==None    CONTINUE
        
        Log    ${cdAtendimento}    console=True

        Log To Console    Processamdp Atemdo,emtp atendimento:${cdAtendimento}

        ${buscaAtendimento}=    Busca Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_AMB    2

        IF    ${buscaAtendimento}    CONTINUE

        
        # Valida Pesquisa Atendimento
        ${statusValidaAtendimeto}    Valida tela de Pesquisa Atendimento    ${cdAtendimento} 

        IF    "${statusValidaAtendimeto}"=="FAILD"
            Logar e Acessar a tela    M_LAN_AMB   Conta Atendimento    ALPHAVILLE HOSPITAL NOVE DE JULHO 
        END

        ${statusPesquisaAtendimeto}=    Pesquisa Atendimento    ${cdAtendimento} 

        IF    "${statusPesquisaAtendimeto}"=="FAILD"    
            Run Keyword And Ignore Error    Atualiza Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_AMB      error    2  
            CONTINUE
        END
        
        #Realiza o download do relatorio
        ${statusDownload}=    Download do relatorio de atendimento   ${cdAtendimento}   ${pathMain}
        Log    ${statusDownload}

        IF    "${statusDownload}"=="FAILD"    
            Run Keyword And Ignore Error    Atualiza Atendimento    ${cdAtendimento}    ${nrConta}    M_LAN_AMB      error    2 
            CONTINUE
        END

        
        IF    "${statusDownload}"=="OK"
            ${statusIntegra}    Integração WebService     ${cdAtendimento}    ${nrConta}    ${pathMain}    ${pathCSVat}    M_LAN_AMB    2
            Pagina Relatorio
            IF    "${statusIntegra}"=="FAILD"    CONTINUE
        END

    END

    Atualizar results    SUCCESS