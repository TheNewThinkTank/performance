# Usage, from anaconda prompt: powershell ./get_linter_reports.ps1

$folders = @("C:\Users\my_user_name\Desktop\my_project_folder\linter_reports",
             "C:\Git_Repositories\my_repository"
)

$path_to_files = $folders[1]

Write-Host "`r`nGenerating linter reports`r`n"
Write-Host "Path to files: " $path_to_files

# One hardcoded module
# pylint read_parquet.py | Out-File -FilePath .\results_of_all_modules.txt  # Works!

# One result file for everything
# pylint $args | Out-File -FilePath .\results_of_all_modules.txt  # Works!

# One result file per module
<#
Foreach ($module in $args){
  pylint $module | Out-File -FilePath .\"results_$module.txt"
}
#>

# List all files in folder ,recursively, and sort by filesize
# Get-ChildItem -Path $path_to_files -Recurse -File -Filter *.py |
#   sort length -Descending | ForEach-Object { $_.Name  }


# Get all Python modules in folder and generate Pylint reports
Get-ChildItem -Path $path_to_files -Recurse -Filter *.py |
  sort length -Descending |
  ForEach-Object { pylint $_.Name |
                   Out-File -FilePath .\"pylint_results_$($_.Name.TrimEnd(".py")).txt"
                   }


# Get all Python modules in folder and generate Prospector reports
Get-ChildItem -Path $path_to_files -Recurse -Filter *.py |
  sort length -Descending |
  ForEach-Object { prospector $_.Name |
                   Out-File -FilePath .\"prospector_results_$($_.Name.TrimEnd(".py")).txt"
                   }


<#
Get-ChildItem -Path $path_to_files -File -Recurse -Filter *.py |
  Tee-Object ForEach-Object { pylint $_.Name |
                   Out-File -FilePath .\"pylint_results_$($_.Name.TrimEnd(".py")).txt"
                   } |
             ForEach-Object { prospector $_.Name |
                   Out-File -FilePath .\"prospector_results_$($_.Name.TrimEnd(".py")).txt"
                   }
#>
