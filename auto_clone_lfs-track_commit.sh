#!/bin/bash
# This script automatically tracks and commits changes using Git LFS.

# Ensure Git and Git LFS are installed
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Installing Git..."
    sudo apt update && sudo apt install -y git
fi

if ! command -v git-lfs &> /dev/null; then
    echo "Git LFS is not installed. Installing Git LFS..."
    sudo apt install -y git-lfs
    git lfs install
fi

if ! command -v curl &> /dev/null; then
    echo "curl is not installed. Installing curl..."
    sudo apt install -y curl
fi

echo "Use this script to track and commit changes using Git LFS."

# List repositories under the user's GitHub account
echo "Fetching repositories under your GitHub account..."
echo
curl -s "https://api.github.com/users/ENTER-GITHUB-USER-HERE/repos?per_page=100" | grep -o '"name": "[^"]*"' | cut -d '"' -f4
echo

while true; do
    echo "Enter repository name to track or clone: "
    read repo_name
    repo_url="https://github.com/ENTER-GITHUB-USER-HERE/$repo_name"

    # Check if repository exists before attempting to clone
    if ! curl -s --head --fail "$repo_url" > /dev/null; then
        echo "Repository '$repo_name' does not exist or is private. Please enter a valid repository name."
        continue
    fi
    break
done

if [ -d "$repo_name" ]; then
    echo "Repository '$repo_name' already exists in the current directory. Overwrite? (y/n)"
    read overwrite_choice
    if [ "$overwrite_choice" = "y" ]; then
        rm -rf "$repo_name"
        git clone "$repo_url"
    fi
else
    git clone "$repo_url" || { echo "Failed to clone repository. Exiting."; exit 1; }
fi

cd "$repo_name" || { echo "Failed to enter repository directory. Exiting."; exit 1; }

# Track all file types with Git LFS
git lfs track "*.*"
git add .gitattributes
echo "Now tracking changes to $repo_name using Git LFS."

while true
do
    echo "Type 'commit' when ready to commit changes. Type 'cancel' to close."
    read user_command
    
    case "$user_command" in
        "commit")
            echo "Enter commit message: "
            read commit_message
            git add .
            git commit -m "$commit_message"
            git push
            ### Use your github username as the username to
            ### authenticate git push
            ### Use the SSH token below instead of github password
            ### to authenticate git push
            ### GitHub token (classic)
            ### (goto https://github.com/settings/tokens to
            ### generate a Personal Access Token, and save it here
            ### to use instead of your github password
            echo "Exiting script."
            exit 0
            ;;
        "cancel")
            echo "Untracking all files from Git LFS..."
            git lfs untrack "*.*"
            echo "Exiting script."
            exit 0
            ;;
        *)
            echo "Invalid command. Please type 'commit' or 'cancel'."
            ;;
    esac
    echo
done



