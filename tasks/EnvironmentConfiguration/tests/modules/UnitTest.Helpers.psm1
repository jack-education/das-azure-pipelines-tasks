function Set-MockEnvironment {
    $ENV:SYSTEM_CULTURE = "en-US"
    $ENV:AGENT_VERSION = "2.152.1"
    $ENV:AGENT_PROXYURL = "https://dummy.com"
    $ENV:AGENT_PROXYUSERNAME = "dummy"
    $ENV:AGENT_PROXYPASSWORD = "dummy"
    $ENV:AGENT_PROXYBYPASSLIST = "[]"
    $ENV:EventsApiBaseUrl = "https://events.test.com"
    $ENV:EventsApiClientToken = "xxxxxxxxxxlksmdflkm3lkmlkm"
    $ENV:PaymentsEnabled = "true"
    $ENV:PaymentsBool = "true"
    $ENV:PaymentsString = "string"
    $ENV:PaymentsInt = "1"
    $ENV:PaymentsNumber = "1.0"
    $ENV:PaymentsArray = @"
    ["one","two","three"]
"@
    $ENV:PaymentsObjectArray = @"
    [{"Enabled": true, "aString": "string"}]
"@
    $ENV:GoogleHeaderUrl = "'https://www.googletagmanager.com/gtm.js?id='wrappedinquotes'&gtm_auth=someauth&gtm_preview=env-7&gtm_cookies_win=x'"
}

function Clear-MockEnvironment {
    Remove-Item -Path @(
        "ENV:SYSTEM_CULTURE",
        "ENV:AGENT_VERSION",
        "ENV:AGENT_PROXYURL",
        "ENV:AGENT_PROXYUSERNAME",
        "ENV:AGENT_PROXYPASSWORD",
        "ENV:AGENT_PROXYBYPASSLIST",
        "ENV:EventsApiBaseUrl",
        "ENV:EventsApiClientToken",
        "ENV:PaymentsEnabled",
        "ENV:PaymentsInt",
        "ENV:PaymentsNumber",
        "ENV:PaymentsArray",
        "ENV:GoogleHeaderUrl"
    )
}

function Add-DefaultMocks {

    Mock Trace-VstsLeavingInvocation {
    }

    Mock Trace-VstsEnteringInvocation {
    }

    Mock Write-Host {

    }

}

Export-ModuleMember -Function @(
    'Set-MockEnvironment',
    'Clear-MockEnvironment',
    'Add-DefaultMocks'
)

