<#

    .SYNOPSIS
        Author: Gustav Rasmussen
        Date: 2020-09-16
        Automation of the code review process.

    .DESCRIPTION
        Automation of the code review process is done by scripting static code analysis
        and report generation.

    .PARAMETER linters
        Array of linters to inspect program files (Python, JavaScript etc.) with.

    .PARAMETER repos
        Path to your local clones of Git repositories to be linted.

    .PARAMETER reports
        Path where the reports will be stored.

    .PARAMETER hash
        Mapping between source and target directories.

    .PARAMETER handlePaths
        Ensure that paths are valid, and create target diractories if necessary.

    .PARAMETER debug
        Test this program.

    .PARAMETER gitPull
        Ensure that you are linting the latest version of the code-base.

    .PARAMETER showPythonFiles
        Perform a dry-run before modifying the file system.

    .PARAMETER createReports
        Generate text file report for each program file specified in the source paths.

    .PARAMETER deleteReports
        Clean-up the report folders when they get too cluttered, or reports are too old.

    .INPUTS
        None

    .OUTPUTS
        linter reports as text-files.

    .EXAMPLE
        From cmd/anaconda prompt: powershell ./get_linter_reports.ps1

    .LINK
        https://github.com/TheNewThinkTank/performance

    .NOTES
        By tuning the Boolean parameters, you can achieve the following:
          Set up folder structure
          debug script
          pull latest commit using git
          show code files
          create reports
          delete reports

#>

$python_linters = @("prospector", "pylint")  # "Coala", "SonarCube"
# $javascript_linters = @("JSLint", "JSHint", "ESLint")
$linters = $python_linters

$repos = "Git_Repositories"
$reports = "Git_Repositories\Performance-Tools\Linter-reports"
$hash = [ordered]@{ "$repos\MyRepo1\subfolder1\subsub1" = "$reports\MyRepo1\subfolder1\subsub1"
                    "$repos\MyRepo1\subfolder1\subsub2" = "$reports\MyRepo1\subfolder1\subsub2"
                    "$repos\MyRepo2\subfolder1" = "$reports\MyRepo2\subfolder1"
                  }

$handlePaths = $true
$debug = $false
$gitPull = $true
$showPythonFiles = $false
$createReports = $true
$deleteReports = $false

$timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }


function handle_paths($hash) {
    # Error handling for the source path
    foreach ($h in $hash.GetEnumerator()) {
      If (Test-Path $h.Name) {
        Write-Host "`r`nPath to source files: $($h.Name)`r`n"
      }
      Else {
        Write-Host "Invalid source_path!"
        Exit
      }
      # If target path does not exist, create it
      If (-Not (Test-Path $h.Value)) {
        mkdir $h.Value
        # Verify that the target path now exists
        If (Test-Path $h.Value) {
            Write-Host "`r`nPath to target files: $($h.Value)`r`n`r`n"
        }
        Else {
          Write-Host "Invalid target_path!"
          Exit
        }
      }
    }
}


function debug_linting() {
    # One hardcoded module
    pylint read_parquet.py | Out-File -FilePath .\results_of_all_modules.txt

    # One result file for everything
    pylint $args | Out-File -FilePath .\results_of_all_modules.txt

    # One result file per module
    Foreach ($module in $args){
      pylint $module | Out-File -FilePath .\"results_$module.txt"
    }
}


function git_pull($hash) {
  # Get unique repo name from hash
  $repo_names = @()
  foreach ($h in $hash.GetEnumerator()) {
    $repo_names += $h.Name.split("\")[0..2] -join "\"    
  }
  $unique_repos = $repo_names | Get-Unique

  # Pull the latest changes from origin master
  foreach ($unique_repo in $unique_repos) {
    Write-Host "Changing directory to: $unique_repo"
    Set-Location $unique_repo
    Git pull
  }

  # Changing directory back to $repos
  Set-Location $repos
}


function show_python_files($hash) {
    # List all Python files in folders, recursively, and sort by filesize
    Foreach ($h in $hash.GetEnumerator()) {
      Foreach ($linter in $linters) {
        Get-ChildItem -Path $h.Name -Recurse -File -Filter *.py |
          Sort-Object length -Descending |
            ForEach-Object {
              "$($h.Value)\$($linter)_results_$($_.BaseName).txt"
            }
      }
    }
}


function create_reports($hash) {
    # Get all Python modules in folder and generate Pylint and prospector reports

    $counter = 0
    Foreach ($h in $hash.GetEnumerator()) {
      
      $counter++
      Write-Progress -Activity 'Processing code:' -CurrentOperation $h.Name -PercentComplete (
        ($counter / $hash.count) * 100)
      Start-Sleep -Milliseconds 200

      Foreach ($linter in $linters) {
        Get-ChildItem -Path $h.Name -Recurse -Filter *.py |
          ForEach-Object {
            Invoke-Expression "$linter $($_.FullName)" |
              Out-File -FilePath "$($h.Value)\$($linter)_results_$($_.BaseName)_$timestamp.txt"
            }
        }
      }

      Write-Host "`r`nGenerated linter reports`r`n"

  }


function delete_reports($hash) {
  Write-Host "`r`nDeleting linter reports`r`n"
  Foreach ($h in $hash.GetEnumerator()) {
    Write-Host "Deleting files in: $($h.Value)"
    Remove-Item "$($h.Value)\*.txt*"
  }
}


function main {

  If ($handlePaths) {
    handle_paths -hash $hash
  }

  If ($debug) {
      debug_linting
  }

  If ($gitPull) {
    git_pull -hash $hash
  }

  If ($showPythonFiles) {
      show_python_files -hash $hash
  }
  
  If ($createReports) {
      create_reports -hash $hash
  }
  
  If ($deleteReports) {
    delete_reports -hash $hash
  }

}


main
