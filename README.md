# 🔧 SSH & Network Tuning

Módulo Terraform para aplicação automática de tuning de **rede**, **SSH** e **limites de sistema** nos servidores. O objetivo é otimizar o desempenho de conexões, aumentar a capacidade de sessões simultâneas e garantir estabilidade sob alta carga.

---

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Variáveis](#variáveis)
- [Configurações Aplicadas](#configurações-aplicadas)
  - [Sysctl — Tuning de Rede](#1--sysctl--tuning-de-rede)
  - [SSH — Tuning do Servidor](#2--ssh--tuning-do-servidor)
  - [Ulimits — Limites de Arquivo](#3--ulimits--limites-de-arquivo)
- [Processo de Aplicação](#processo-de-aplicação)
- [Uso](#uso)
- [Outputs](#outputs)

---

## Visão Geral

O módulo provisiona automaticamente três arquivos de configuração nos servidores e aplica as mudanças de forma segura:

| Arquivo                                | Finalidade                          |
|----------------------------------------|-------------------------------------|
| `/etc/sysctl.d/99-network-tuning.conf` | Parâmetros de kernel (rede e I/O)   |
| `/etc/ssh/sshd_config.d/99-tuning.conf`| Configurações do servidor SSH       |
| `/etc/security/limits.d/99-ssh.conf`   | Limites de file descriptors (ulimit)|

---

## Variáveis

| Variável               | Tipo          | Default             | Descrição                              |
|------------------------|---------------|---------------------|----------------------------------------|
| `servers`              | `map(string)` | templates1/2 IPs    | Mapa de nome → IP dos servidores alvo  |
| `ssh_user`             | `string`      | `root`              | Usuário SSH para conexão               |
| `ssh_private_key_path` | `string`      | `~/.ssh/id_rsa`     | Caminho da chave privada SSH           |

---

## Configurações Aplicadas

### 1. 🌐 Sysctl — Tuning de Rede

Arquivo: `/etc/sysctl.d/99-network-tuning.conf`

Parâmetros do kernel Linux que otimizam o comportamento da pilha TCP/IP e o limite global de arquivos abertos.

#### Backlog e Fila de Conexões

| Parâmetro                        | Valor  | Descrição |
|----------------------------------|--------|-----------|
| `net.core.somaxconn`             | `1024` | Tamanho máximo da fila de conexões pendentes (listen backlog) de um socket. O padrão do Linux é `128`, insuficiente para servidores com muitas conexões simultâneas. Aumentar para `1024` evita que conexões sejam descartadas antes de serem aceitas pela aplicação. |
| `net.core.netdev_max_backlog`    | `5000` | Quantidade máxima de pacotes que podem ficar na fila de recebimento da interface de rede antes de serem processados pelo kernel. O padrão é `1000`. Aumentar para `5000` evita perda de pacotes em picos de tráfego. |
| `net.ipv4.tcp_max_syn_backlog`   | `4096` | Tamanho máximo da fila de conexões TCP no estado SYN_RECEIVED (meio do handshake). Protege contra sobrecarga e melhora a capacidade de aceitar novas conexões rapidamente. O padrão é `256` ou `512`. |

#### Reutilização e Timeout de Conexões

| Parâmetro                        | Valor  | Descrição |
|----------------------------------|--------|-----------|
| `net.ipv4.tcp_tw_reuse`          | `1`    | Permite reutilizar sockets no estado TIME_WAIT para **novas conexões de saída**. Reduz drasticamente o consumo de portas efêmeras em servidores que fazem muitas conexões curtas (ex: proxies, APIs). |
| `net.ipv4.tcp_fin_timeout`       | `15`   | Tempo (em segundos) que uma conexão fica no estado FIN_WAIT_2 antes de ser fechada. O padrão é `60`. Reduzir para `15` libera recursos mais rapidamente de conexões meio-fechadas. |

#### TCP Keep-Alive

| Parâmetro                        | Valor  | Descrição |
|----------------------------------|--------|-----------|
| `net.ipv4.tcp_keepalive_time`    | `300`  | Tempo (em segundos) de inatividade antes de enviar o primeiro probe keep-alive. O padrão é `7200` (2 horas). Reduzir para `300` (5 minutos) detecta conexões mortas muito mais rápido. |
| `net.ipv4.tcp_keepalive_intvl`   | `30`   | Intervalo (em segundos) entre probes keep-alive consecutivos após o primeiro. Padrão: `75`. Com `30s`, a detecção de conexão morta é mais ágil. |
| `net.ipv4.tcp_keepalive_probes`  | `5`    | Número de probes keep-alive sem resposta antes de considerar a conexão morta. Padrão: `9`. Com `5`, o tempo total de detecção fica em: `300 + (30 × 5) = 450 segundos` (~7.5 min) ao invés de `7200 + (75 × 9) = 7875 segundos` (~2h11). |

#### Limites de Sistema

| Parâmetro    | Valor      | Descrição |
|--------------|------------|-----------|
| `fs.file-max`| `1048576`  | Número máximo de file descriptors que o **kernel inteiro** pode ter abertos simultaneamente. Essencial para servidores que mantêm muitas conexões ativas (cada conexão TCP consome pelo menos um file descriptor). `1048576` = 1 milhão. |

---

### 2. 🔐 SSH — Tuning do Servidor

Arquivo: `/etc/ssh/sshd_config.d/99-tuning.conf`

Configurações do daemon SSH para suportar alto volume de sessões simultâneas com segurança.

| Parâmetro               | Valor          | Descrição |
|--------------------------|---------------|-----------|
| `MaxSessions`            | `100`         | Número máximo de sessões multiplexadas por uma única conexão SSH. O padrão é `10`. Aumentar para `100` é útil quando se usa connection multiplexing (ex: `ControlMaster` no SSH client) ou ferramentas que abrem múltiplas sessões. |
| `MaxStartups`            | `100:30:200`  | Controla conexões SSH simultâneas não autenticadas. Formato: `start:rate:full`. <br>• Até **100** conexões pendentes: aceita todas. <br>• Entre **100** e **200**: rejeita com probabilidade crescente de **30%** até **100%**. <br>• Acima de **200**: rejeita tudo. <br>Protege contra ataques de exaustão mantendo capacidade alta. |
| `MaxAuthTries`           | `6`           | Número máximo de tentativas de autenticação por conexão. Padrão já é `6`. Limita brute-force sem impactar uso legítimo. |
| `UseDNS`                 | `no`          | Desabilita resolução reversa de DNS durante autenticação. Elimina latência de **até 30 segundos** no login quando o DNS reverso é lento ou inexistente. Não afeta segurança real. |
| `ClientAliveInterval`    | `60`          | Envia um pacote keep-alive a cada **60 segundos** para clientes inativos. Previne que conexões sejam cortadas por NATs ou firewalls intermediários com timeout agressivo. |
| `ClientAliveCountMax`    | `10`          | Número de keep-alives sem resposta antes de desconectar o cliente. Com `interval=60` e `count=10`, uma sessão inativa é encerrada após **10 minutos** sem resposta, liberando recursos. |
| `LoginGraceTime`         | `30`          | Tempo máximo (em segundos) para completar a autenticação após conectar. O padrão é `120`. Reduzir para `30` libera rapidamente conexões que ficam penduradas sem autenticar (possível ataque). |

---

### 3. 📂 Ulimits — Limites de Arquivo

Arquivo: `/etc/security/limits.d/99-ssh.conf`

Define o número máximo de file descriptors que cada processo pode abrir.

| Configuração           | Valor      | Descrição |
|------------------------|------------|-----------|
| `* soft nofile`        | `1048576`  | Limite **soft** (padrão inicial) de arquivos abertos para **todos os usuários**. Processos podem elevar até o limite hard. |
| `* hard nofile`        | `1048576`  | Limite **hard** (máximo absoluto) de arquivos abertos para **todos os usuários**. Só root pode aumentar este valor após definido. |
| `root soft nofile`     | `1048576`  | Limite soft específico para o usuário **root**. Definido explicitamente pois o wildcard `*` nem sempre inclui root em algumas distros. |
| `root hard nofile`     | `1048576`  | Limite hard específico para o usuário **root**. |

> **Por que 1.048.576?** É 2²⁰ (1M), um valor generoso que garante que nenhum processo seja limitado por file descriptors. Cada conexão de rede, arquivo aberto, pipe ou socket consome um file descriptor.

---

## Processo de Aplicação

Após copiar os arquivos de configuração, o módulo executa os seguintes comandos remotamente:

```bash
# 1. Aplica todas as configurações sysctl imediatamente
sysctl --system

# 2. Valida a configuração do SSH antes de reiniciar (previne lockout)
sshd -t

# 3. Reinicia o SSH apenas se a validação passar
sshd -t && (systemctl restart ssh || systemctl restart sshd)
```

> ⚠️ **Segurança**: O `sshd -t` valida a sintaxe da configuração **antes** de reiniciar o serviço. Se a configuração for inválida, o restart não acontece, evitando perda de acesso ao servidor.

---

## Uso

```bash
# Inicializar o Terraform
terraform init

# Visualizar as mudanças que serão aplicadas
terraform plan

# Aplicar o tuning nos servidores
terraform apply

# Para forçar reaplicação (ex: após alterar configurações)
terraform apply -replace="null_resource.ssh_tuning[\"templates1\"]"
```

Para adicionar novos servidores, basta incluir no mapa `servers`:

```hcl
variable "servers" {
  default = {
    templates1 = "154.38.178.174"
    templates2 = "154.38.178.251"
    novo_server = "xxx.xxx.xxx.xxx"
  }
}
```

---

## Outputs

| Output          | Descrição                                              |
|-----------------|--------------------------------------------------------|
| `tuned_servers` | Mapa confirmando quais servidores receberam o tuning   |

---

## 📊 Resumo do Impacto

| Métrica                        | Antes (padrão)      | Depois (tuning)      |
|--------------------------------|----------------------|----------------------|
| Listen backlog                 | 128                  | **1.024**            |
| Fila de pacotes da NIC         | 1.000                | **5.000**            |
| Fila SYN                       | 256–512              | **4.096**            |
| FIN_WAIT timeout               | 60s                  | **15s**              |
| Detecção de conexão morta      | ~2h11                | **~7.5 min**         |
| File descriptors (kernel)      | ~65.536              | **1.048.576**        |
| File descriptors (por processo)| 1.024                | **1.048.576**        |
| Sessões SSH multiplexadas      | 10                   | **100**              |
| Login grace time               | 120s                 | **30s**              |
| DNS reverso no SSH             | Sim (lento)          | **Não (rápido)**     |
