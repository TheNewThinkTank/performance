# Usage, from anaconda prompt: powershell ./get_linter_reports.ps1

# Insert your folderpaths here, examples provided:
$folders = @("C:\Users\$env:UserName\Desktop\my_project_folder\linter_reports",
             "C:\Git_Repositories\my_repo"
)

$path_to_files = $folders[1]

Write-Host "`r`nGenerating linter reports`r`n"
Write-Host "Path to files: " $path_to_files

# Get all Python modules in folder and generate Pylint and prospector reports
Get-ChildItem -Path $path_to_files -Recurse -Filter *.py |
  ForEach-Object { pylint $_.Name |
                   Out-File -FilePath "pylint_results_$($_.Name.TrimEnd(".py")).txt"

                   prospector $_.Name |
                   Out-File -FilePath "prospector_results_$($_.Name.TrimEnd(".py")).txt"
                   }
