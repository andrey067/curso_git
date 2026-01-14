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

function create_tag() {
	echo "Creating a new tag..."

	# Selecionar commit
	local commit=$(git log --oneline --color=always | fzf +m \
		--ansi \
		--header "Select the commit to tag:" \
		--height 40% \
		--layout reverse \
		--border --preview \
		'git show --color=always {1}' \
		--color bg:#222222,preview-bg:#333333)

	exit_if_empty "$commit"

	local commit_hash=$(echo $commit | awk '{print $1}')

	# Solicitar nome da tag
	echo ""
	read -p "Enter tag name (e.g., v1.0.0): " tag_name

	if [ -z "$tag_name" ]; then
		echo "Error: Tag name cannot be empty"
		exit 1
	fi

	# Verificar se tag já existe
	if git tag -l | grep -q "^${tag_name}$"; then
		echo "Error: Tag '$tag_name' already exists"
		exit 1
	fi

	# Solicitar mensagem da tag
	read -p "Enter tag message: " tag_message

	if [ -z "$tag_message" ]; then
		tag_message="Tag $tag_name"
	fi

	# Criar tag annotated
	git tag -a "$tag_name" "$commit_hash" -m "$tag_message"
	exit_on_error "Could not create tag: $tag_name"

	echo "✅ Successfully created tag: $tag_name at commit $commit_hash"
	echo "💡 To push this tag, use: git push origin $tag_name"
}

function list_tags() {
	echo "Listing all tags..."

	if [ -z "$(git tag)" ]; then
		echo "No tags found in this repository"
		return
	fi

	local selected=$(git tag --sort=-creatordate | fzf +m \
		--header "Tags (press Enter to view details, ESC to cancel):" \
		--height 40% \
		--layout reverse \
		--border --preview \
		'git show --color=always {}' \
		--color bg:#222222,preview-bg:#333333)

	if [ -n "$selected" ]; then
		echo ""
		git show "$selected"
	fi
}

function push_tag() {
	if [ -z "$(git tag)" ]; then
		echo "No tags found in this repository"
		return
	fi

	local options=(
		"Push all tags"
		"Push specific tag"
		"Cancel"
	)

	local choice=$(for opt in "${options[@]}"; do echo $opt; done | fzf +m \
		--header "Select push option:" \
		--height 40% \
		--layout reverse \
		--border --color bg:#222222)

	exit_if_empty "$choice"

	case "$choice" in
	${options[0]})
		echo "Pushing all tags..."
		git push --tags
		exit_on_error "Could not push tags"
		echo "✅ Successfully pushed all tags"
		;;
	${options[1]})
		local tag=$(git tag --sort=-creatordate | fzf +m \
			--header "Select tag to push:" \
			--height 40% \
			--layout reverse \
			--border --preview \
			'git show --color=always {}' \
			--color bg:#222222,preview-bg:#333333)

		exit_if_empty "$tag"

		echo "Pushing tag: $tag"
		git push origin "$tag"
		exit_on_error "Could not push tag: $tag"
		echo "✅ Successfully pushed tag: $tag"
		;;
	${options[2]})
		echo "Operation cancelled"
		;;
	esac
}

function delete_tag() {
	if [ -z "$(git tag)" ]; then
		echo "No tags found in this repository"
		return
	fi

	local tag=$(git tag --sort=-creatordate | fzf +m \
		--header "Select tag to delete:" \
		--height 40% \
		--layout reverse \
		--border --preview \
		'git show --color=always {}' \
		--color bg:#222222,preview-bg:#333333)

	exit_if_empty "$tag"

	# Confirmar deleção
	echo ""
	read -p "Delete tag '$tag' locally and remotely? (y/n): " -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		echo "Operation cancelled"
		return
	fi

	# Deletar localmente
	git tag -d "$tag"
	exit_on_error "Could not delete local tag: $tag"
	echo "✅ Deleted local tag: $tag"

	# Tentar deletar no remoto
	read -p "Delete from remote as well? (y/n): " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		git push origin --delete "$tag" 2>/dev/null
		if [ $? -eq 0 ]; then
			echo "✅ Deleted remote tag: $tag"
		else
			echo "⚠️  Tag not found on remote or already deleted"
		fi
	fi
}

function tag_menu() {
	local tag_options=(
		"1 - Create tag"
		"2 - List tags"
		"3 - Push tag(s)"
		"4 - Delete tag"
		"Back to main menu"
	)

	local selected=$(for opt in "${tag_options[@]}"; do echo $opt; done | fzf +m \
		--header "Tag Management:" \
		--height 40% \
		--layout reverse \
		--border --color bg:#222222)

	exit_if_empty "$selected"

	case "$selected" in
	${tag_options[0]})
		echo "$selected"
		create_tag
		;;
	${tag_options[1]})
		echo "$selected"
		list_tags
		;;
	${tag_options[2]})
		echo "$selected"
		push_tag
		;;
	${tag_options[3]})
		echo "$selected"
		delete_tag
		;;
	${tag_options[4]})
		echo "Returning to main menu..."
		main
		;;
	*) ;;
	esac
}

check_fzf_installed

function main() {

	options=(
		"1 - Switch branch"
		"2 - Git merge"
		"3 - Delete branch"
		"4 - Manage tags"
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
		tag_menu
		exit 0
		;;
	${options[4]})
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
