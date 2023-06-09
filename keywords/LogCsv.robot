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
    ...    ${pathCsv}

    # Cria arquivo se não existir
    IF    ${createdCsv} != ${True}
        RPA.FileSystem.Create File    ${pathCsv}
        RPA.FileSystem.Append To File
        ...    ${pathCsv}
        ...    cod_atendimento,nr_conta,arquivo,data_envio,status_envio,msg_envio\n
    END


    # Cria novo registo
    IF    ${status}
        ${csvData}    Convert To String    ${cdAtendimento},${nrConta},${filePdfName},${date},Sucesso,Arquivo enviado
    ELSE
        ${csvData}    Convert To String    ${cdAtendimento},${nrConta},${filePdfName},${date},Falha,Arquivo não foi enviado
    END

    # Adiciona novo registro ao arquivo
    RPA.FileSystem.Append To File    ${pathCsv}   ${csvData}\n
