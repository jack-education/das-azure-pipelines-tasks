Import-Module -Name $PSScriptRoot/modules/UnitTest.Helpers.psm1 -Force -Global

InModuleScope "Handlers" {

    Describe "Build-ConfigurationEntity tests" {

        BeforeAll {
            Set-MockEnvironment
            Add-DefaultMocks
        }
    
        AfterAll {
            Clear-MockEnvironment
        }

        Mock Expand-Schema {
            return @{ }
        }

        $SchemaDefinition = "$PSScriptRoot/resource/SFA.DAS.Test.schema.json"

        Context "When passed an invalid schema definition" {
            
            Mock Get-Content {
                return "not a schema"
            }

            It "Should throw an exception" {
                { Build-ConfigurationEntity -SchemaDefinition $SchemaDefinition } | Should Throw
                Assert-MockCalled -CommandName Expand-Schema -Times 0
            }
        }

        Context "When passed a valid schema definition" {

            It "Should build a configuration entity from the schema definition and environment variables" {
                { Build-ConfigurationEntity -SchemaDefinition $SchemaDefinition } | Should Not Throw
                Assert-MockCalled -CommandName Expand-Schema -Times 1
            }
        }
    }    
}