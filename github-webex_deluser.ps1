﻿Param (
       [Parameter(mandatory=$true)][boolean]$RunEnabled,
       [Parameter(mandatory=$true)][string]$user_WebexUserID
)

#region Webex Login
$WebExSiteName = "WebexSiteName"
$WebExSiteID = "WebexSiteID"
$WebExPartnerID = "WebexPartnerID"
$WebExServiceAccountName = "WebexAdminID"
$WebExServiceAccountPassword = "Password"
#endregion

if ($RunEnabled -eq $true) {
    #region XML Request
    # XML Body Request
    $XML =[xml]"<?xml version=""1.0"" encoding=""UTF-8"" ?>
    <serv:message xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance""
    xmlns:serv=""http://www.webex.com/schemas/2002/06/service"">
    <header>
        <securityContext>
            <webExID>$WebExServiceAccountName</webExID>
            <password>$WebExServiceAccountPassword</password>
            <siteID>$WebExSiteID</siteID>
            <partnerID>$WebExPartnerID</partnerID>
        </securityContext>
    </header>
    <body>
        <bodyContent xsi:type=""java:com.webex.service.binding.user.DelUser"">
            <webExId>$user_WebexUserID</webExId>
        </bodyContent>
    </body>
    </serv:message>"

    # WebEx XML API URL 
    $URL = "https://$WebExSiteName/WBXService/XMLService"

    # Send WebRequest and save to URLResponse
    try {
        $URLResponse = Invoke-WebRequest -Uri $URL -Method Post -ContentType 'text/xml' -TimeoutSec 120 -Body $XML
        Write-Host "Webex: Inactivated $user_WebexUserID"
    } catch {
        Write-Host "Webex: Unable to send XML request"
    }
    #endregion
    
    #region XML Response
    $XMLResponse = [xml]$URLResponse

    # Response Result and Reason from XML
    if ($XMLResponse.ChildNodes.header.response.result -eq "SUCCESS"){
        Write-Host "Webex Result: "$XMLResponse.ChildNodes.header.response.result
        Write-Host "Webex: Inactivated user [$user_WebexUserID]"
    } else {
        Write-Host "Webex Result: "$XMLResponse.ChildNodes.header.response.result
    }

    if ($XMLResponse.ChildNodes.header.response.reason) {
        Write-Host "Webex Reason: "$XMLResponse.ChildNodes.header.response.reason
    }
    #endregion
}
