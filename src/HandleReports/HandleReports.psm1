
class CodeReview {
  [string] $timestamp
  [array] $linters
  [string] $repos
  [string] $reports
  [array] $sources
  [bool] $handlePaths
  [bool] $debug
  [bool] $gitPull
  [bool] $showPythonFiles
  [bool] $createReports
  [bool] $deleteReports
  [hashtable] $hash

  CodeReview ([string] $timestamp,
              [array] $linters,
              [string] $repos,
              [string] $reports,
              [array] $sources,
              [bool] $handlePaths,
              [bool] $debug,
              [bool] $gitPull,
              [bool] $showPythonFiles,
              [bool] $createReports,
              [bool] $deleteReports,
              [hashtable] $hash)
    {
    $this.timestamp = $timestamp
    $this.linters = $linters
    $this.repos = $repos
    $this.reports = $reports
    $this.sources = $sources
    $this.handlePaths = $handlePaths
    $this.debug = $debug
    $this.gitPull = $gitPull
    $this.showPythonFiles = $showPythonFiles
    $this.createReports = $createReports
    $this.deleteReports = $deleteReports
    $this.hash = $hash
    foreach ($source in $this.sources) {
      $hash.Add("$($this.repos)\$source", "$($this.reports)\$source")
    }
  }

  [void] handle_paths() {
    # Error handling for the source path
    foreach ($h in $this.hash.GetEnumerator()) {
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

  [void] debug_linting() {
      # One hardcoded module
      pylint read_parquet.py | Out-File -FilePath .\results_of_all_modules.txt

      # One result file for everything
      # pylint $args | Out-File -FilePath .\results_of_all_modules.txt

      # One result file per module
      # Foreach ($module in $args){
        # pylint $module | Out-File -FilePath .\"results_$module.txt"
      # }
  }

  [void] git_pull() {
    # Get unique repo name from hash
    $repo_names = @()
    foreach ($h in $this.hash.GetEnumerator()) {
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
    Set-Location $this.repos
  }

  [void] show_python_files() {
      # List all Python files in folders, recursively, and sort by filesize
      Foreach ($h in $this.hash.GetEnumerator()) {
        Foreach ($linter in $this.linters) {
          Get-ChildItem -Path $h.Name -Recurse -File -Filter *.py |
            Sort-Object length -Descending |
              ForEach-Object {
                "$($h.Value)\$($linter)_results_$($_.BaseName).txt"
              }
        }
      }
  }

  [void] create_reports() {
      # Get all Python modules in folder and generate linter reports
      $counter = 0
      Foreach ($h in $this.hash.GetEnumerator()) {
        $counter++
        Write-Progress -Activity 'Processing code:' -CurrentOperation $h.Name -PercentComplete (
          ($counter / $this.hash.count) * 100)
        Start-Sleep -Milliseconds 200
        Foreach ($linter in $this.linters) {
          Get-ChildItem -Path $h.Name -Recurse -Filter *.py |
            ForEach-Object {
              Invoke-Expression "$linter $($_.FullName)" |
                Out-File -FilePath "$($h.Value)\$($linter)_results_$($_.BaseName)_$timestamp.txt"
              }
          }
        }
        Write-Host "`r`nGenerated linter reports`r`n"
    }

  [void] delete_reports() {
    Write-Host "`r`nDeleting linter reports`r`n"
    Foreach ($h in $this.hash.GetEnumerator()) {
      Write-Host "Deleting files in: $($h.Value)"
      Remove-Item "$($h.Value)\*.txt*"
    }
  }

  [void] main() {
    If ($this.handlePaths) {
      $this.handle_paths()
    }
    If ($this.debug) {
      $this.debug_linting()
    }
    If ($this.gitPull) {
      $this.git_pull()
    }
    If ($this.showPythonFiles) {
      $this.show_python_files()
    }
    If ($this.createReports) {
      $this.create_reports()
    }
    If ($this.deleteReports) {
      $this.delete_reports()
    }
  }

}
