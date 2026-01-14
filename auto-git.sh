#! /bin/bash
echo "Auto Git Script Running..."

function check_fzf_installed() {
	if ! command -v fzf &>/dev/null; then
		echo "fzf is not installed. Please install fzf to use this script."
		exit 1
	fi
}

function exit_on_error() {
	if [ $? -ne 0 ]; then
		echo "Error: $1"
		exit 1
	fi
}

function exit_if_empty() {
	if [ -z "$1" ]; then
		echo "Operation cancelled by user."
		exit 0
	fi
}

function switch_branch() {
	local branch_select=$(git branch | fzf +m \
		--header "Select the branch to go:" \
		--height 40% \
		--layout reverse \
		--border --preview \
		'git -c color.ui=always log --oneline $(echo {} | tr -d "* ")' \
		--color bg:#222222,preview-bg:#333333)

	exit_if_empty "$branch_select"

	branch_select=$(echo $branch_select | tr -d "* ")

	git switch "$branch_select"
	exit_on_error "Could not switch to branch: $branch_select"

	echo "Successfully switched to branch: $branch_select"
}

function merge_branch() {
	local branch_select=$(git branch | fzf +m \
		--header "Select the branch to merge:" \
		--height 100% \
		--layout reverse \
		--border --preview \
		'git -c color.ui=always diff $(git branch | grep "^*" | tr -d "* " ) $(echo {} | tr -d "* ")' \
		--color bg:#222222,preview-bg:#333333)

	exit_if_empty "$branch_select"

	branch_select=$(echo $branch_select | tr -d "* ")

	git merge "$branch_select"
	exit_on_error "Could not merge branch: $branch_select"

	echo "Successfully merged branch: $branch_select"
}

function delete_branch() {
	local selected=$(git branch | fzf +m \
		--header "Select the branch to delete:" \
		--height 40% \
		--layout reverse \
		--border --preview \
		'git -c color.ui=always log --oneline $(echo {} | tr -d "* ")' \
		--color bg:#222222,preview-bg:#333333)

	exit_if_empty "$selected"

	selected=$(echo $selected | tr -d "* ")

	# Previne deletar a branch atual
	local current_branch=$(git branch --show-current)
	if [ "$selected" = "$current_branch" ]; then
		echo "Error: Cannot delete the current branch: $selected"
		exit 1
	fi

	git branch -d "$selected"
	exit_on_error "Could not delete branch: $selected"

	echo "Successfully deleted branch: $selected"
}

check_fzf_installed

function main() {

	options=(
		"1 - Switch branch"
		"2 - Git merge"
		"3 - Delete branch"
		"Exit"
	)

	selected=$(for opt in "${options[@]}"; do echo $opt; done | fzf +m \
		--header "Select one option:" \
		--height 40% \
		--layout reverse \
		--border --color bg:#222222)

	exit_if_empty "$selected"

	case "$selected" in
	${options[0]})
		echo "$selected"
		switch_branch
		exit 0
		;;
	${options[1]})
		echo "$selected"
		merge_branch
		exit 0
		;;
	${options[2]})
		echo "$selected"
		delete_branch
		exit 0
		;;
	${options[3]})
		echo "$selected"
		exit 0
		;;
	*)
		exit 0
		;;
	esac
}

function validate_git_repository() {
	if ! git rev-parse --is-inside-work-tree &>/dev/null; then
		echo "Error: This is not a git repository!"
		exit 1
	fi
}

validate_git_repository
main
