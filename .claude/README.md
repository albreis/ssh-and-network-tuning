# Configuração de Atualização Automática do Repositório

## Resumo
Esta configuração garante que o repositório `ssh-and-network-tuning` seja sempre atualizado antes de qualquer tarefa substancial.

## Arquivos Criados/Modificados

### 1. `.claude/rules.md`
- **Função**: Define as regras obrigatórias para atualização do repositório
- **Localização**: `/projects/69b235ed78cc8ded7792d113/.claude/rules.md`
- **Conteúdo**: Protocolo detalhado de atualização específico para `ssh-and-network-tuning`

### 2. `.claude/config.yml`
- **Função**: Configuração YAML para hooks pré-tarefa
- **Localização**: `/projects/69b235ed78cc8ded7792d113/.claude/config.yml`
- **Conteúdo**: Configuração automatizada com sequência de comandos

### 3. `.claude/update-repo.sh`
- **Função**: Script automatizado para atualização do repositório
- **Localização**: `/projects/69b235ed78cc8ded7792d113/.claude/update-repo.sh`
- **Permissões**: Executável (`chmod +x`)
- **Recursos**:
  - Verificação de status do repositório
  - Detecção de mudanças não commitadas
  - Fetch e pull automáticos
  - Tratamento de erros
  - Interface amigável com emojis

## Como Usar

### Execução Manual
```bash
# Na pasta raiz do projeto
./.claude/update-repo.sh
```

### Comando Rápido
```bash
# Atualização direta sem script
cd ssh-and-network-tuning && git fetch origin && git pull && cd ..
```

## Funcionalidades

✅ **Atualização automática antes de tarefas**
✅ **Verificação de status do repositório** 
✅ **Detecção de conflitos**
✅ **Tratamento de mudanças não commitadas**
✅ **Interface visual com indicadores**
✅ **Retorno seguro ao diretório raiz**
✅ **Tratamento de erros robusto**

## Cenários de Aplicação

### Obrigatório
- Modificações de código
- Criação/exclusão de arquivos
- Operações de branch
- Atualizações de dependências
- Mudanças de configuração
- Operações de build/teste

### Opcional
- Visualização simples de arquivos
- Verificações de status
- Leitura de documentação

## Estrutura do Repositório Alvo
- **Caminho**: `/projects/69b235ed78cc8ded7792d113/ssh-and-network-tuning`
- **Branch atual**: `update-readme-title`
- **Remote origin**: `https://github.com/albreis/ssh-and-network-tuning`

## Status da Configuração
- ✅ Regras definidas em `rules.md`
- ✅ Configuração YAML atualizada
- ✅ Script automatizado criado e testado
- ✅ Permissões de execução configuradas
- ✅ Teste de funcionamento realizado

---
**Data de criação**: 2026-03-12  
**Versão**: 1.0  
**Status**: Ativo e funcional