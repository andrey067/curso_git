# Comandos Básicos do Git

Este README apresenta os comandos básicos do Git, usando o arquivo `index.html` como exemplo prático.

## 1. Inicializando um Repositório

Para começar a versionar seu projeto, inicialize um repositório Git no diretório do projeto:

```bash
git init
```

## 2. Verificando o Status dos Arquivos

Verifique o status dos arquivos no repositório para ver quais foram modificados, adicionados ou estão no stage:

```bash
git status
```

## 3. Adicionando Arquivos ao Stage

Adicione o arquivo `index.html` ao stage para prepará-lo para o commit:

```bash
git add index.html
```

Para adicionar todos os arquivos modificados:

```bash
git add .
```

## 4. Fazendo um Commit

Commit as mudanças no stage com uma mensagem descritiva:

```bash
git commit -m "Adiciona estrutura básica do arquivo index.html"
```

Para adicionar e commitar arquivos já rastreados em um só comando (equivalente a `git add . && git commit -m`):

```bash
git commit -am "Mensagem do commit"
```

## 5. Visualizando o Histórico de Commits

Veja o histórico de commits para acompanhar as mudanças:

```bash
git log
```

Para uma visualização mais compacta:

```bash
git log --oneline
```

## 6. Navegando entre Commits

Para navegar para um commit específico e ver o estado do projeto naquele ponto (modo detached HEAD):

```bash
git checkout <hash-do-commit>
```

Para voltar à branch atual:

```bash
git checkout main
```

## 7. Comparando Mudanças com git diff

Veja as diferenças entre o working directory e o último commit:

```bash
git diff
```

Para ver diferenças entre o stage e o último commit:

```bash
git diff --staged
```

Para comparar dois commits específicos:

```bash
git diff <hash-commit1> <hash-commit2>
```

## 8. Editando um Commit

Para alterar a mensagem do último commit:

```bash
git commit --amend -m "Nova mensagem do commit"
```

Para adicionar mudanças esquecidas ao último commit:

```bash
git add index.html
git commit --amend
```

## 9. Desfazendo Alterações

Para descartar mudanças no working directory e voltar ao último commit:

```bash
git checkout -- index.html
```

Para remover um arquivo do stage (sem perder mudanças):

```bash
git reset HEAD index.html
```

Para resetar todo o working directory e stage para o último commit (perde mudanças não commitadas):

```bash
git reset --hard HEAD
```

## 10. Desfazendo Commits

Para remover o último commit mas manter as mudanças no stage (soft reset):

```bash
git reset --soft HEAD~1
```

Para remover o último commit e descartar as mudanças (hard reset):

```bash
git reset --hard HEAD~1
```

Para reverter um commit específico criando um novo commit que desfaz as mudanças:

```bash
git revert <hash-do-commit>
```

## 11. Criando uma Nova Branch

Crie uma nova branch para trabalhar em uma feature separada:

```bash
git branch feature-nova
```

## 12. Trocando de Branch

Mude para a nova branch criada:

```bash
git checkout feature-nova
```

Ou use o comando moderno:

```bash
git switch feature-nova
```

## 13. Fazendo Merge de Branches

Volte para a branch principal (geralmente `main` ou `master`) e faça merge da branch feature:

```bash
git checkout main
git merge feature-nova
```

## 14. Fazendo Rebase de Branches

O `git rebase` reorganiza o histórico de commits aplicando os commits de uma branch sobre a base de outra, criando um histórico linear sem commits de merge. Use quando quiser manter o histórico limpo e linear, especialmente em branches de feature antes de fazer merge, ou para atualizar uma branch com as últimas mudanças da main.

Para rebase de uma branch feature sobre main:

```bash
git checkout feature-nova
git rebase main
```

Para rebase interativo (permite editar, squash ou reordenar commits):

```bash
git rebase -i HEAD~3  # Para os últimos 3 commits
```

Após o rebase, volte à main e faça fast-forward merge:

```bash
git checkout main
git merge feature-nova
```

## 15. Clonando um Repositório Remoto

Para clonar um repositório existente de um servidor remoto:

```bash
git clone <url-do-repositorio>
```

## 16. Fazendo Push para o Repositório Remoto

Envie seus commits locais para o repositório remoto:

```bash
git push origin main
```

## 17. Fazendo Pull de Mudanças

Puxe as mudanças mais recentes do repositório remoto:

```bash
git pull origin main
```

## 18. Configurando o Git

Configure seu nome e email (faça isso uma vez):

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu.email@exemplo.com"
```

## 19. Trabalhando com Tags

Tags são referências fixas a commits específicos, usadas para marcar versões de releases. Consulte o [README-tags.md](README-tags.md) para documentação completa sobre tags.

**Comandos básicos:**
```bash
git tag v1.0                           # Criar tag
git tag -a v1.0 -m "Release v1.0"     # Tag annotated
git push origin v1.0                   # Enviar tag
git push --tags                        # Enviar todas
```

## 20. Ignorando Arquivos

Crie um arquivo `.gitignore` para ignorar arquivos que não devem ser versionados, como arquivos temporários ou de build.

Exemplo de conteúdo para `.gitignore`:

```
*.log
node_modules/
.DS_Store
```

Esses são os comandos básicos e avançados para usar o Git. Pratique com o arquivo `index.html` para se familiarizar!

Para mais detalhes sobre tags, consulte o [README-tags.md](README-tags.md).