InModuleScope "Handlers" {

    Describe "Test-ConfigurationEntity tests" {

        BeforeAll {
            Set-MockEnvironment
            Add-DefaultMocks
        }

        AfterAll {
            Clear-MockEnvironment
        }

        $SchemaDefinition = "$PSScriptRoot/resource/SFA.DAS.Test.schema.json"
        $ValidConfiguration = Get-Content -Path "$PSScriptRoot/resource/SFA.DAS.Test.Valid.json" -Raw
        $InvalidConfiguration = Get-Content -Path "$PSScriptRoot/resource/SFA.DAS.Test.Invalid.json" -Raw

        Context "When the configuration passed matches the schema definition" {

            It "Should validate succesfully and not throw an exception" {
                { Test-ConfigurationEntity -Configuration $ValidConfiguration -SchemaDefinitionPath $SchemaDefinition } | Should Not Throw
            }
        }

        Context "When the configuration passed does not match the schema definition" {

            It "Should fail to validate and throw an exception" {
                { Test-ConfigurationEntity -Configuration $InvalidConfiguration -SchemaDefinitionPath $SchemaDefinition } | Should Throw
            }
        }
    }
}
