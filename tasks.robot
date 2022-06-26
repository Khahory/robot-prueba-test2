*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library    RPA.Browser.Selenium
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.PDF

*** Variables ***
${GLOBAL_RETRY_AMOUNT}=         10x
${GLOBAL_RETRY_INTERVAL}=       1s

*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order


Get orders
    # Download    https://robotsparebinindustries.com/orders.csv    overwrite=true
    ${orders}=    Read table from CSV    orders.csv
    [Return]    ${orders}


Close the annoying modal
    Click Button    OK


Fill the form
    [Arguments]    ${row}
    Select From List By Index    id:head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    class:form-control    ${row}[Legs]
    Input Text    id:address    ${row}[Address]


Preview the robot
    Click Button    Preview
    Wait Until Page Contains Element    id:robot-preview-image

    
Submit the order
    Click Button    id:order
    # si id:receipt es visible, dejaras de esperar
    Wait Until Element Is Visible    id:receipt


Store the receipt as a PDF file
    [Arguments]    ${Order number}
    Wait Until Element Is Visible    id:receipt
    ${receipt_result_html}=        Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_result_html}    ${OUTPUT_DIR}${/}${Order number}-receipt.pdf
    [Return]    ${OUTPUT_DIR}${/}${Order number}-receipt.pdf
        

Retry submitting order
    Wait Until Keyword Succeeds   5x    1s    Submit the order

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Retry submitting order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
    #     ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
    #     Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
    #     Go to order another robot
    END
    # Create a ZIP file of the receipts

