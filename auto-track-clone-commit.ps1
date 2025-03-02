# Ensure Git and Git LFS are installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git is not installed. Installing Git..."
    winget install --id Git.Git -e --source winget
}

if (-not (Get-Command git-lfs -ErrorAction SilentlyContinue)) {
    Write-Host "Git LFS is not installed. Installing Git LFS..."
    winget install --id Git.LFS -e --source winget
    git lfs install
}

if (-not (Get-Command curl -ErrorAction SilentlyContinue)) {
    Write-Host "curl is not installed. Installing curl..."
    winget install --id curl.curl -e --source winget
}

Write-Host "Use this script to track and commit changes using Git LFS."

# List repositories under the user's GitHub account
Write-Host "Fetching repositories under your GitHub account..." 
$githubUser = "ENTER-GITHUB-USER-HERE"
$repos = Invoke-RestMethod -Uri "https://api.github.com/users/$githubUser/repos?per_page=100"
$repos | ForEach-Object { Write-Host $_.name }

# Get repository name from user
do {
    $repo_name = Read-Host "Enter repository name to track or clone"
    $repo_url = "https://github.com/$githubUser/$repo_name"
    
    # Check if repository exists
    try {
        Invoke-WebRequest -Uri "$repo_url" -UseBasicParsing -ErrorAction Stop | Out-Null
        $repo_exists = $true
    } catch {
        Write-Host "Repository '$repo_name' does not exist or is private. Please enter a valid repository name."
        $repo_exists = $false
    }
} while (-not $repo_exists)

# Clone repository if needed
if (Test-Path "$repo_name") {
    $overwrite_choice = Read-Host "Repository '$repo_name' already exists. Overwrite? (y/n)"
    if ($overwrite_choice -eq "y") {
        Remove-Item -Recurse -Force "$repo_name"
        git clone "$repo_url"
    }
} else {
    git clone "$repo_url" 
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to clone repository. Exiting."
        exit 1
    }
}

Set-Location "$repo_name"

# Track all file types with Git LFS
git lfs track "*.*"
git add .gitattributes
Write-Host "Now tracking changes to $repo_name using Git LFS."

while ($true) {
    $user_command = Read-Host "Type 'commit' to commit changes or 'cancel' to exit"
    
    switch ($user_command) {
        "commit" {
            $commit_message = Read-Host "Enter commit message"
            git add .
            git commit -m "$commit_message"
            git push
            Write-Host "Exiting script."
            exit 0
        }
        "cancel" {
            Write-Host "Untracking all files from Git LFS..."
            git lfs untrack "*.*"
            Write-Host "Exiting script."
            exit 0
        }
        default {
            Write-Host "Invalid command. Please type 'commit' or 'cancel'."
        }
    }
}
