# Usage, from anaconda prompt: powershell ./get_pylint_report.ps1 module_name1 module_name2 etc...

Write-Host "Generating Pylint reports"

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
Get-ChildItem -Path "C:\Users\gtrm\Desktop\MyScripts\Pylint_reports" -Recurse -File -Filter *.py |
  sort length -Descending | ForEach-Object { $_.Name  }


# Get all Python modules in folder and generate Pylint reports
Get-ChildItem -Path "C:\Users\gtrm\Desktop\MyScripts\Pylint_reports" -Recurse -File -Filter *.py |
  sort length -Descending |
  ForEach-Object { pylint $_.Name |
                   Out-File -FilePath .\"results_$($_.Name.TrimEnd(".py")).txt"
                   }
