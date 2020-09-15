# Usage, from anaconda prompt: powershell ./get_linter_reports.ps1

$source_path = "C:\Git_Repositories\Git_Repository"
$target_path = "C:\Users\$env:UserName\Desktop\lint_reports_Git_Repository"

$debug = $false
$showPythonFiles = $false
$createReports = $true


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


function show_python_files($source_path, $target_path) {
    # List all files in folder, recursively, and sort by filesize
    Get-ChildItem -Path $source_path -Recurse -File -Filter *.py |
      Sort-Object length -Descending |
      ForEach-Object { $_.Name
        "$target_path\pylint_results_$($_.Name.TrimEnd(".py")).txt"
        "$target_path\prospector_results_$($_.Name.TrimEnd(".py")).txt"
      }
}


function create_reports($source_path, $target_path) {
    # Get all Python modules in folder and generate Pylint and prospector reports
    Write-Host "`r`nGenerating linter reports`r`n"
    Write-Host "`r`nPath to source files: $source_path`r`n"
    Write-Host "Path to target files: $target_path"

    Get-ChildItem -Path $source_path -Recurse -Filter *.py |
      ForEach-Object { 
                       prospector $_.FullName |
                       Out-File -FilePath "$target_path\prospector_results_$($_.BaseName).txt"
                      
                       pylint $_.FullName |
                       Out-File -FilePath "$target_path\pylint_results_$($_.BaseName).txt"
                      }
  }


if ($debug) {
    debug_linting
}

if ($showPythonFiles) {
    show_python_files -source_path $source_path
}

if ($createReports) {
    create_reports -source_path $source_path -target_path $target_path
}
