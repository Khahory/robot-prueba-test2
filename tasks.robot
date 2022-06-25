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
    Click Button    Order
    Wait Until Keyword Succeeds    30    0.5    Submit the order
        Wait Until Element Is Not Visible    alert alert-danger


Store the receipt as a PDF file
    [Arguments]    ${Order number}
    ${receipt_result_html}=        Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_result_html}    ${OUTPUT_DIR}${/}${Order number}-receipt.pdf
    [Return]    ${Order number}
        


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
    #     ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
    #     Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
    #     Go to order another robot
    END
    # Create a ZIP file of the receipts

