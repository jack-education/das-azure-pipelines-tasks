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
    $ENV:PaymentsArray = "['one', 'two', 'three']"
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
        "ENV:PaymentsArray"
    )
}

function Add-DefaultMocks {
    Mock Get-AzResource {
        return @{
            ResourceGroupName = "mock-resource-group"
        }
    }
    
    Mock Get-AzStorageAccountKey {
        $MockKeysArray = @(
            @{
                KeyName = "key1"
                Value = "bW9jayBzdG9yYWdlIGFjY291bnQga2V5IG5vdGhpbmcgdG8gc2VlIGhlcmUgMQ=="
                Permissions = "Full"
            },
            @{
                Key1 = "key2"
                Value = "bW9jayBzdG9yYWdlIGFjY291bnQga2V5IG5vdGhpbmcgdG8gc2VlIGhlcmUgMg=="
                Permissions = "Full"
            }
        )
        return $MockKeysArray
    }

    Mock Get-AzStorageTable {
        return @{ }
    }

    Mock New-AzStorageTable {
        return @{ }
    }

    Mock Get-TableEntity {
        return @{ }
    }

    Mock New-TableEntity {
        return @{ }
    }

    Mock Set-TableEntity {
        return @{ }
    }

    Mock Write-Host {
        
    }

}

Export-ModuleMember -Function @(
    'Set-MockEnvironment',
    'Clear-MockEnvironment',
    'Add-DefaultMocks'
)

