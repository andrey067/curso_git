# Git Flow: Modelo de Branching para Git

## O que é Git Flow?

Git Flow é um modelo de branching criado por Vincent Driessen para gerenciar projetos com releases frequentes e controle rigoroso de versões. Ele define um padrão para branches e merges, facilitando o desenvolvimento paralelo, releases e correções de emergência.

O modelo usa branches de longa duração (main e develop) e branches temporárias (feature, release, hotfix) para organizar o trabalho.

## Branches Principais

- **main** (ou master): Contém o código de produção. Apenas releases finais são mergeados aqui.
- **develop**: Branch de desenvolvimento principal. Integra novas features antes de releases.

## Branches de Suporte

- **feature/* **: Para desenvolver novas funcionalidades. Criadas a partir de develop e mergeadas de volta para develop.
- **release/* **: Para preparar releases. Criadas a partir de develop, testadas e mergeadas para main e develop.
- **hotfix/* **: Para correções urgentes em produção. Criadas a partir de main e mergeadas para main e develop.

## Fluxo de Trabalho

### 1. Iniciando um Projeto
- Crie a branch develop a partir de main.
- Trabalhe sempre em develop para integrações.

### 2. Desenvolvendo uma Feature
- Crie uma branch feature a partir de develop: `git checkout -b feature/nome-feature develop`
- Desenvolva e commite mudanças.
- Faça merge de volta para develop: `git checkout develop && git merge feature/nome-feature`
- Delete a branch feature.

Exemplo do log:
- Commit `5d55f08`: "feature: implementando git flow" na branch feature/git-flow.
- PR #1: Merge da feature/git-flow para develop.

### 3. Preparando um Release
- Crie uma branch release a partir de develop: `git checkout -b release/v1.0 develop`
- Faça testes finais e correções menores.
- Merge para main: `git checkout main && git merge release/v1.0`
- Crie uma tag: `git tag v1.0`
- Merge de volta para develop: `git checkout develop && git merge release/v1.0`
- Delete a branch release.

Exemplo do log:
- Branch release presente em `531e58c` (tag: v2.0, v1.0).

### 4. Correção de Emergência (Hotfix)
- Crie uma branch hotfix a partir de main: `git checkout -b hotfix/v3.0 main`
- Corrija o bug e commite.
- Merge para main: `git checkout main && git merge hotfix/v3.0`
- Crie uma tag se necessário.
- Merge para develop: `git checkout develop && git merge hotfix/v3.0`
- Delete a branch hotfix.

Exemplo do log:
- Branches como hotfix/v3.0 podem ser simuladas com commits de correção.

### 5. Integração com Tags
- Use tags para marcar releases: `git tag v1.0` após merge para main.
- Exemplo: Tags v1.0, v2.0, initial, beta no log.

## Comandos Essenciais

- Criar branch: `git checkout -b <branch> <base>`
- Merge: `git checkout <target> && git merge <source>`
- Push: `git push origin <branch>`
- Tag: `git tag -a v1.0 -m "Release v1.0"`

## Vantagens do Git Flow

- Histórico limpo e organizado.
- Separação clara entre desenvolvimento, releases e produção.
- Facilita trabalho em equipe e CI/CD.

## Desvantagens

- Pode ser complexo para projetos pequenos.
- Muitos branches podem confundir iniciantes.

Para mais detalhes, consulte o artigo original de Vincent Driessen ou ferramentas como git-flow (extensão para Git).

Exemplo prático baseado no log fornecido: O projeto iniciou com "criando o projeto" (8a79adc), adicionou features como about-page e git-flow, e evoluiu para releases marcados com tags.