
# Import class
Using module C:\Git_Repositories\Performance-Tools\HandleReports\HandleReports.psm1

# This test script uses Pester version 4+
# To upgrade, run:
# Set-ExecutionPolicy Unrestricted
# Install-Module -Name Pester -Force -SkipPublisherCheck

# $ScriptPath = Split-Path $MyInvocation.MyCommand.Path
# Import-Module $ScriptPath\HandleReports\HandleReports.psm1


$MyLinters = @("prospector", "pylint")
$MyRepos = "C:\Git_Repositories"
$MyReports = "C:\Git_Repositories\Performance-Tools\Linter-reports"
$MySources = @("NNEDL-CORE-TEST\tests\lambda_tests",
               "NNEDL-CORE-TEST\tests\flow_tests",
               "NNEDL-CORE-TEST\tests\api_tests",
               "NNEDL-CORE-GLOBAL\lambdas",
               "NNEDL-CORE-REGIONAL\glue_scripts",
               "NNEDL-CORE-REGIONAL\lambdas"
)

$MyHandlePaths = $false
$MyDebug = $false
$MyGitPull = $false
$MyShowPythonFiles = $true
$MyCreateReports = $false
$MyDeleteReports = $false


$MyTimestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
$MyHash = @{}

$MyCodeReview = [CodeReview]::new($MyTimestamp,
                                  $MyLinters,
                                  $MyRepos,
                                  $MyReports,
                                  $MySources,
                                  $MyHandlePaths,
                                  $MyDebug,
                                  $MyGitPull,
                                  $MyShowPythonFiles,
                                  $MyCreateReports,
                                  $MyDeleteReports,
                                  $MyHash
                                  )

$MyCodeReview.main()

# Write-Host $MyCodeReview.timestamp
# Write-Host $MyCodeReview.linters
# Write-Host $MyCodeReview.repos
# Write-Host $MyCodeReview.reports
# Write-Host $MyCodeReview.sources
# Write-Host $MyCodeReview.handlePaths
# Write-Host $MyCodeReview.gitPull
# Write-Host $MyCodeReview.showPythonFiles
# Write-Host $MyCodeReview.createReports
# Write-Host $MyCodeReview.deleteReports
# $MyCodeReview.hash | ForEach-Object { $_ }


Describe "Check HandleReports" {

  context "Check that paths are valid" {

    It 'Should point to valid source directories' {
      Foreach ($h in $MyCodeReview.hash.GetEnumerator()) {
        (Test-Path $h.Name) | Should -BeTrue
      }
    }

    It 'Should have 6 key-values for the source-target mappings' {
      $MyCodeReview.hash.count | Should -Be 6
    }

    If ($MyCodeReview.createReports) {
      It 'Should point to valid target directories' {
        Foreach ($h in $MyCodeReview.hash.GetEnumerator()) {
          (Test-Path $h.Value) | Should -BeTrue
        }
      }
    }

  }

}
