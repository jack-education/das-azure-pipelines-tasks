$ENV:SYSTEM_CULTURE = "en-US"
Import-Module -Name $PSScriptRoot/modules/UnitTest.Helpers.psm1 -Force
Import-Module -Name $PSScriptRoot/../task/ps_modules/VstsTaskSdk -Force
Import-Module -Name $PSScriptRoot/../task/ps_modules/Handlers/Handlers.psm1 -Force
Import-Module -Name $PSScriptRoot/../task/InitializationHelpers.psm1 -Force

Initialize-TaskDependencies -Verbose:$VerbosePreference
 
InModuleScope "Handlers" {

    Describe "New-ConfigurationTableEntry tests" {

        BeforeAll {
            Set-MockEnvironment
        }
    
        AfterAll {
            Clear-MockEnvironment
        }

        $MockConfigurationEntity = Get-Content -Path "$PSScriptRoot/resource/SFA.DAS.Test.Valid.json" -Raw
        Mock Build-ConfigurationEntity {
            return $MockConfigurationEntity
        }

        Mock Test-ConfigurationEntity {
            return $null
        }

        Mock New-ConfigurationEntity {}

        $NewConfigurationTableEntryParameters = @{
            SourcePath = "$PSScriptRoot/resource"
            TargetFileName = "*.schema.json"
            StorageAccount = "mock-storage-account"
            EnvironmentName = "DEV"
        }

        Context "When passed a valid schema definition" {

            It "Should sucesfully create a new configuration entity" {
                { New-ConfigurationTableEntry @NewConfigurationTableEntryParameters } | Should Not Throw
                Assert-MockCalled -CommandName Build-ConfigurationEntity -Times 1
                Assert-MockCalled -CommandName Test-ConfigurationEntity -Times 1
                Assert-MockCalled -CommandName New-ConfigurationEntity -Times 1
            }

            It "Should throw an exception and stop processing if validation fails" {
                Mock Test-ConfigurationEntity {
                    throw "Validation failed"
                }

                { New-ConfigurationTableEntry @NewConfigurationTableEntryParameters } | Should Throw "Validation failed"
                Assert-MockCalled -CommandName Build-ConfigurationEntity -Times 1
                Assert-MockCalled -CommandName Test-ConfigurationEntity -Times 1
            }
        }

        Context "When building a configuration entity fails" {

            Mock Build-ConfigurationEntity {
                throw "Failed to build configuration entity"
            }

            It "Should throw an exception and stop processing" {
                { New-ConfigurationTableEntry @NewConfigurationTableEntryParameters } | Should Throw "Failed to build configuration entity"
                Assert-MockCalled -CommandName Build-ConfigurationEntity -Times 1
                Assert-MockCalled -CommandName Test-ConfigurationEntity -Times 0
                Assert-MockCalled -CommandName New-ConfigurationEntity -Times 0
            }
        }

        Context "When persisting an entity fails" {

            Mock New-ConfigurationEntity {
                throw "Failed to create entity"
            }

            It "Should throw and stop processing" {
                { New-ConfigurationTableEntry @NewConfigurationTableEntryParameters } | Should Throw "Failed to create entity"
                Assert-MockCalled -CommandName Build-ConfigurationEntity -Times 1
                Assert-MockCalled -CommandName Test-ConfigurationEntity -Times 1
                Assert-MockCalled -CommandName New-ConfigurationEntity -Times 1
            }
        }
    }
}