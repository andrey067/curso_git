Write-Host "Auto Git Script Running..." -ForegroundColor Cyan

function Test-FzfInstalled {
    if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
        Write-Host "fzf is not installed. Please install fzf to use this script." -ForegroundColor Red
        Write-Host "Install with: winget install fzf or brew install fzf" -ForegroundColor Yellow
        exit 1
    }
}

function Exit-OnError {
    param([string]$Message)
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: $Message" -ForegroundColor Red
        exit 1
    }
}

function Exit-IfEmpty {
    param([string]$Value)
    
    if ([string]::IsNullOrWhiteSpace($Value)) {
        Write-Host "Operation cancelled by user." -ForegroundColor Yellow
        exit 0
    }
}

function Switch-GitBranch {
    $branches = git branch 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error getting branches" -ForegroundColor Red
        return
    }

    $branchSelect = $branches | fzf `
        --header="Select the branch to go:" `
        --height=40% `
        --layout=reverse `
        --border `
        --preview='git -c color.ui=always log --oneline {1}' `
        --preview-window=right:50% `
        --color='bg:#222222,preview-bg:#333333' `
        --no-multi

    Exit-IfEmpty $branchSelect

    $branchName = $branchSelect.Trim() -replace '^\*?\s*', ''

    git switch $branchName
    Exit-OnError "Could not switch to branch: $branchName"

    Write-Host "Successfully switched to branch: $branchName" -ForegroundColor Green
}

function Merge-GitBranch {
    $currentBranch = git branch --show-current
    $branches = git branch 2>$null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error getting branches" -ForegroundColor Red
        return
    }

    $branchSelect = $branches | fzf `
        --header="Select the branch to merge:" `
        --height=100% `
        --layout=reverse `
        --border `
        --preview="git -c color.ui=always diff $currentBranch {1}" `
        --preview-window=right:50% `
        --color='bg:#222222,preview-bg:#333333' `
        --no-multi

    Exit-IfEmpty $branchSelect

    $branchName = $branchSelect.Trim() -replace '^\*?\s*', ''

    git merge $branchName
    Exit-OnError "Could not merge branch: $branchName"

    Write-Host "Successfully merged branch: $branchName" -ForegroundColor Green
}

function Remove-GitBranch {
    $branches = git branch 2>$null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error getting branches" -ForegroundColor Red
        return
    }

    $selected = $branches | fzf `
        --header="Select the branch to delete:" `
        --height=40% `
        --layout=reverse `
        --border `
        --preview='git -c color.ui=always log --oneline {1}' `
        --preview-window=right:50% `
        --color='bg:#222222,preview-bg:#333333' `
        --no-multi

    Exit-IfEmpty $selected

    $branchName = $selected.Trim() -replace '^\*?\s*', ''

    # Previne deletar a branch atual
    $currentBranch = git branch --show-current
    if ($branchName -eq $currentBranch) {
        Write-Host "Error: Cannot delete the current branch: $branchName" -ForegroundColor Red
        exit 1
    }

    git branch -d $branchName
    Exit-OnError "Could not delete branch: $branchName"

    Write-Host "Successfully deleted branch: $branchName" -ForegroundColor Green
}

