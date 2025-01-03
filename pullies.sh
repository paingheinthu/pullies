#!/bin/bash

# Define the color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Define version
VERSION="1.0.0"

# Check for arguments
if [[ "$1" == "--version" ]]; then
  echo "Pullies version $VERSION"
  exit 0
fi

header="*${GREEN}\t  multiple project stash, checkout and pulling${NC}\t\t\t\t\t*"
body="* ${RED}please make sure your projects must be same source repo name and branch name${NC}\t\t*"
horizontal_line="*****************************************************************************************"
vertical_line="*                                                                                       *"
echo "$horizontal_line"
echo "$vertical_line"
echo -e "$header"
#echo -e "$body"
echo "$vertical_line"
echo "$horizontal_line"

stash_miko() {
  local projects=("$1")
  current_dir=$(pwd)

  for project in "${projects[@]}"; do
    echo -e "satshing ${GREEN}$project${NC} ... "

    # go to directory
    cd "$project"

    # stash all of changes
    git stash

    # go back current dir
    cd "$current_dir"
  done
}

change_branch() {
  local projects=("${!1}")
  local branch=("$2")

  current_dir=$(pwd)

  for project in "${projects[@]}"; do
    echo -e "checkout ${GREEN}$project${NC} ... "

    # go to directory
    cd "$project"

    # stash all of changes
    git checkout $branch

    # go back current dir
    cd "$current_dir"
  done
}

pull_branch() {
  local projects=("${!1}")
  local source="$2"
  local branch="$3"
  local is_same="$4"

  current_dir=$(pwd)

  for project in "${projects[@]}"; do
    echo -e "pulling ${GREEN}$project${NC} ... "

    # go to directory
    cd "$project"

    if [[ "$is_same" == "y" || "$is_same" == "Y" ]]; then
      git pull $source $branch
    else
      read -p "provide the source repo name! (eg., source || origin): " remote
      read -p "provide the source branch name! (eg., dev || master): " branch

      if [ -n "$remote" ] && [ -n "$branch" ]; then
        git pull $remote $branch
      else
        echo -e "hmm your missing to support source repo or source branch ;( ${RED}YOU NEED RE RUN! SO SAD${NC}"
      fi
    fi

    # go back current dir
    cd "$current_dir"
  done
}

complete -d cd

read -e -p "which projects are you working eg., project-a project-b ...: " -a projects
echo -e "run for the those projects ... ${GREEN}[${projects[@]}]${NC}"
read -p "are you want to stash of current working process? (y/n): " stash_confirm

if [[ "$stash_confirm" == "y" || "$stash_confirm" == "Y" ]]; then
  echo "stashing from your working directory ... "
  # Call the git stash function
  stash_miko "${projects[@]}"
fi

read -p "are you want to check out base branch?(y/n): " base_branch_confirm

if [[ "$base_branch_confirm" == "y" || "$base_branch_confirm" == "Y" ]]; then
  read -p "which branch are you want to checkout: " branch
  echo "checkout branch from your working directory ... "
  # Call the git stash function
  change_branch "projects[@]" "$branch"
fi

read -p "are you using same remote and branch name?(y/n): " remote_confirm
if [[ "$remote_confirm" == "y" || "$remote_confirm" == "Y" ]]; then
  read -p "provide the source repo name! (eg., source || origin): " source_repo
  read -p "provide the source branch name! (eg., dev || master): " source_branch
  if [ -n "$source_repo" ] && [ -n "$source_branch" ]; then
    #Call to git pull
    pull_branch "projects[@]" "$source_repo" "$source_branch" "$remote_confirm"
  fi
else
  pull_branch "projects[@]" "$source_repo" "$source_branch" "$remote_confirm"
fi
