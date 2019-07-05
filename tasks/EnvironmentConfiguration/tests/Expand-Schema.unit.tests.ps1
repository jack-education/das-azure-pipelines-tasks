InModuleScope "Handlers" {

    Describe "Expand-Schema tests" {

        BeforeAll {
            Set-MockEnvironment
            Add-DefaultMocks
        }

        AfterAll {
            Clear-MockEnvironment
        }

        Mock Get-SchemaProperty {
            return "mock"
        }

        $SchemaDefinitionPath = "$PSScriptRoot/resource/SFA.DAS.Test.schema.json"
        $SchemaDefinition = Get-Content -Path $SchemaDefinitionPath -Raw
        $SchemaObject = [Newtonsoft.Json.Schema.JSchema, Newtonsoft.Json.Schema, Version = 2.0.0.0, Culture = neutral, PublicKeyToken = 30ad4fe6b2a6aeed]::Parse($SchemaDefinition)

        Context "When passed a valid schema definition" {

            It "Should process each defined type succesfully" {
                Expand-Schema -PropertyObject $SchemaObject.Properties
                Assert-MockCalled -CommandName Get-SchemaProperty -Times 1
                Assert-MockCalled -CommandName Get-SchemaProperty -ParameterFilter { $AsArray -eq $true } -Times 1
                Assert-MockCalled -CommandName Get-SchemaProperty -ParameterFilter { $AsInt -eq $true } -Times 1
                Assert-MockCalled -CommandName Get-SchemaProperty -ParameterFilter { $AsNumber -eq $true } -Times 1
                Assert-MockCalled -CommandName Get-SchemaProperty -ParameterFilter { $AsBool -eq $true } -Times 1
            }

            It "Should return a hashtable" {
                Expand-Schema -PropertyObject $SchemaObject.Properties | Should BeOfType hashtable
            }
        }
    }
}
