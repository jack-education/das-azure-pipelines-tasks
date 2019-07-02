InModuleScope "Handlers" {

    Describe "Expand-Schema tests" {

        BeforeAll {
            Set-MockEnvironment
            Add-DefaultMocks
        }
    
        AfterAll {
            Clear-MockEnvironment
        }

        Mock Get-VstsTaskVariable { return "default-string" }
        Mock Get-VstsTaskVariable { return 1 } -ParameterFilter { $AsInt -eq $true }
        Mock Get-VstsTaskVariable { return $true } -ParameterFilter { $AsBool -eq $true }

        $SchemaDefinitionPath = "$PSScriptRoot/resource/SFA.DAS.Test.schema.json"
        $SchemaDefinition = Get-Content -Path $SchemaDefinitionPath -Raw
        $SchemaObject = [Newtonsoft.Json.Schema.JSchema, Newtonsoft.Json.Schema, Version = 3.0.0.0, Culture = neutral, PublicKeyToken = 30ad4fe6b2a6aeed]::Parse($SchemaDefinition)


        Context "When given a valid properties object" {

            It "Should return a string when no parameters are passed" {

                $Property = Get-SchemaProperty -PropertyObject $SchemaObject.Properties["PaymentsString"]
                $Property.GetType() | Should Be "String"
                Assert-MockCalled -CommandName Get-VstsTaskVariable -Times 1
            }

            It "Should return an int when -AsInt is passed" {

                $Property = Get-SchemaProperty -PropertyObject $SchemaObject.Properties["PaymentsInt"] -AsInt
                $Property.GetType() | Should Be "Int"
                Assert-MockCalled -CommandName Get-VstsTaskVariable -ParameterFilter { $AsInt -eq $true } -Times 1
            }

            It "Should return a decimal when -AsNumber is passed" {

                Mock Get-VstsTaskVariable { return "1.0" }
                $Property = Get-SchemaProperty -PropertyObject $SchemaObject.Properties["PaymentsNumber"] -AsNumber
                $Property.GetType() | Should Be "Decimal"
                Assert-MockCalled -CommandName Get-VstsTaskVariable -Times 1
            }

            It "Should return an array when -AsArray is passed" {

                Mock Get-VstsTaskVariable { return (@("one","two", "three")| ConvertTo-Json) }
                $Property = Get-SchemaProperty -PropertyObject $SchemaObject.Properties["PaymentsArray"] -AsArray
                $Property.GetType().BaseType.Name | Should Be "Array"
                Assert-MockCalled -CommandName Get-VstsTaskVariable -Times 1
            }

            It "Should return an bool when -AsBool is passed" {

                $Property = Get-SchemaProperty -PropertyObject $SchemaObject.Properties["PaymentsBool"] -AsBool
                $Property.GetType() | Should Be "Bool"
                Assert-MockCalled -CommandName Get-VstsTaskVariable -ParameterFilter { $AsBool -eq $true } -Times 1
            }

            It "Should return the default value if no environment variable can be found and the default property is populated" {

                Mock Get-VstsTaskVariable { return $null }
                $Property = Get-SchemaProperty -PropertyObject $SchemaObject.Properties["PaymentsDefaultValue"]
                $Property | Should Be "default-value"
                Assert-MockCalled -CommandName Get-VstsTaskVariable -Times 5
            }

            It "Should throw an exception if no value can be found" {

                Mock Get-VstsTaskVariable { return $null }
                { Get-SchemaProperty -PropertyObject $SchemaObject.Properties["PaymentsString"] } | Should Throw
                Assert-MockCalled -CommandName Get-VstsTaskVariable -Times 5
            }
        }
    }    
}