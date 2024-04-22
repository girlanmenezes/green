*** Settings ***
Documentation       Green

Library             Collections
Library             String
Library             DateTime
Library             RPA.Browser.Selenium
# Library    RPA.Excel.Files
Library             RPA.Tables
Library             RPA.HTTP
Library             RPA.FileSystem
Library             OperatingSystem
Library             Processwindows


*** Variables ***
#Transferir esses itens para um page
${QA_ENVIROMENT}                    Get Environment Variable    qaenviroment
${HomeXpathBtnMenu}                 xpath=//*[@class='mv-basico-menu dp32']
${HomeXpathInputPesquisa}           xpath=//input[@id='menu-filter-1']
${cdPage}                           xpath=//*[@id="status"]/div/span[3]
${PageClassImgLoading}              class=las-progress-circular__half-circle
${PageIdTxtUsuario}                 id=username
${PageIdTxtSenha}                   id=password
${PageIdSelectEmpresa}              id=companies
${PageIdBtnLogin}                   name=submit
${PageIClassListMenu}               class=nav
${imagens}                          ${CURDIR}\\4-images
${arquivos_upload}                  ${CURDIR}\\6-files
${classLasDisplay}                  class=las-display
${las}                               @las
${btnExecutar}                      xpath=//li[@id='toolbar']//li[@id='tb-execute']//a
${so}                               windows
${browser}                          chrome
${ambiente}                         qarelease
#${url}                              http://prdmvcr2.adhosp.com.br/mvautenticador-cas/login
#${url}                               http://hmlerpmvcr2.adhosp.com.br:81/soul-mv/ 517789
${nrContaSistema}
#Portable
#${options}                           binary_location="C:\\Program Files\\Google\\GoogleChromePortable\\Chrome.exe";add_argument("--disable-dev-shm-usage");add_argument("--no-sandbox");add_argument("--start-maximized");add_argument("remote-debugging-port=9222")
#centos
#${options}                           binary_location="C:\\CentBrowser\\chrome.exe";add_argument("--disable-dev-shm-usage");add_argument("--no-sandbox");add_argument("--start-maximized");add_argument("remote-debugging-port=9222")
#Chrome
${options}                           binary_location="C:\\Program Files\\Google\\chromewin\\chrome.exe";add_argument("--disable-dev-shm-usage");add_argument("--no-sandbox");add_argument("--start-maximized");add_argument("remote-debugging-port=9222")

#${dadosLoginUsuarioQaRelease}       RPA_CONTA
#${dadosLoginSenhaQaRelease}         12345678

#${dadosLoginUsuarioQaRelease}       TIRPAWATI
#${dadosLoginSenhaQaRelease}         TIRPAWATI

${dadosLoginEmpresaQaRelease}       HOSPITAL NOVE DE JULHO

#${dadosLoginEmpresaQaRelease}       HML - HOSPITAL NOVE DE JULHO
#child_CONEC.HTML,CONTR.HTML,FATUR-CONV.HTML,FATUR-SUS.HTML,FINAN.HTML,PAGU.HTML,SUPRI.HTML

#HML
#${IdIframe}                            id=child_CONEC.HTML,CONTR.HTML,FATUR-CONV.HTML,FATUR-SUS.HTML,FINAN.HTML,PAGU.HTML,SUPRI.HTML
#PROD
${IdIframe}                              id=child_CONEC.HTML,CONTR.HTML,FATUR-CONV.HTML,FATUR-SUS.HTML,FINAN.HTML,PAGU.HTML,SUPRI.HTML
#...                                 id=child_APOIO.HTML,ATEND.HTML,CONTR.HTML,DIAGN.HTML,EXTENSION.HTML,FATUR-CONV.HTML,FATUR-SUS.HTML,FINAN.HTML,GLOBAL.HTML,INTER.HTML,PLANO.HTML,SUPRI.HTML
#...                                 id=child_APOIO.HTML,ATEND.HTML,CONEC.HTML,CONTR.HTML,DIAGN.HTML,FATUR-CONV.HTML,FATUR-SUS.HTML,FINAN.HTML,GLOBAL.HTML,INTER.HTML,PAGU.HTML,SUPRI.HTML   
${IdIframePagu}                     id=child_PAGU.HTML
@{novaListaItensMenu}
@{validaItemExistente}
${EMPTY}


