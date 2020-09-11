# Usage, from anaconda prompt: powershell ./get_linter_reports.ps1

$folders = @("C:\Users\$env:UserName\Desktop\my_project_folder\linter_reports",
             "C:\Git_Repositories\my_repo"
)

$debug = $false
$showPythonFiles = $true
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


function show_python_files($path_to_files) {
    # List all files in folder, recursively, and sort by filesize
    Get-ChildItem -Path $path_to_files -Recurse -File -Filter *.py |
      Sort-Object length -Descending | ForEach-Object { $_.Name  }
}


function create_reports($path_to_files) {
    # Get all Python modules in folder and generate Pylint and prospector reports

    Write-Host "`r`nGenerating linter reports`r`n"
    Write-Host "Path to files: " $path_to_files

    Get-ChildItem -Path $path_to_files -Recurse -Filter *.py |
      ForEach-Object { pylint $_.Name |
                       Out-File -FilePath "pylint_results_$($_.Name.TrimEnd(".py")).txt"

                       prospector $_.Name |
                       Out-File -FilePath "prospector_results_$($_.Name.TrimEnd(".py")).txt"
                      }
  }


if ($debug) {
    debug_linting
}

if ($showPythonFiles) {
    show_python_files -path_to_files $folders[0]
}

if ($createReports) {
    create_reports -path_to_files $folders[0]
}
