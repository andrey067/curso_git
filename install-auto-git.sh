#!/bin/bash

echo "🚀 Auto-Git Installer"
echo "===================="

# Verificar se auto-git já está instalado
if command -v auto-git &>/dev/null; then
	echo "✅ auto-git já está instalado!"
	echo "   Localização: $(which auto-git)"
	read -p "Deseja reinstalar? (y/n): " -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		echo "Instalação cancelada."
		exit 0
	fi
fi

# Verificar se fzf está instalado
if ! command -v fzf &>/dev/null; then
	echo "❌ fzf não está instalado (dependência necessária)"
	read -p "Deseja instalar fzf via Homebrew? (y/n): " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		if command -v brew &>/dev/null; then
			echo "📦 Instalando fzf..."
			brew install fzf
		else
			echo "❌ Homebrew não encontrado. Instale manualmente: https://brew.sh"
			exit 1
		fi
	else
		echo "❌ Instalação cancelada. fzf é necessário para usar auto-git."
		exit 1
	fi
fi

# Criar diretório ~/.local/bin se não existir
if [ ! -d "$HOME/.local/bin" ]; then
	echo "📁 Criando diretório $HOME/.local/bin..."
	mkdir -p "$HOME/.local/bin"
fi

# Download auto-git.sh do GitHub Gist
GIST_URL="https://gist.githubusercontent.com/andrey067/8419135a4f9b98dcc8457d29d3d98ef9/raw/auto-git.sh"
DEST_FILE="$HOME/.local/bin/auto-git"

echo "📥 Baixando auto-git.sh do GitHub Gist..."
if command -v curl &>/dev/null; then
	curl -fsSL "$GIST_URL" -o "$DEST_FILE"
	if [ $? -ne 0 ]; then
		echo "❌ Erro ao baixar auto-git.sh do gist!"
		exit 1
	fi
elif command -v wget &>/dev/null; then
	wget -q "$GIST_URL" -O "$DEST_FILE"
	if [ $? -ne 0 ]; then
		echo "❌ Erro ao baixar auto-git.sh do gist!"
		exit 1
	fi
else
	echo "❌ Erro: curl ou wget não encontrado. Instale um deles para continuar."
	exit 1
fi

echo "✅ Download concluído!"

# Definir permissões de execução
echo "🔐 Definindo permissões de execução..."
chmod +x "$DEST_FILE"

# Verificar e adicionar ao PATH se necessário
PATH_ENTRY='export PATH="$HOME/.local/bin:$PATH"'

detect_shell() {
	if [ -n "$ZSH_VERSION" ]; then
		echo "zsh"
	elif [ -n "$BASH_VERSION" ]; then
		echo "bash"
	else
		echo "unknown"
	fi
}

SHELL_TYPE=$(detect_shell)
if [ "$SHELL_TYPE" = "zsh" ]; then
	RC_FILE="$HOME/.zshrc"
elif [ "$SHELL_TYPE" = "bash" ]; then
	RC_FILE="$HOME/.bashrc"
else
	RC_FILE="$HOME/.profile"
fi

if ! grep -q "$HOME/.local/bin" "$RC_FILE" 2>/dev/null; then
	echo "📝 Adicionando $HOME/.local/bin ao PATH em $RC_FILE..."
	echo "" >>"$RC_FILE"
	echo "# Added by auto-git installer" >>"$RC_FILE"
	echo "$PATH_ENTRY" >>"$RC_FILE"
	echo "✅ PATH atualizado!"
else
	echo "✅ $HOME/.local/bin já está no PATH"
fi

# Adicionar alias 'ag' para auto-git
ALIAS_ENTRY='alias ag="auto-git"'

if ! grep -q "alias ag=" "$RC_FILE" 2>/dev/null; then
	echo "📝 Adicionando alias 'ag' para auto-git em $RC_FILE..."
	echo "$ALIAS_ENTRY" >>"$RC_FILE"
	echo "✅ Alias 'ag' configurado!"
else
	echo "✅ Alias 'ag' já está configurado"
fi

# Recarregar configuração do shell
echo "🔄 Atualizando ambiente..."
export PATH="$HOME/.local/bin:$PATH"

echo ""
echo "✨ Instalação concluída com sucesso!"
echo ""
echo "📚 Para usar o auto-git:"
echo "   1. Recarregue seu terminal ou execute: source $RC_FILE"
echo "   2. Navegue até um repositório Git"
echo "   3. Execute: auto-git (ou use o alias 'ag')"
echo ""
echo "💡 Comandos disponíveis:"
echo "   - Switch branch: Trocar de branch interativamente"
echo "   - Git merge: Fazer merge de branches"
echo "   - Delete branch: Deletar branches"
echo "   - Manage tags: Criar, listar e gerenciar tags"
echo ""
echo "⚡ Atalho: Use 'ag' em vez de 'auto-git'"
