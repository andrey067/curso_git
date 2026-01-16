# Trabalhando com Tags no Git

## O que são Tags?

Tags são referências fixas a commits específicos no Git, usadas principalmente para marcar versões de releases, pontos importantes no histórico ou marcos do projeto. Diferente de branches, que evoluem com novos commits, tags são imutáveis.

## Tipos de Tags

### 1. Lightweight Tags
- Simples ponteiro para um commit
- Não armazena metadados extras
- Rápida de criar

```bash
git tag v1.0
```

### 2. Annotated Tags
- Armazena metadados completos (autor, data, mensagem)
- Pode ser assinada com GPG
- **Recomendada para releases oficiais**

```bash
git tag -a v1.0 -m "Release version 1.0"
```

## Criando Tags

### Tag no Commit Atual

```bash
# Lightweight
git tag v1.0

# Annotated
git tag -a v1.0 -m "Release version 1.0"
```

### Tag em Commit Específico

```bash
git tag -a v1.0 <hash-do-commit> -m "Mensagem"

# Exemplo:
git tag -a initial 8a79adc -m "feature: initial project"
```

## Quando Usar Tags

- **Releases de Produção**: v1.0, v2.0.1, v3.1.5 (Semantic Versioning)
- **Marcos do Projeto**: beta, alpha, release-candidate, stable
- **Pontos de Referência**: audit-2024, backup-before-refactor
- **Snapshots Importantes**: pre-migration, post-deploy

### Convenções de Nomenclatura

- **Semantic Versioning**: vMAJOR.MINOR.PATCH (v1.2.3)
- **Prefixos**: v (version), rel (release)
- **Ambientes**: prod-v1.0, staging-v2.0

## Listando Tags

```bash
# Todas as tags
git tag

# Tags com padrão específico
git tag -l "v1.*"
git tag -l "v2.*"

# Detalhes de uma tag
git show v1.0

# Tags ordenadas por data
git tag --sort=-creatordate
```

## Enviando Tags para o Remoto

### Tag Específica

```bash
git push origin v1.0
```

### Todas as Tags

```bash
git push --tags
```

### Tag e Commits Juntos

```bash
git push origin main --tags
```

## Deletando Tags

### Localmente

```bash
git tag -d v1.0
git tag -d initial_project
```

### Remotamente

Após deletar localmente:

```bash
git push origin --delete v1.0
```

Ou diretamente:

```bash
git push origin :refs/tags/v1.0
```

## Fazendo Checkout de Tags

Tags não são branches, então fazer checkout coloca o repositório em estado **detached HEAD**. Você pode visualizar o código, mas mudanças não afetarão branches.

```bash
git checkout v1.0
# Note: switching to 'v1.0'.
# You are in 'detached HEAD' state...
```

### Criar Branch a Partir de Tag

```bash
git checkout -b bugfix/v1.0 v1.0
# ou
git switch -c hotfix/v2.0 v2.0
```

### Voltar à Branch

```bash
git checkout main
# ou
git switch main
```

## Comparando Tags

### Diferenças Entre Tags

```bash
git diff v1.0 v2.0
```

### Log Entre Tags

```bash
git log v1.0..v2.0
git log --oneline v1.0..v2.0
```

### Commits Únicos em Cada Tag

```bash
git log v1.0...v2.0 --left-right --oneline
```

## Renomeando Tags

Git não permite renomear tags diretamente. É necessário deletar e recriar:

```bash
# Localmente
git tag new-name old-name
git tag -d old-name

# Remotamente
git push origin new-name
git push origin --delete old-name
```

## Exemplo Prático: Workflow de Release

```bash
# 1. Criar tag de release na main
git checkout main
git tag -a v1.0.0 -m "Release version 1.0.0"

# 2. Enviar para o remoto
git push origin v1.0.0

# 3. Listar tags
git tag
# beta
# initial
# v1.0
# v2.0

# 4. Fazer checkout para investigar bug em release antiga
git checkout v1.0.0

# 5. Criar branch para hotfix
git checkout -b hotfix/v1.0.1 v1.0.0

# 6. Após correção, criar nova tag
git tag -a v1.0.1 -m "Hotfix: correção crítica"
git push origin v1.0.1
```

## Boas Práticas

1. **Use Annotated Tags para Releases**: Incluem metadados importantes
2. **Siga Semantic Versioning**: MAJOR.MINOR.PATCH
3. **Mensagens Descritivas**: Explique o que a versão contém
4. **Não Modifique Tags**: São imutáveis por design
5. **Sincronize com Remoto**: `git push --tags` após criação
6. **Documente Mudanças**: Mantenha CHANGELOG.md atualizado
7. **Evite Detached HEAD Permanente**: Crie branch se precisar trabalhar

## Assinando Tags com GPG

Para verificar autenticidade e integridade:

```bash
# Criar tag assinada
git tag -s v1.0 -m "Signed release v1.0"

# Verificar assinatura
git tag -v v1.0

# Enviar tag assinada
git push origin v1.0
```

## Tags e CI/CD

Tags são frequentemente usadas para disparar pipelines de deploy:

```yaml
# Exemplo GitHub Actions
on:
  push:
    tags:
      - 'v*.*.*'
```

Isso cria automação baseada em releases marcados com tags.

---

**Referências:**
- [Git Tagging Documentation](https://git-scm.com/book/en/v2/Git-Basics-Tagging)
- [Semantic Versioning](https://semver.org/)
