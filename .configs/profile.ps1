Write-Host "Loading user `$PROFILE ..." -ForegroundColor DarkGray
try
{
  $ErrorActionPreference = 'Stop'
  # Cache installed modules once
  $script:InstalledModuleSet =
  [System.Collections.Generic.HashSet[string]]::new(
    [string[]](Get-Module -ListAvailable).Name
  )
  function prompt
  {
    # ---------- Custom loaded custom modules ----------
    $customModules = (Get-Module).Name.Where({
        -not $script:InstalledModuleSet.Contains($_)
      })
    $moduleText = if ($customModules.Count -gt 0)
    {
      "[$($customModules -join ',')]"
    } else
    {
      ""
    }
    # ---------- CWD path relative to home ----------
    $homePath = $HOME.TrimEnd('/')
    $cwd = (Get-Location).Path
    if ($cwd.StartsWith($homePath))
    {
      $cwd = "~" + $cwd.Substring($homePath.Length)
    }
    # ---------- Console window width ----------
    $width = $Host.UI.RawUI.WindowSize.Width
    # ----------- Left aligned text -----------
    $promptPrefix = "PS "
    $modulePrefix = ($moduleText ? "$moduleText " : "")
    $cwdPrefix= "$cwd >"
    
    # ---------- Git Status ----------
    $gitStatus = ""
    $gitColor = "DarkGray"
    
    # Check if we're in a git repository
    $gitDir = git rev-parse --git-dir 2>$null
    if ($LASTEXITCODE -eq 0)
    {
      # Get current branch
      $branch = git branch --show-current 2>$null
      if (-not $branch)
      {
        # Detached HEAD state
        $branch = git rev-parse --short HEAD 2>$null
        $branch = "detached:$branch"
      }
      
      # Get status counts
      $status = git status --porcelain 2>$null
      $staged = 0
      $modified = 0
      $untracked = 0
      $deleted = 0
      
      if ($status)
      {
        foreach ($line in $status)
        {
          $x = $line.Substring(0,1)
          $y = $line.Substring(1,1)
          
          # Staged changes (index)
          if ($x -match '[MADRC]')
          { $staged++ 
          }
          # Modified in working tree
          if ($y -eq 'M')
          { $modified++ 
          }
          # Deleted
          if ($y -eq 'D' -or $x -eq 'D')
          { $deleted++ 
          }
          # Untracked
          if ($x -eq '?' -and $y -eq '?')
          { $untracked++ 
          }
        }
      }
      
      # Check if ahead/behind remote
      $ahead = 0
      $behind = 0
      $upstream = git rev-parse --abbrev-ref '@{upstream}' 2>$null
      if ($LASTEXITCODE -eq 0)
      {
        $counts = git rev-list --left-right --count 'HEAD...@{upstream}' 2>$null
        if ($counts -match '^(\d+)\s+(\d+)$')
        {
          $ahead = [int]$Matches[1]
          $behind = [int]$Matches[2]
        }
      }
      
      # Build status string
      $statusParts = @()
      if ($staged -gt 0)
      { $statusParts += "●$staged" 
      }      # staged (green dot)
      if ($modified -gt 0)
      { $statusParts += "±$modified" 
      }  # modified (yellow)
      if ($deleted -gt 0)
      { $statusParts += "✖$deleted" 
      }    # deleted (red)
      if ($untracked -gt 0)
      { $statusParts += "…$untracked" 
      } # untracked (gray)
      if ($ahead -gt 0)
      { $statusParts += "↑$ahead" 
      }        # ahead
      if ($behind -gt 0)
      { $statusParts += "↓$behind" 
      }      # behind
      
      $statusSuffix = if ($statusParts.Count -gt 0)
      { " " + ($statusParts -join " ") 
      } else
      { "" 
      }
      
      # Determine overall color
      if ($staged -gt 0 -or $modified -gt 0 -or $deleted -gt 0 -or $untracked -gt 0)
      {
        $gitColor = "Yellow"  # Changes present
      } else
      {
        $gitColor = "Green"   # Clean
      }
      
      $gitStatus = " git:$branch$statusSuffix"
    }
    
    # ------------- Right aligned text ----------
    $time = (Get-Date).ToString('HH:mm:ss')
    $rightText = "$gitStatus $time"
    
    # --------- Write right-aligned content on line above ---------
    $pad = [Math]::Max(0, $width - $rightText.Length)
    Write-Host (" " * $pad) -NoNewline
    
    # Write git status if present
    if ($gitStatus)
    {
      Write-Host $gitStatus -NoNewline -ForegroundColor $gitColor
      Write-Host " " -NoNewline
    }
    Write-Host $time -ForegroundColor DarkGray
    
    # --------- Write left prompt on current line ---------
    Write-Host $promptPrefix -NoNewline -ForegroundColor Green
    if ($moduleText)
    {
      Write-Host $modulePrefix -NoNewline -ForegroundColor Cyan
    }
    Write-Host $cwdPrefix -NoNewline -ForegroundColor Yellow
    
    # Return empty string so cursor stays on same line
    return " "
  }
  Write-Host "User `$PROFILE loaded" -ForegroundColor DarkGreen
} catch
{
  Write-Host "User `$PROFILE failed to load" -ForegroundColor Red
  throw
} finally
{
  $ErrorActionPreference = 'Continue'
}








