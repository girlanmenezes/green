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


*** Variables ***
#Transferir esses itens para um page
${QA_ENVIROMENT}                    Get Environment Variable    qaenviroment
${HomeXpathBtnMenu}                 xpath=//*[@class='mv-basico-menu dp32']
${HomeXpathInputPesquisa}           xpath=//input[@id='menu-filter-1']
${PageClassImgLoading}              class=las-progress-circular__half-circle
${PageIdTxtUsuario}                 id=username
${PageIdTxtSenha}                   id=password
${PageIdSelectEmpresa}              id=companies
${PageIdBtnLogin}                   name=submit
${PageIClassListMenu}               class=nav
${imagens}                          ${CURDIR}\\4-images
${arquivos_upload}                  ${CURDIR}\\6-files

${btnExecutar}                      xpath=//li[@id='toolbar']//li[@id='tb-execute']//a
${so}                               windows
${browser}                          chrome
${ambiente}                         qarelease
${url}                              http://prdmvcr2.adhosp.com.br/mvautenticador-cas/login

${options}
...                                 binary_location="C:\\Program Files\\Google\\GoogleChromePortable\\Chrome.exe"; add_argument("--disable-dev-shm-usage"); add_argument("--no-sandbox"); add_argument("--start-maximized"); add_argument("headless");
${dadosLoginUsuarioQaRelease}       TIRPAWATI
${dadosLoginSenhaQaRelease}         TIRPAWATI
${dadosLoginEmpresaQaRelease}       HOSPITAL NOVE DE JULHO
${IdIframe}
...                                 id=child_APOIO.HTML,ATEND.HTML,CONTR.HTML,DIAGN.HTML,EXTENSION.HTML,FATUR-CONV.HTML,FATUR-SUS.HTML,FINAN.HTML,GLOBAL.HTML,INTER.HTML,PLANO.HTML,SUPRI.HTML
${IdIframePagu}                     id=child_PAGU.HTML
@{novaListaItensMenu}
@{validaItemExistente}



# Elementos tela M_LAN_HOS - Download relatorio
${XpathTxtAtendimento}              xpath=//*[@id='inp:cdAtendimento']
${XpathBtnExecutar}                 xpath=//a[@title='Executar Consulta']
${XpathTblContasCell1Col1}          xpath=//div[@class='slick-cell b0 f0 selected']
${IdBtnRelatorio}                   id=btnImprimir

# Tela de Impressão do relatório
${IdCboSaidaRelatorio}              id=tpSaida_ac
# ${XpathBtnImprimir}    xpath=//button[@data-name='comum_btnImprimir']
${XpathBtnImprimir}                 xpath=//span[contains(text(), 'Imprimir')]
${XpathMsgInfo}
...    xpath=//ul[@class="dropdown-menu workspace-notifications-menu"]/li[@class='notification-info']
${XpathMsgInfoBtnSim}               xpath=//li[@class='notification-buttons']/button[contains(text(),'Sim')]


*** Keywords ***
Logar e Acessar a tela
    Nova sessao
    Acessar a tela pela busca |M_LAN_HOS||Conta do Atendimento|

Executar a pesquisa
    Sleep    2
    Click no Item    ${btnExecutar}

Click no Item
    [Arguments]    ${elemento}
    Wait Until Element Is Visible    ${elemento}    120
    Sleep    1
    Click Element    ${elemento}
    Sleep    1

Download do relatorio
    [Arguments]    ${cdAtendimento}    ${nrConta}    ${pathMain}
    # [Arguments]    ${cdAtendimento}    ${nrConta}    ${outputReport}

    # Pesquisa número de atendimento
    Wait Until Element Is Visible    ${XpathTxtAtendimento}    120
    Input Text    ${XpathTxtAtendimento}    ${cdAtendimento}
    Click Element    ${XpathBtnExecutar}

    # Seleciona conta
    Sleep    10
    Wait Until Element Is Enabled    ${XpathTblContasCell1Col1}    120
    Sleep    1
    ${nrContaSistema}    RPA.Browser.Selenium.Get Text    ${XpathTblContasCell1Col1}
    Should Be Equal As Strings    ${nrConta}    ${nrContaSistema}
    Click Element    ${XpathTblContasCell1Col1}
    Sleep    1

    # Imprime relatório
    Click Element    ${IdBtnRelatorio}
    Seleciona Item Combobox    ${IdCboSaidaRelatorio}    Tela
    Click Element    ${XpathBtnImprimir}

    # Verifica se alguma mensagem de informação foi apresentada
    ${msgInfoVisible}    Run Keyword And Return Status    Wait Until Element Is Visible    ${XpathMsgInfo}    3

    IF    ${msgInfoVisible} == ${True}    Click Element    ${XpathMsgInfoBtnSim}

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
    ${files}    RPA.FileSystem.List Files In Directory    ${pathMain}\\resources\\PDF
    ${fileCount}    Get Length    ${files}

    IF    ${fileCount} == ${1}
        ${files}    Convert To String    ${files}
        ${attrFile}    Split String    ${files}    ,
        ${fileName}    Replace String    ${attrFile}[1]    name='    ${EMPTY}
        ${fileName}    Replace String    ${fileName}    '    ${EMPTY}
        ${fileName}    Set Variable    ${fileName.strip()}
        OperatingSystem.Remove File    ${pathMain}\\resources\\PDF\\${fileName}
    END

    Download    ${pdfUrl}    ${pathMain}\\resources\\PDF    # Realiza download do relatório

    # Renomeio o arquivo
    ${date}    Get Current Date    result_format=%d%m%Y%H%M%S
    ${fileName}    Split String    ${pdfUrl}    /
    ${lastPosition}    Get Length    ${fileName}
    ${lastPosition}    Evaluate    ${lastPosition}-1
    # ${newFileName}    Replace String    ${fileName}[${lastPosition}]    .pdf    _${date}.pdf
    ${newFileName}    Set Variable    ${date}.pdf
    RPA.FileSystem.Move File    ${pathMain}\\resources\\PDF\\${fileName}[${lastPosition}]    ${pathMain}\\resources\\PDF\\${newFileName}

Acessar a tela pela busca |${tela}||${nomeItem}|
    #${printscreen}
    Unselect Frame
    Click Element    ${HomeXpathBtnMenu}
    Input Text    ${HomeXpathInputPesquisa}    ${tela}
    Click Elemento por titulo    ${nomeItem}
    Seleciona frame    ${IdIframe}    180

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
    Sleep    3

Seleciona Item Combobox
    [Arguments]    ${elemento}    ${valor}
    Wait Until Element Is Visible    ${elemento}    30
    Input Text    ${elemento}    ${valor}
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
    ${url}    Set Variable If    %{DRY_RUN=${True}} == ${True}    ${url}    ${QA_ENVIROMENT}

    Log    *** Teste QA Environment: ${url}
    Log    *** Teste no Sistema Operacional: ${so}
    Log To Console    *** Teste no Sistema Operacional: ${so}

    Open Browser    ${url}    ${browser}    options=${options}
    Add Cookie    las-uuid    2a603126-6068-4cfb-a00f-b79d6a7adc6d
    Add Cookie    las-host    http://127.0.0.1:32768
    Maximize Browser Window
    Sleep    30
    Log     ABERTURA DO NAVEGADOR

    Realiza Login    ${dadosLoginUsuarioQaRelease}    ${dadosLoginSenhaQaRelease}    ${dadosLoginEmpresaQaRelease}

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

Click Javascript
    [Arguments]    ${elemento}
    ${elemento2}    Get WebElement    ${elemento}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${elemento2}
    Capture Page Screenshot
