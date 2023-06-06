*** Settings ***
Library             RPA.FileSystem
Library             OperatingSystem
Library             DateTime
Library             RPA.Browser.Selenium

*** Keywords ***
Log CSV
    [Arguments]    ${cdAtendimento}    ${nrConta}    ${filePdfName}    ${pathCsv}    ${status}

    ${date}    Get Current Date    result_format=%d-%m-%Y-%H:%M:%S

    # Verifica se já existe o arquivo RELATORIO_ENVIOS.csv
    ${createdCsv}    Run Keyword And Return Status
    ...    File Should Exist
    ...    ${pathCsv}\\resources\\CSV\\RELATORIO_ENVIOS.csv

    # Cria arquivo se não existir
    IF    ${createdCsv} != ${True}
        RPA.FileSystem.Create File    ${pathCsv}\\resources\\CSV\\RELATORIO_ENVIOS.csv
        RPA.FileSystem.Append To File
        ...    ${pathCsv}\\resources\\CSV\\RELATORIO_ENVIOS.csv
        ...    cod_paciente,cod_atendimento,nr_conta,arquivo,data_envio,status_envio,msg_envio\n
    END

    # Cria novo registo
    IF    ${status}
        ${csvData}    Convert To String    ${cdAtendimento},${nrConta},${filePdfName},${date},Sucesso,Arquivo enviado
    ELSE
        ${csvData}    Convert To String    ${cdAtendimento},${nrConta},${filePdfName},${date},Falha,Arquivo não foi enviado
    END

    # Adiciona novo registro ao arquivo
    RPA.FileSystem.Append To File    ${pathCsv}\\resources\\CSV\\RELATORIO_ENVIOS.csv   ${csvData}\n


ReadS CSV file
    [Arguments]    ${pathCsv}    ${atendimento}
    ${csv}=    Get File    ${pathCsv}\\resources\\CSV\\RELATORIO_ENVIOS.csv
    @{read}=    Create List    ${csv}
    Log    @{read}
    @{lines}=    Split To Lines    @{read}    1

    FOR    ${line_csv}    IN    @{lines}
        #Log    @{lines}
        Log    ${line_csv}
        Log    @{lines}[1]
        Log    @{line_csv}[1]

        ${EXIST}    Run Keyword And Return Status    Should Be Equal    ${line_csv}[0]    ${atendimento}
        Log To Console    Atendimento já integrado ${line_csv}[0]
    END