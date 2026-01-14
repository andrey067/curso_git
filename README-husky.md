# Documentação do Husky: Git Hooks para Projetos Node.js

## O que é Husky?

Husky é uma ferramenta que facilita a configuração e execução de Git hooks em projetos Node.js. Git hooks são scripts que rodam automaticamente em eventos específicos do Git (como commit, push, etc.), permitindo automatizar tarefas como linting, testes e formatação de código. Ele substitui a necessidade de configurar hooks manualmente no diretório `.git/hooks`.

Husky integra-se com ferramentas como ESLint, Prettier e Jest para garantir qualidade de código antes de commits ou pushes.

## Instalação

Instale via npm ou yarn:

```bash
npm install husky --save-dev
# ou
yarn add husky --dev
```

Para versões recentes (Husky v7+), inicialize com:

```bash
npx husky-init && npm install
```

Isso cria o diretório `.husky` e configura hooks básicos.

## Configuração

Husky usa o diretório `.husky` para armazenar scripts de hooks. Cada hook é um arquivo executável no `.husky/`.

Exemplo de estrutura:
```
.husky/
  pre-commit
  commit-msg
  pre-push
```

Para adicionar um hook, crie um arquivo com o nome do hook e torne-o executável:

```bash
echo '#!/usr/bin/env sh' > .husky/pre-commit
chmod +x .husky/pre-commit
```

## Hooks Principais e Suas Funções

### 1. pre-commit
- **Quando roda**: Antes de um commit ser criado.
- **Função**: Executa verificações rápidas no código staged. Se falhar, o commit é abortado.
- **Exemplo de uso**:
  ```bash
  # .husky/pre-commit
  npm run lint
  npm run test:unit
  ```
- **Caso de uso**: Garantir que código lintado e testes unitários passem antes de commitar. Evita commits com erros óbvios.

### 2. commit-msg
- **Quando roda**: Após o commit ser criado, mas antes de finalizar.
- **Função**: Valida a mensagem do commit contra padrões (ex: Conventional Commits).
- **Exemplo de uso**:
  ```bash
  # .husky/commit-msg
  npx commitlint --edit $1
  ```
- **Caso de uso**: Forçar mensagens padronizadas, facilitando geração de changelogs e releases automáticos.

### 3. pre-push
- **Quando roda**: Antes de um push para o remoto.
- **Função**: Executa testes mais pesados ou verificações de integração.
- **Exemplo de uso**:
  ```bash
  # .husky/pre-push
  npm run test
  npm run build
  ```
- **Caso de uso**: Prevenir pushes com código quebrado. Ideal para CI/CD, garantindo que apenas código testado chegue ao remoto.

### 4. post-commit
- **Quando roda**: Após um commit ser finalizado.
- **Função**: Executa ações pós-commit, como notificações ou limpeza.
- **Exemplo de uso**:
  ```bash
  # .husky/post-commit
  echo "Commit realizado com sucesso!"
  ```
- **Caso de uso**: Raro, mas útil para logs ou integrações com ferramentas externas.

### 5. post-merge
- **Quando roda**: Após um merge (incluindo pull).
- **Função**: Executa ações após merges, como instalar dependências ou rodar migrations.
- **Exemplo de uso**:
  ```bash
  # .husky/post-merge
  npm install  # Se package.json mudou
  ```
- **Caso de uso**: Manter o ambiente atualizado após pulls ou merges de branches.

### 6. pre-rebase
- **Quando roda**: Antes de um rebase.
- **Função**: Impede rebases em branches protegidas ou executa verificações.
- **Exemplo de uso**:
  ```bash
  # .husky/pre-rebase
  if [ "$1" = "main" ]; then
    echo "Rebase na main não permitido"
    exit 1
  fi
  ```
- **Caso de uso**: Proteger branches principais de rebases acidentais.

## Casos de Uso Gerais

- **Qualidade de Código**: Combine com ESLint e Prettier para formatar e validar código automaticamente.
- **Testes Automatizados**: Rode testes unitários e de integração em pre-commit ou pre-push.
- **Conventional Commits**: Use commit-msg para validar mensagens e gerar changelogs com tools like `standard-version`.
- **CI/CD Local**: Simule pipelines locais com pre-push, evitando falhas no servidor.
- **Segurança**: Impedir commits de secrets ou arquivos sensíveis.
- **Notificações**: Envie alertas para Slack ou email em post-commit.

## Dicas e Boas Práticas

- Mantenha hooks leves em pre-commit para não atrasar commits frequentes.
- Use `npm run` para scripts consistentes.
- Teste hooks localmente antes de commitar.
- Para desabilitar temporariamente: `git commit --no-verify`.
- Integre com lint-staged para rodar ferramentas apenas em arquivos modificados.

## Exemplo Completo

Arquivo `package.json`:
```json
{
  "scripts": {
    "lint": "eslint .",
    "test": "jest",
    "build": "webpack"
  },
  "husky": {
    "hooks": {
      "pre-commit": "npm run lint",
      "pre-push": "npm run test && npm run build"
    }
  }
}
```

Para Husky v8+, use apenas `.husky/` sem config no package.json.

Husky transforma Git hooks em parte integrante do workflow de desenvolvimento, promovendo código de alta qualidade e automação.