# Elementos tela M_LAN_HOS - Download relatorio
${XpathTxtAtendimento}              xpath=//*[@id='inp:cdAtendimento']
${XpathidAtendimento}               xpath=//*[@id="cdAtendimento"]
${XpathBtnExecutar}                 xpath=//a[@title='Executar Consulta']
${XpathBtnProcurar}                 xpath=//a[@title='Procurar']
${btnCancelaRetornar}                 xpath=//*[@id="btnCancela1"]
${XpathTblContasCell1Col1}          xpath=//div[@class='slick-cell b0 f0 selected']
${XpathTb}                          xpath=//div[@class='slick-cell b0 f0 selected ui-fixed-width']
${IdBtnRelatorio}                   id=btnImprimir
${IdbtnImprCtaFaturada}             id=btnImprCtaFaturada
${BotaoAlertaNao}                   xpath=//button[contains(text(),"não")]
${BotaoAlertaOk}                    xpath=//button[contains(text(),"Ok")]

# Tela de Impressão do relatório
${IdCboSaidaRelatorio}              id=tpSaida_ac
# ${XpathBtnImprimir}    xpath=//button[@data-name='comum_btnImprimir']
${XpathBtnImprimir}                 xpath=//span[contains(text(), 'Imprimir')]
${XpathMsgInfo}
...    xpath=//ul[@class="dropdown-menu workspace-notifications-menu"]/li[@class='notification-info']
${XpathMsgInfoBtnSim}               xpath=//li[@class='notification-buttons']/button[contains(text(),'Sim')]
${XpathMsgInfoBtnOK}                xpath=//li[@class='notification-buttons']/button[contains(text(),'OK')]

${Notifications}                xpath=//*[@id='notifications']

*** Keywords ***
Logar e Acessar a tela
    [Arguments]    ${tela}    ${nomeItem}
    TRY
        Kill Process    chrome.exe
        Kill Process    chrome-custom.exe

        Sleep     5s
        Nova sessao
        Acessar a tela pela busca |${tela}||${nomeItem}|
    EXCEPT
        Skip    Sistema Indisponivel
    END
Executar a pesquisa
    Sleep    2
    Click no Item    ${btnExecutar}

Click no Item
    [Arguments]    ${elemento}
    Wait Until Element Is Visible    ${elemento}    10
    Sleep    1
    Click Element    ${elemento}
    Sleep    1


Clicar botão imprimir relatorio
    ${btnRelatorio}    Run Keyword And Return Status    Click Element    ${IdBtnRelatorio}
    IF    ${btnRelatorio} == ${False}    
        Click Element    ${IdbtnImprCtaFaturada}
    END