function New-GitTag {
    Write-Host "Creating a new tag..." -ForegroundColor Cyan

    # Selecionar commit
    $commits = git log --oneline --color=always 2>$null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error getting commits" -ForegroundColor Red
        return
    }

    $commit = $commits | fzf `
        --ansi `
        --header="Select the commit to tag:" `
        --height=40% `
        --layout=reverse `
        --border `
        --preview='git show --color=always {1}' `
        --preview-window=right:50% `
        --color='bg:#222222,preview-bg:#333333' `
        --no-multi

    Exit-IfEmpty $commit

    $commitHash = ($commit -split '\s+')[0]

    # Solicitar nome da tag
    Write-Host ""
    $tagName = Read-Host "Enter tag name (e.g., v1.0.0)"

    if ([string]::IsNullOrWhiteSpace($tagName)) {
        Write-Host "Error: Tag name cannot be empty" -ForegroundColor Red
        exit 1
    }

    # Verificar se tag já existe
    $existingTags = git tag -l 2>$null
    if ($existingTags -contains $tagName) {
        Write-Host "Error: Tag '$tagName' already exists" -ForegroundColor Red
        exit 1
    }

    # Solicitar mensagem da tag
    $tagMessage = Read-Host "Enter tag message"

    # Criar tag annotated
    if ([string]::IsNullOrWhiteSpace($tagMessage)) {
        git tag -a $tagName $commitHash -m "Tag $tagName"
    } else {
        git tag -a $tagName $commitHash -m $tagMessage
    }
    
    Exit-OnError "Could not create tag: $tagName"

    Write-Host "✅ Successfully created tag: $tagName at commit $commitHash" -ForegroundColor Green
    Write-Host "💡 To push this tag, use: git push origin $tagName" -ForegroundColor Yellow
}

function Show-GitTags {
    Write-Host "Listing all tags..." -ForegroundColor Cyan

    $tags = git tag --sort=-creatordate 2>$null
    
    if ([string]::IsNullOrWhiteSpace($tags)) {
        Write-Host "No tags found in this repository" -ForegroundColor Yellow
        return
    }

    $selected = $tags | fzf `
        --header="Tags (press Enter to view details, ESC to cancel):" `
        --height=40% `
        --layout=reverse `
        --border `
        --preview='git show --color=always {}' `
        --preview-window=right:50% `
        --color='bg:#222222,preview-bg:#333333' `
        --no-multi

    if (-not [string]::IsNullOrWhiteSpace($selected)) {
        Write-Host ""
        git show $selected
    }
}

function Push-GitTag {
    $tags = git tag 2>$null
    
    if ([string]::IsNullOrWhiteSpace($tags)) {
        Write-Host "No tags found in this repository" -ForegroundColor Yellow
        return
    }

    $options = @(
        "Push all tags"
        "Push specific tag"
        "Cancel"
    )

    $choice = $options | fzf `
        --header="Select push option:" `
        --height=40% `
        --layout=reverse `
        --border `
        --color='bg:#222222' `
        --no-multi

    Exit-IfEmpty $choice

    switch ($choice) {
        "Push all tags" {
            Write-Host "Pushing all tags..." -ForegroundColor Cyan
            git push --tags
            Exit-OnError "Could not push tags"
            Write-Host "✅ Successfully pushed all tags" -ForegroundColor Green
        }
        "Push specific tag" {
            $tag = git tag --sort=-creatordate | fzf `
                --header="Select tag to push:" `
                --height=40% `
                --layout=reverse `
                --border `
                --preview='git show --color=always {}' `
                --preview-window=right:50% `
                --color='bg:#222222,preview-bg:#333333' `
                --no-multi

            Exit-IfEmpty $tag

            Write-Host "Pushing tag: $tag" -ForegroundColor Cyan
            git push origin $tag
            Exit-OnError "Could not push tag: $tag"
            Write-Host "✅ Successfully pushed tag: $tag" -ForegroundColor Green
        }
        "Cancel" {
            Write-Host "Operation cancelled" -ForegroundColor Yellow
        }
    }
}

function Remove-GitTag {
    $tags = git tag --sort=-creatordate 2>$null
    
    if ([string]::IsNullOrWhiteSpace($tags)) {
        Write-Host "No tags found in this repository" -ForegroundColor Yellow
        return
    }

    $tag = $tags | fzf `
        --header="Select tag to delete:" `
        --height=40% `
        --layout=reverse `
        --border `
        --preview='git show --color=always {}' `
        --preview-window=right:50% `
        --color='bg:#222222,preview-bg:#333333' `
        --no-multi

    Exit-IfEmpty $tag

    # Confirmar deleção
    Write-Host ""
    $confirmation = Read-Host "Delete tag '$tag' locally and remotely? (y/n)"
    
    if ($confirmation -notmatch '^[Yy]$') {
        Write-Host "Operation cancelled" -ForegroundColor Yellow
        return
    }

    # Deletar localmente
    git tag -d $tag
    Exit-OnError "Could not delete local tag: $tag"
    Write-Host "✅ Deleted local tag: $tag" -ForegroundColor Green

    # Tentar deletar no remoto
    $remoteConfirm = Read-Host "Delete from remote as well? (y/n)"
    
    if ($remoteConfirm -match '^[Yy]$') {
        git push origin --delete $tag 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Deleted remote tag: $tag" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Tag not found on remote or already deleted" -ForegroundColor Yellow
        }
    }
}

function Show-TagMenu {
    $tagOptions = @(
        "1 - Create tag"
        "2 - List tags"
        "3 - Push tag(s)"
        "4 - Delete tag"
        "Back to main menu"
    )

    $selected = $tagOptions | fzf `
        --header="Tag Management:" `
        --height=40% `
        --layout=reverse `
        --border `
        --color='bg:#222222' `
        --no-multi

    Exit-IfEmpty $selected

    switch ($selected) {
        "1 - Create tag" {
            Write-Host $selected -ForegroundColor Cyan
            New-GitTag
        }
        "2 - List tags" {
            Write-Host $selected -ForegroundColor Cyan
            Show-GitTags
        }
        "3 - Push tag(s)" {
            Write-Host $selected -ForegroundColor Cyan
            Push-GitTag
        }
        "4 - Delete tag" {
            Write-Host $selected -ForegroundColor Cyan
            Remove-GitTag
        }
        "Back to main menu" {
            Write-Host "Returning to main menu..." -ForegroundColor Cyan
            Show-MainMenu
        }
    }
}

function Show-MainMenu {
    $options = @(
        "1 - Switch branch"
        "2 - Git merge"
        "3 - Delete branch"
        "4 - Manage tags"
        "Exit"
    )

    $selected = $options | fzf `
        --header="Select one option:" `
        --height=40% `
        --layout=reverse `
        --border `
        --color='bg:#222222' `
        --no-multi

    Exit-IfEmpty $selected

    switch ($selected) {
        "1 - Switch branch" {
            Write-Host $selected -ForegroundColor Cyan
            Switch-GitBranch
            exit 0
        }
        "2 - Git merge" {
            Write-Host $selected -ForegroundColor Cyan
            Merge-GitBranch
            exit 0
        }
        "3 - Delete branch" {
            Write-Host $selected -ForegroundColor Cyan
            Remove-GitBranch
            exit 0
        }
        "4 - Manage tags" {
            Write-Host $selected -ForegroundColor Cyan
            Show-TagMenu
            exit 0
        }
        "Exit" {
            Write-Host $selected -ForegroundColor Cyan
            exit 0
        }
        default {
            exit 0
        }
    }
}

function Test-GitRepository {
    git rev-parse --is-inside-work-tree 2>$null | Out-Null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: This is not a git repository!" -ForegroundColor Red
        exit 1
    }
}

# Main execution
Test-FzfInstalled
Test-GitRepository
Show-MainMenu
