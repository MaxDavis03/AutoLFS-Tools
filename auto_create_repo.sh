#!/bin/bash

echo "Use this script to create a new public repository."
echo "Enter the name for the new repository: "
read repo_name

# Create the new repository directory and initialize Git
mkdir $repo_name
cd $repo_name
git init

# Add a README file
echo "# My New Repo" > README.md

# Inform the user they can copy new files into the repository
echo "You now have time to copy new files into the repository directory."
echo "Press any key to continue once you've added your files..."
read -n 1 -s  # Wait for user input before continuing

# Stage and commit the files
git add .
git commit -m "Initial commit"

# Add the remote repository URL
git remote add origin https://github.com/ENTER-GITHUB-USER-HERE/$repo_name.git
git push -u origin main

