*** Settings ***
Library             String
Library             RPA.FileSystem

*** Keywords ***
Get File Name
    [Arguments]    ${pathFile}
    # Verifica se existe apenas um arquivo na pasta
    ${files}    RPA.FileSystem.List Files In Directory    ${pathFile}
    ${fileCount}    Get Length    ${files}

    IF    ${fileCount} != ${1}    Fail    Arquivo PDF não foi localizado     # Metodo CSV

    ${files}    Convert To String    ${files}
    ${attrFile}    Split String    ${files}    ,
    ${fileName}    Replace String    ${attrFile}[1]    name='    ${EMPTY}
    ${fileName}    Replace String    ${fileName}    '    ${EMPTY}
    ${fileName}    Set Variable    ${fileName.strip()}

    [Return]    ${fileName}