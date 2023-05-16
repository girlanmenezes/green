*** Settings ***
Library    Collections
Library    String
Library    DateTime
Library    RPA.Browser.Selenium
Library    RPA.Excel.Files
Library    RPA.HTTP

Documentation       Green

*** Variable ***

#Transferir esses itens para um page
${QA_ENVIROMENT} =    Get Environment Variable    qaenviroment
${HomeXpathBtnMenu}    xpath=//*[@class='mv-basico-menu dp32']
${HomeXpathInputPesquisa}    xpath=//input[@id='menu-filter-1']
${PageIdTxtUsuario}    id=username
${PageIdTxtSenha}    id=password
${PageIdSelectEmpresa}    id=companies
${PageIdBtnLogin}    name=submit
${PageIClassListMenu}    class=nav
${imagens}            ${CURDIR}\\4-images
${arquivos_upload}    ${CURDIR}\\6-files

${btnExecutar}                          xpath=//li[@id='toolbar']//li[@id='tb-execute']//a
${so}      windows
${browser}        chrome
${ambiente}     qarelease
${url}          http://qarelease.mv.com.br:84/soul-mv/

${options}      add_argument("--disable-dev-shm-usage"); add_argument("--no-sandbox"); add_argument("--start-maximized")
${dadosLoginUsuarioQaRelease}    ANDRE.VASCONCELOS
${dadosLoginSenhaQaRelease}      12345678
${dadosLoginEmpresaQaRelease}    5 - HOSPITAL MV - MATRIZ
${IdIframe}           id=child_APOIO.HTML,ATEND.HTML,CONTR.HTML,DIAGN.HTML,FATUR-CONV.HTML,FATUR-SUS.HTML,FINAN.HTML,GLOBAL.HTML,INTER.HTML,PLANO.HTML,SUPRI.HTML               
${IdIframePagu}       id=child_PAGU.HTML




*** Keywords ***
Logar e Acessar a tela
    Nova sessao
    Acessar a tela "Faturamento>Faturamento de Convênios e Particulares>Lançamentos>Conta Hospitalar>Conta do Atendimento"

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
    [Arguments]    ${cdPaciente}    ${cdAtendimento}    ${nrConta}
    Log    ${cdPaciente}    ${cdAtendimento}    ${nrConta}
#implementar o download do relatorio

Acessar a tela "${caminhoSelecaoMenu}"
    Unselect Frame
    ${cont}    Set Variable    ${1}
    Click Element    ${HomeXpathBtnMenu}
    @{listaItensMenu}    Converte string em lista    ${caminhoSelecaoMenu}    >
    @{listaXpathItensMenu}    Criar Lista Itens Menu Xpath com Index    @{listaItensMenu}
    FOR    ${itemMenu}    IN    @{listaXpathItensMenu}
        ${visivel}   Run Keyword And Return Status    Wait Until Element Is Visible    xpath=${itemMenu}
        Log To Console    *** Visivel: ${visivel}
        ${classe}    Get Element Attribute    xpath=${itemMenu}/ancestor::li[1]    class
        Log To Console    *** Visivel: ${classe}
        IF    '${classe}' == 'menu-node'
            Seleciona item no menu    ${itemMenu}
        END
        Log To Console    *** Item ${itemMenu} selecionado no menu
        Log    *** Item ${itemMenu} selecionado no menu
    END
    Seleciona frame    ${IdIframe}    180
    Sleep    3

Seleciona item no menu
    [Arguments]    ${xpathTituloItemMenu}
    ${titleItemMenu}    Set Variable    xpath=${xpathTituloItemMenu}
    Wait Until Element Is Visible    ${titleItemMenu}    5
    # Realcar Elemento Execucao    ${titleItemMenu}
    Sleep    0.5
    Click Javascript    ${titleItemMenu}
    Sleep    2

Seleciona frame
    [Arguments]                      ${elementoFrame}    ${timeout}=${60}
    Wait Until Element Is Visible    ${elementoFrame}    ${timeout}          O elemento Frame ${elementoFrame} não foi carregado
    Wait Until Element Is Enabled    ${elementoFrame}    ${timeout}          O elemento Frame ${elementoFrame} não esta habilitado
    Select Frame                     ${elementoFrame}
    Sleep    3   


Realiza Login
    [Arguments]    ${usuario}    ${senha}    ${empresa}
    Wait Until Element Is Visible    ${PageIdTxtUsuario}    120    error=Erro ao efetuar o login
    Input Text    ${PageIdTxtUsuario}    ${usuario}
    Input Text    ${PageIdTxtSenha}    ${senha}
    Select From List By Label    ${PageIdSelectEmpresa}    ${empresa}
    # Capture Page Screenshot
    Click Button    ${PageIdBtnLogin}
    Wait Until Element Is Visible    ${PageIClassListMenu}    timeout=60    error=Erro ao efetuar o login
    Sleep    5


Nova sessao
    ${url}=      Set Variable If   %{DRY_RUN=${True}} == ${True}  ${url}    ${QA_ENVIROMENT} 

    Log                        *** Teste QA Environment: ${url}
    Log                        *** Teste no Sistema Operacional: ${so}
    Log To Console             *** Teste no Sistema Operacional: ${so}

    Open Browser               ${url}                                     ${browser}       options=${options}
    Add Cookie    las-uuid       2a603126-6068-4cfb-a00f-b79d6a7adc6d
    Add Cookie    las-host       http://127.0.0.1:32768 
    Maximize Browser Window
    Sleep    10

    Realiza Login    ${dadosLoginUsuarioQaRelease}      ${dadosLoginSenhaQaRelease}      ${dadosLoginEmpresaQaRelease}


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
                        Exit For Loop
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
    [Return]    @{novaListaItensMenu}


Converte string em lista
    [Arguments]    ${valor}        ${caracter}
    @{lista}       Split String    ${valor}       ${caracter}
    [Return]       @{lista}



Click Javascript
    [Arguments]                ${elemento}
    ${elemento2}               Get WebElement           ${elemento}
    Execute Javascript         arguments[0].click();    ARGUMENTS      ${elemento2}
    Capture Page Screenshot

    