Download do relatorio
    [Arguments]    ${cdAtendimento}    ${nrConta}    ${pathMain}
    # [Arguments]    ${cdAtendimento}    ${nrConta}    ${outputReport}
    TRY
        Log To Console    Download Relatorio
        # Imprime relatório
        #Clicar botão imprimir relatorio
        Click Element    ${IdBtnRelatorio}

        

        ${msgInfoVisible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${XpathMsgInfo}    120

        IF    ${msgInfoVisible} == ${True}    
            Run Keyword And Ignore Error    Click Element    ${XpathMsgInfoBtnSim}
            Run Keyword And Ignore Error    Click Element    ${XpathMsgInfoBtnOK}
        END

        Run Keyword And Ignore Error    Clear Element Text    ${IdCboSaidaRelatorio}
        Seleciona Item Combobox    ${IdCboSaidaRelatorio}    Tela
        Click Element    ${XpathBtnImprimir}

        Sleep    2

        # Verifica se alguma mensagem de informação foi apresentada
        ${msgInfoVisible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${XpathMsgInfo}    120

        IF    ${msgInfoVisible} == ${True}    
            Run Keyword And Ignore Error    Click Element    ${XpathMsgInfoBtnSim}
            Run Keyword And Ignore Error    Click Element    ${XpathMsgInfoBtnOK}
        END
        # Aguarda a aba do navegador com o relatório ser carregada
        ${countTabs}    Set Variable    ${1}
        ${count}    Set Variable    ${0}

        WHILE    ${countTabs} == ${1}
            Sleep    1
            ${tabs}    Get Window Titles
            ${countTabs}    Get Length    ${tabs}
            ${count}    Evaluate    ${count} + 1

            # Realiza 30 tentativas durante pouco mais de 30 segundos
            IF    ${count} == ${120}    Fail    Guia do relatório não foi carregada
        END

        Switch Window    NEW    # Seleciona aba do relatório
        ${pdfUrl}    Get Location    # Pega url do relatório pdf

        # Remove arquivo antigo
        Run Keyword And Ignore Error    RPA.FileSystem.Empty Directory    ${pathMain}\\resources\\PDF
        

        Download    ${pdfUrl}    target_file=${pathMain}\\resources\\PDF    # Realiza download do relatório

        # Renomeio o arquivo
        ${date}    Get Current Date    result_format=%d%m%Y%H%M%S
        ${fileName}    Split String    ${pdfUrl}    /
        Log    ${fileName}
        ${lastPosition}    Get Length    ${fileName}
        Log    ${lastPosition} 
        ${lastPosition}    Evaluate    ${lastPosition}-1
        # ${newFileName}    Replace String    ${fileName}[${lastPosition}]    .pdf    _${date}.pdf
        ${newFileName}    Set Variable    ${date}.pdf
        Log     ${newFileName}
        RPA.FileSystem.Move File    ${pathMain}\\resources\\PDF\\${fileName}[${lastPosition}]    ${pathMain}\\resources\\PDF\\${newFileName}
        Sleep    5s

        Log    Relatorio Gerado com Sucesso
        RETURN    OK
    EXCEPT
        Log    Erro ao realizar download do relatorio Atendimento: ${cdAtendimento}
        RETURN    FAILD
    END

Download do relatorio de atendimento
    [Arguments]    ${cdAtendimento}   ${pathMain}
    TRY
        Log To Console    Download Relatorio
        # Imprime relatório
        #Clicar botão imprimir relatorio
       
        Click Element    ${IdBtnRelatorio}

        ${msgInfoVisible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${XpathMsgInfo}    120

        IF    ${msgInfoVisible} == ${True}    
            Run Keyword And Ignore Error    Click Element    ${XpathMsgInfoBtnSim}
            Run Keyword And Ignore Error    Click Element    ${XpathMsgInfoBtnOK}
        END

        Run Keyword And Ignore Error    Clear Element Text    ${IdCboSaidaRelatorio}
        Seleciona Item Combobox    ${IdCboSaidaRelatorio}    Tela
        Click Element    ${XpathBtnImprimir}

        Sleep    2

        # Verifica se alguma mensagem de informação foi apresentada
        ${msgInfoVisible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${XpathMsgInfo}    10

        IF    ${msgInfoVisible} == ${True}    
            Run Keyword And Ignore Error    Click Element    ${XpathMsgInfoBtnSim}
            Run Keyword And Ignore Error    Click Element    ${XpathMsgInfoBtnOK}
        END
        # Aguarda a aba do navegador com o relatório ser carregada
        ${countTabs}    Set Variable    ${1}
        ${count}    Set Variable    ${0}

        WHILE    ${countTabs} == ${1}
            Sleep    1
            ${tabs}    Get Window Titles
            ${countTabs}    Get Length    ${tabs}
            ${count}    Evaluate    ${count} + 1

            # Realiza 30 tentativas durante pouco mais de 30 segundos
            IF    ${count} == ${120}    Fail    Guia do relatório não foi carregada
        END

        Switch Window    NEW    # Seleciona aba do relatório
        ${pdfUrl}    Get Location    # Pega url do relatório pdf

        # Remove arquivo antigo
        Run Keyword And Ignore Error    RPA.FileSystem.Empty Directory    ${pathMain}\\resources\\PDF
        

        Download    ${pdfUrl}    target_file=${pathMain}\\resources\\PDF    # Realiza download do relatório

        # Renomeio o arquivo
        ${date}    Get Current Date    result_format=%d%m%Y%H%M%S
        ${fileName}    Split String    ${pdfUrl}    /
        Log    ${fileName}
        ${lastPosition}    Get Length    ${fileName}
        Log    ${lastPosition} 
        ${lastPosition}    Evaluate    ${lastPosition}-1
        # ${newFileName}    Replace String    ${fileName}[${lastPosition}]    .pdf    _${date}.pdf
        ${newFileName}    Set Variable    ${date}.pdf
        Log     ${newFileName}
        RPA.FileSystem.Move File    ${pathMain}\\resources\\PDF\\${fileName}[${lastPosition}]    ${pathMain}\\resources\\PDF\\${cdAtendimento}${newFileName}
        Sleep    5s

        Log    Relatorio Gerado com Sucesso
        RETURN    OK
    EXCEPT
        Log    Erro ao realizar download do relatorio Atendimento: ${cdAtendimento}
        RETURN    FAILD
    END

Acessar a tela pela busca |${tela}||${nomeItem}|
    #${printscreen}
    Log To Console    Acessando a tela pela busca
    Unselect Frame
    Click Element    ${HomeXpathBtnMenu}
    Input Text    ${HomeXpathInputPesquisa}    ${tela}
    Click Elemento por titulo    ${nomeItem}
    Sleep    10s
    
    Seleciona frame    ${IdIframe}    180


Las
    Seleciona frame    ${IdIframe}    180
    ${ls}    Run Keyword And Return Status    Wait Until Element Is Visible    ${classLasDisplay}    120
    IF    ${ls}
        #Unselect Frame
        Sleep     3s
        Press keys    None    TAB
        Press keys    None    ENTER
    END


Click Elemento por titulo
    [Arguments]    ${titulo}    ${timeout}=${60}
    ${elemento}    Set Variable    xpath=//*[contains(@title, '${titulo}')]
    Wait Until Element Is Visible    ${elemento}    ${timeout}    O elemento ${elemento} não foi carregado
    Wait Until Element Is Enabled    ${elemento}    ${timeout}    O elemento ${elemento} não esta habilitado
    Sleep    1
    Click Element    ${elemento}

Acessar a tela "${caminhoSelecaoMenu}"
    Unselect Frame
    ${cont}    Set Variable    ${1}
    Click Element    ${HomeXpathBtnMenu}
    @{listaItensMenu}    Converte string em lista    ${caminhoSelecaoMenu}    >
    @{listaXpathItensMenu}    Criar Lista Itens Menu Xpath com Index    @{listaItensMenu}
    FOR    ${itemMenu}    IN    @{listaXpathItensMenu}
        ${visivel}    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=${itemMenu}
        Log To Console    *** Visivel: ${visivel}
        ${classe}    RPA.Browser.Selenium.Get Element Attribute    xpath=${itemMenu}/ancestor::li[1]    class
        Log To Console    *** Visivel: ${classe}
        IF    '${classe}' == 'menu-node'
            Seleciona item no menu    ${itemMenu}
        END
        Log To Console    *** Item ${itemMenu} selecionado no menu
        Log    *** Item ${itemMenu} selecionado no menu
    END

    Seleciona frame    ${IdIframe}    180
    Wait Until Element Is Visible    ${classLasDisplay}    120
    Unselect Frame
    ress keys    None    TAB
    Press keys    None    ENTER
    Seleciona frame    ${IdIframe}    180
    Sleep    3

Seleciona Item Combobox
    [Arguments]    ${elemento}    ${valor}
    Wait Until Element Is Visible    ${elemento}    30
    #Input Text    ${elemento}    ${valor}
    Sleep    1
    Wait Until Element Is Enabled    ${elemento}    5
    Press Keys    ${elemento}    ENTER
    FOR    ${i}    IN RANGE    1    11
        Sleep    1
        ${textoAtual}    RPA.Browser.Selenium.Get Element Attribute    ${elemento}    value
        # ${textoAtual}    Get Text    ${elemento}
        IF    "${textoAtual}" == "${valor}"
            BREAK
        ELSE IF    "${textoAtual}" != "${valor}"
            IF    "${i}" == "${10}"
                Log To Console    *** Falha ao tentar selecionar o "${valor}" no combobox ${elemento}
                Log    *** Falha ao tentar selecionar o "${valor}" no combobox ${elemento}
                Capture Page Screenshot
                Fail    *** Falha ao tentar selecionar o "${valor}" no combobox ${elemento}
            ELSE
                Input Text    ${elemento}    ${valor}
                Wait Until Element Is Enabled    ${elemento}    5
                Press Keys    ${elemento}    ENTER
            END
        END
    END

Seleciona item no menu
    [Arguments]    ${xpathTituloItemMenu}
    ${titleItemMenu}    Set Variable    xpath=${xpathTituloItemMenu}
    Wait Until Element Is Visible    ${titleItemMenu}    5
    # Realcar Elemento Execucao    ${titleItemMenu}
    Sleep    0.5
    Click Javascript    ${titleItemMenu}
    Sleep    2

Seleciona frame
    [Arguments]    ${elementoFrame}    ${timeout}=${60}
    Wait Until Element Is Visible
    ...    ${elementoFrame}
    ...    ${timeout}
    ...    O elemento Frame ${elementoFrame} não foi carregado
    Wait Until Element Is Enabled
    ...    ${elementoFrame}
    ...    ${timeout}
    ...    O elemento Frame ${elementoFrame} não esta habilitado
    Select Frame    ${elementoFrame}
    Sleep    3

Realiza Login
    [Arguments]    ${usuario}    ${senha}    ${empresa}
    Log To Console    Realizar Login
    Sleep    2s
    Wait Until Element Is Visible    ${PageIdTxtUsuario}    120    error=Erro ao efetuar o login
    Sleep    2
    Wait Until Element Is Not Visible    ${PageClassImgLoading}    120    error=Erro ao efetuar o login
    Input Text    ${PageIdTxtUsuario}    ${usuario} 
    Input Text    ${PageIdTxtSenha}    ${senha} 
    Select From List By Label    ${PageIdSelectEmpresa}    ${empresa}
    # Capture Page Screenshot
    Click Button    ${PageIdBtnLogin}
    Wait Until Element Is Visible    ${PageIClassListMenu}    timeout=60    error=Erro ao efetuar o login
    Sleep    2

Nova sessao
    Log    *** Teste QA Environment: ${URL_AMBIENTE}
    Log    *** Teste no Sistema Operacional: ${so}
    Log To Console    *** Teste no Sistema Operacional: ${so}

    Open Browser    ${URL_AMBIENTE}   ${browser}    options=${options}
    #Add Cookie    las-uuid    2a603126-6068-4cfb-a00f-b79d6a7adc6d
    Add Cookie    las-uuid    6491a899-2e53-4484-a0d3-76bf432bcd70
    Add Cookie    las-host    http://127.0.0.1:32768
    #Add Cookie    las-host    http://127.0.0.1:32785
    Maximize Browser Window
    Sleep    5s
    Log To Console     ABERTURA DO NAVEGADOR

    Realiza Login    ${USER}    ${SENHA}    ${dadosLoginEmpresaQaRelease}

Criar Lista Itens Menu Xpath com Index
    [Arguments]    @{listaItensMenu}
    Set Test Variable    @{novaListaItensMenu}
    Set Test Variable    @{validaItemExistente}
    ${contLista}    Get length    ${novaListaItensMenu}
    IF    ${contLista} > 0
        FOR    ${item}    IN    @{novaListaItensMenu}
            Remove Values From List    ${novaListaItensMenu}    ${item}
        END
    END
    ${indexXPath}    Set Variable    ${EMPTY}
    FOR    ${itemMenu}    IN    @{listaItensMenu}
        ${indexHtml}    Set Variable    ${1}
        ${contLista}    Get length    ${novaListaItensMenu}
        IF    ${contLista} > 0
            ${contListMenu}    Get Length    ${listaItensMenu}
            FOR    ${novoItemMenu}    IN    @{novaListaItensMenu}
                ${flag}    Set Variable    false
                FOR    ${novoItemMenu}    IN    @{novaListaItensMenu}
                    ${existe}    Get Lines Containing String    ${novoItemMenu}    (//*[@title='${itemMenu}'])[
                    IF    "${existe}" != ""
                        ${flag}    Set Variable    true
                        BREAK
                    END
                END
                IF    "${flag}" == "true"
                    ${indexXPath}    Get Substring    ${novoItemMenu}    -1
                    IF    '${indexXPath}' == ']'
                        ${indexHtml}    Get Substring    ${novoItemMenu}    -2
                        ${indexHtml}    Replace String    ${indexHtml}    ]    ${EMPTY}
                        ${indexHtml}    Set Variable    ${${indexHtml}}
                        ${indexHtml}    Evaluate    ${indexHtml} + 1
                    END
                END
                Append To List    ${novaListaItensMenu}    (//*[@title='${itemMenu}'])[${indexHtml}]
                Exit For Loop
            END
        ELSE
            Append To List    ${novaListaItensMenu}    (//*[@title='${itemMenu}'])[${indexHtml}]
        END
    END
    RETURN    @{novaListaItensMenu}

Converte string em lista
    [Arguments]    ${valor}    ${caracter}
    @{lista}    Split String    ${valor}    ${caracter}
    RETURN    @{lista}

Validacao das mensagens de Alta|${Msg1Alta}||${Msg2Alta}|
    Wait Until Element Is Visible       ${Alerta}                    120
    Valida Mensagem                     ${Alerta}                    ${Msg1Alta}
    Click no Item                       ${BotaoAlerta}    
    Valida Mensagem                     ${Alerta2}                   ${Msg2Alta}
    Click no Item                       ${BotaoAlertaOK}
    Click Elemento por titulo           Sair



Click Javascript
    [Arguments]    ${elemento}
    ${elemento2}    Get WebElement    ${elemento}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${elemento2}
    Capture Page Screenshot


Click Alert
    [Arguments]    ${Botao}
    ${Status}    Run Keyword And Return Status    Wait Until Element Is Visible    ${Botao}    30
    Run Keyword If    '${Status}' == 'True'    Click no Item    ${Botao}

Pagina Relatorio
    ${title_var}        Get Window Titles
    Log  ${title_var}  
    ${cnt}=    Get length    ${title_var}
            
    IF    ${cnt} >= 1  
        Run Keyword And Ignore Error    RPA.Browser.Selenium.Close Window
        Sleep     3s
        Run Keyword And Ignore Error    Switch Window     SOULMV
        Run Keyword And Ignore Error    Seleciona frame    ${IdIframe}    180 
        Run Keyword And Ignore Error    Click Alert    ${BotaoAlertaNao} 
        Run Keyword And Ignore Error    Click no Item    ${Notifications}
        Sleep     2s
        Run Keyword And Ignore Error    Wait Until Element Is Visible     ${XpathBtnProcurar}
        Run Keyword And Ignore Error    Click Element    ${XpathBtnProcurar}
    END


Valida tela de pesquisa atendimento
    [Arguments]    ${cdAtendimento}
    TRY
        Log To Console    Valida tela de pesquisa atendimento
        Sleep    3s
        ${StatusError}    Run Keyword And Return Status    Element Should Contain    ${cdPage}    LOG_FALHA_IMPORTACAO


        IF    ${StatusError}
            Log To Console    Tela erro retornar
            Click Element    ${btnCancelaRetornar}
            Sleep    4s
            Run Keyword And Ignore Error    Wait Until Element Is Visible     ${XpathBtnProcurar}
            Run Keyword And Ignore Error    Click Element    ${XpathBtnProcurar}
            Sleep    3s
        END

        Sleep    3s
        Wait Until Keyword Succeeds    20x    3s    input text     ${XpathTxtAtendimento}   ${cdAtendimento}

        input text     ${XpathTxtAtendimento}   ${EMPTY}

        RETURN    OK 
    EXCEPT
        Log To Console    Falha Valida tela de pesquisa atendimento
        RETURN    FAILD 
    END

    
Buscar Conta no Grid 
	[Arguments]    	${nrConta}
    TRY
        Wait Until Keyword Succeeds    10x    6s    Wait Until Element Is Visible    ${XpathTblContasCell1Col1}    120    
        FOR    ${i}    IN RANGE    50
            ${nrContaSistema}    Get Value nrConta    ${i}  
            ${True}		Run Keyword And Return Status     Should Be Equal As Strings    ${nrConta}    ${nrContaSistema}
            IF    ${True}    
                ${CheckBox}	    Run Keyword And Return Status      Element Should Be Visible  //*[@id="grdRegFat"]/div[4]/div[3]/div/div[${i}]/div[14]/div/button[@state='unchecked']
                IF    ${CheckBox}
                    Click Element    //*[@id="grdRegFat"]/div[4]/div[3]/div/div[${i}]/div[14]/div/button
                END
                Click Element    //*[@id="grdRegFat"]/div[4]/div[3]/div/div[${i}]/div[1]/div
                BREAK
            END
        END
        RETURN    OK 
    EXCEPT
        Log To Console    Erro ao buscar conta no grid
        RETURN    FAILD 
    END



Get Value nrConta
    [Arguments]    	${i}
    TRY
        ${nrContaSistema}   RPA.Browser.Selenium.Get Text    //*[@id="grdRegFat"]/div[4]/div[3]/div/div[${i}]/div[1]/div
        RETURN    ${nrContaSistema}
    EXCEPT
        Log To Console     Não Existe Conta
    END
    
#${Result}=     Run Keyword And Return Status     Page Should Contain Element  ${Xpath} 


Pesquisa Atendimento conta
    [Arguments]    ${cdAtendimento}
    TRY
        Log To Console    Pesquisar o atendimento
        Sleep     5s
        Wait Until Element Is Visible    ${XpathTxtAtendimento}    120
        Input Text    ${XpathTxtAtendimento}    ${cdAtendimento}
        Click Element    ${XpathBtnExecutar}
        Sleep     5s    
            
        # Seleciona conta
        ${dadosAtendimento}    Run Keyword And Return Status    Wait Until Element Is Visible    ${XpathTblContasCell1Col1}    120
        RETURN    OK
    EXCEPT
        Log To Console   Erro ao pesquisar o atendimento
        RETURN    FAILD
    END
    
Pesquisa Atendimento
    [Arguments]    ${cdAtendimento}
    TRY

        Log To Console    Pesquisar o atendimento
        Sleep     5s
        Wait Until Element Is Visible    ${XpathTxtAtendimento}    120
        Input Text    ${XpathTxtAtendimento}    ${cdAtendimento}
        Click Element    ${XpathBtnExecutar}
        Sleep     5s    
            
        # Seleciona conta
        ${dadosAtendimento}    Run Keyword And Return Status    Wait Until Element Is Visible    ${XpathTb}    120
        RETURN    OK
    EXCEPT
        Log To Console    Erro ao pesquisar o atendimento
        RETURN    FAILD
    END
    