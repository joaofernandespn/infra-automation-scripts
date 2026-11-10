# Scripts de Automação e Diagnóstico de Infraestrutura

Biblioteca de scripts comentados em PowerShell para apoiar rotinas de diagnóstico e automação de Analistas de Infraestrutura e Sysadmins.

O projeto também acompanha uma série de publicações no LinkedIn, conectando problemas reais do dia a dia a soluções práticas, com explicações dos comandos, pré-requisitos e limitações.

A proposta é simples: entender o ambiente antes de intervir.

## Objetivos

- Facilitar consultas e verificações recorrentes de infraestrutura.
- Compartilhar scripts organizados em blocos e comentados.
- Explicar o que cada rotina faz e o que seu resultado realmente confirma.
- Manter um histórico das alterações no código.
- Construir uma base para futuras automações e integrações.
- Incentivar o uso consciente de scripts, com revisão e testes antes da execução.

## Escopo atual

Os scripts disponíveis são voltados ao Windows e foram escritos em PowerShell.

As rotinas atuais consultam:

- Informações do sistema operacional, memória e uptime.
- Espaço livre nas unidades locais.
- Saúde reportada dos dispositivos de armazenamento e dos volumes.
- Serviços automáticos fora de execução.
- Conectividade TCP com servidores e serviços.
- Eventos críticos e erros nos logs do Windows.
- Arquivos EVTX para exportação de campos selecionados em CSV.

Os scripts de diagnóstico não iniciam serviços, não executam reparos de armazenamento e não apagam registros.

O script de conversão de EVTX para CSV cria um arquivo de saída. O teste de conectividade TCP realiza conexões aos destinos configurados.

A pasta `bash` está reservada para futuras rotinas Linux. Ainda não há scripts Bash nesta versão inicial.

## Estrutura do projeto

```text
infra-automation-scripts/
├── README.md
├── powershell/
│   ├── armazenamento/
│   │   ├── 002_Identificar_discos_com_pouco_espaco_livre.ps1
│   │   └── 002-5_Consultar_a_saude_reportada_dos_discos.ps1
│   ├── conectividade/
│   │   └── 004_Testar_conectividade_TCP_com_servidores_e_servicos.ps1
│   ├── eventos/
│   │   ├── 005_Consultar_erros_eventos_críticos_24_hs.ps1
│   │   └── 006_Converter_EVTX_to_CSV.ps1
│   ├── servicos/
│   │   └── 003_ConsutarServices_Fora_Execucao.ps1
│   └── sistema/
│       └── 001_ConsutarServer_Memo_Uptime.ps1
├── bash/
└── docs/
    └── posts-linkedin/
```

A estrutura acima representa a organização planejada. Pastas reservadas que ainda estejam vazias podem não aparecer na versão publicada.

Os nomes atuais dos arquivos foram preservados para manter a relação com a sequência de publicações, incluindo a numeração complementar `002-5`.

## Índice dos scripts

| Identificação | Script | Finalidade |
|---|---|---|
| 001 | [Informações do sistema, memória e uptime](powershell/sistema/001_ConsutarServer_Memo_Uptime.ps1) | Apresentar informações básicas do computador local. |
| 002 | [Unidades com pouco espaço livre](powershell/armazenamento/002_Identificar_discos_com_pouco_espaco_livre.ps1) | Identificar unidades abaixo do percentual livre configurado. |
| 002-5 | [Saúde reportada dos dispositivos e volumes](powershell/armazenamento/002-5_Consultar_a_saude_reportada_dos_discos.ps1) | Consultar separadamente dispositivos de armazenamento e volumes com letra. |
| 003 | [Serviços automáticos fora de execução](powershell/servicos/003_ConsutarServices_Fora_Execucao.ps1) | Listar serviços automáticos cujo estado seja diferente de `Running`. |
| 004 | [Conectividade TCP](powershell/conectividade/004_Testar_conectividade_TCP_com_servidores_e_servicos.ps1) | Testar combinações configuradas de servidor e porta. |
| 005 | [Eventos críticos e erros recentes](powershell/eventos/005_Consultar_erros_eventos_críticos_24_hs.ps1) | Consultar os logs `System` e `Application` em um período configurável. |
| 006 | [Conversão de EVTX para CSV](powershell/eventos/006_Converter_EVTX_to_CSV.ps1) | Exportar campos selecionados de um arquivo EVTX para CSV. |

## Pré-requisitos

Confira sempre o cabeçalho do script antes da execução.

De forma geral, as rotinas atuais exigem:

- Windows.
- Windows PowerShell 5.1 ou PowerShell 7, conforme a disponibilidade dos módulos e cmdlets utilizados.
- Permissão para consultar os recursos envolvidos.
- Git instalado para clonar e atualizar a cópia local do repositório.
- Revisão dos parâmetros, destinos e caminhos antes de executar.

### Requisitos específicos

| Script | Requisito adicional |
|---|---|
| 001 | Acesso às classes CIM `Win32_OperatingSystem` e `Win32_ComputerSystem`. |
| 002 | Acesso à classe CIM `Win32_LogicalDisk`. |
| 002-5 | Módulo `Storage`, com `Get-PhysicalDisk` e `Get-Volume` disponíveis. |
| 003 | Acesso à classe CIM `Win32_Service`. Para `DelayedAutoStart`, Windows 10 ou Windows Server 2016 e posteriores. |
| 004 | Cmdlet `Test-NetConnection` disponível e destinos autorizados para teste. |
| 005 | Cmdlet `Get-WinEvent` e permissão de leitura nos logs consultados. |
| 006 | Cmdlet `Get-WinEvent`, EVTX acessível e permissão de escrita em uma pasta de saída existente. |

A disponibilidade de um cmdlet em uma sessão não garante que todos os recursos possam ser consultados com as permissões atuais.

## Como começar

### 1. Obter uma cópia do projeto

No PowerShell, entre na pasta em que deseja armazenar o repositório e execute:

```powershell
git clone [https://github.com/joaofernandespn/infra-automation-scripts.git](https://github.com/joaofernandespn/infra-automation-scripts.git)
```

Depois, entre na pasta criada:

```powershell
Set-Location -LiteralPath ".\infra-automation-scripts"
```

Os exemplos de execução abaixo consideram que o terminal está na raiz do repositório.

Se você já possui uma cópia local, não precisa clonar novamente.

### 2. Revisar antes de executar

Antes de iniciar qualquer rotina:

1. Leia o código e o cabeçalho.
2. Confira os pré-requisitos.
3. Ajuste os valores de exemplo quando necessário.
4. Verifique se possui autorização para consultar os recursos.
5. Teste em um ambiente adequado.
6. Analise o resultado dentro do contexto do incidente.

Não altere políticas de execução, permissões ou controles de segurança indiscriminadamente para contornar uma mensagem de erro. Identifique a restrição e siga as regras do ambiente.

## Scripts disponíveis

### 001 — Informações do sistema, memória e uptime

Apresenta:

- Nome do computador.
- Sistema operacional e versão.
- Memória total e livre reportadas, em GiB.
- Data e hora da última inicialização.
- Tempo decorrido desde a última inicialização reportada.

#### Execução

```powershell
.\powershell\sistema\001_ConsutarServer_Memo_Uptime.ps1
```

#### Cuidados de interpretação

- A memória livre representa o momento da consulta.
- A memória total é o valor reportado por `Win32_ComputerSystem`, não um inventário dos módulos físicos instalados.
- O uptime é calculado a partir de `LastBootUpTime`.
- A rotina consulta o computador local.

### 002 — Identificar unidades com pouco espaço livre

Consulta as unidades lógicas classificadas pelo Windows como disco local/fixo, usando `DriveType=3`.

Apresenta:

- Unidade.
- Capacidade em GiB.
- Espaço livre em GiB.
- Percentual livre.
- Classificação `OK` ou `ATENCAO`.

O limite padrão é de 20% de espaço livre.

#### Execução padrão

```powershell
.\powershell\armazenamento\002_Identificar_discos_com_pouco_espaco_livre.ps1
```

#### Execução com limite personalizado

```powershell
.\powershell\armazenamento\002_Identificar_discos_com_pouco_espaco_livre.ps1 `
    -LimiteLivre 15 `
    -Verbose
```

#### Cuidados de interpretação

- `ATENCAO` indica percentual livre abaixo do limite configurado.
- Com limite de 20%, uma unidade com exatamente 20% permanece como `OK`.
- A classificação usa o percentual antes do arredondamento.
- Uma unidade pode aparecer com `20,00` na tabela e receber `ATENCAO` se o valor original estiver ligeiramente abaixo de 20%.
- `OK` significa apenas que o critério de espaço livre foi atendido.
- O script não avalia a saúde do dispositivo nem executa limpeza.

### 002-5 — Consultar a saúde reportada dos dispositivos e volumes

Apresenta dois relatórios independentes:

1. Dispositivos de armazenamento retornados por `Get-PhysicalDisk`.
2. Volumes com letra de unidade retornados por `Get-Volume`.

#### Execução

```powershell
.\powershell\armazenamento\002-5_Consultar_a_saude_reportada_dos_discos.ps1
```

#### Cuidados de interpretação

- Dispositivos e volumes representam camadas diferentes.
- O script não associa automaticamente um dispositivo a uma letra de unidade.
- Um dispositivo reportar `Healthy` não determina a saúde dos volumes.
- Os alertas resumidos destacam saúde diferente de `Healthy`.
- A coluna `Operacao` também precisa ser analisada.
- `Nao informado` é uma indicação adicionada pelo script quando a propriedade não retorna informação.
- Volumes sem letra de unidade não entram no relatório.
- A visibilidade depende do hardware, dos drivers e dos provedores de armazenamento.
- `Healthy` não equivale a um diagnóstico completo nem substitui backup.
- O script não executa CHKDSK ou reparos.

### 003 — Listar serviços automáticos fora de execução

Consulta serviços com `StartMode='Auto'` e apresenta aqueles cujo estado seja diferente de `Running`.

A tabela inclui:

- Nome técnico.
- Nome de exibição.
- Estado.
- Modo de inicialização.
- Indicação de inicialização automática atrasada.

#### Execução

```powershell
.\powershell\servicos\003_ConsutarServices_Fora_Execucao.ps1
```

#### Cuidados de interpretação

- A lista representa o estado no momento da coleta.
- O filtro inclui estados diferentes de `Running`, não apenas `Stopped`.
- Um serviço listado não representa, isoladamente, uma falha confirmada.
- Considere a indicação de início atrasado ao consultar logo após a inicialização.
- O script não analisa dependências, gatilhos ou eventos dos serviços.
- Não inicia, para, reinicia ou modifica serviços.

### 004 — Testar conectividade TCP

Testa uma lista de combinações de servidor e porta, apresentando:

- Servidor.
- IP remoto retornado.
- Porta.
- Resultado.
- Detalhe da consulta ou erro.

#### Configuração

Antes de executar, ajuste a lista `$Destinos` no script:

```powershell
$Destinos = @(
    [PSCustomObject]@{
        Servidor = "web01.seudominio.local"
        Porta    = 443
    }
    [PSCustomObject]@{
        Servidor = "srv01.seudominio.local"
        Porta    = 3389
    }
    [PSCustomObject]@{
        Servidor = "sql01.seudominio.local"
        Porta    = 1433
    }
)
```

Os nomes são exemplos. Confirme os destinos e as portas reais, e teste somente recursos autorizados.

#### Execução

```powershell
.\powershell\conectividade\004_Testar_conectividade_TCP_com_servidores_e_servicos.ps1
```

#### Interpretação

| Resultado | Significado |
|---|---|
| `SUCESSO` | O teste confirmou o estabelecimento da conexão TCP. |
| `FALHA` | O teste não confirmou o estabelecimento da conexão TCP. |
| `ERRO` | A validação ou a execução gerou uma exceção capturada pelo script. |

#### Cuidados de interpretação

- `SUCESSO` não valida autenticação, TLS, consultas ao banco ou transações da aplicação.
- `FALHA` não determina, isoladamente, a causa do problema.
- O IP exibido corresponde a `RemoteAddress`, não a todos os endereços associados ao nome.
- Os testes são sequenciais e podem demorar em destinos inacessíveis.
- O script não altera firewall nem habilita serviços.

### 005 — Consultar eventos críticos e erros recentes

Consulta os logs `System` e `Application` com os níveis:

- `1`: Crítico.
- `2`: Erro.

O período padrão é de 24 horas, com limite de 50 eventos no total.

#### Execução padrão

```powershell
.\powershell\eventos\005_Consultar_erros_eventos_críticos_24_hs.ps1
```

#### Execução personalizada

```powershell
.\powershell\eventos\005_Consultar_erros_eventos_críticos_24_hs.ps1 `
    -Horas 48 `
    -LimiteEventos 100
```

#### Cuidados de interpretação

- O limite é aplicado ao resultado combinado dos logs, não individualmente a cada log.
- Os resultados são apresentados dos mais recentes para os mais antigos.
- Ao atingir o limite, o script avisa que pode haver outros eventos.
- Não é feita uma contagem adicional para confirmar eventos além do limite.
- A ausência de correspondências é diferenciada de outras falhas na consulta.
- Nenhum evento encontrado não significa ausência de problemas.
- Alguns campos textuais podem aparecer vazios nos resultados.
- A rotina não modifica nem limpa os registros.

Use a saída como triagem: relacione horário, origem e mensagem com o contexto do incidente.

### 006 — Converter EVTX para CSV

Lê um arquivo EVTX e exporta os seguintes campos:

- `TimeCreated`
- `Id`
- `LevelDisplayName`
- `ProviderName`
- `LogName`
- `RecordId`
- `MachineName`
- `Message`

#### Execução com saída automática

```powershell
.\powershell\eventos\006_Converter_EVTX_to_CSV.ps1 `
    -Arquivo "C:\Logs\Sistema.evtx"
```

Nesse exemplo, o destino padrão é:

```text
C:\Logs\Sistema_Eventos.csv
```

#### Execução com destino e delimitador personalizados

```powershell
.\powershell\eventos\006_Converter_EVTX_to_CSV.ps1 `
    -Arquivo "C:\Logs\Sistema.evtx" `
    -Saida "C:\Relatorios\Sistema_Eventos.csv" `
    -Delimitador ";"
```

Os caminhos são exemplos. O EVTX precisa existir e a pasta de saída deve estar criada.

#### Conferir o CSV gerado

```powershell
$EventosCSV = @(
    Import-Csv -LiteralPath "C:\Relatorios\Sistema_Eventos.csv" `
        -Delimiter ";" `
        -Encoding UTF8 `
        -ErrorAction Stop
)

"Registros no CSV: {0}" -f $EventosCSV.Count

$EventosCSV |
    Select-Object -First 3 TimeCreated, Id, LevelDisplayName, ProviderName |
    Format-Table -AutoSize
```

#### Cuidados de interpretação

- O EVTX original não é alterado.
- O destino não pode existir: o script recusa sobrescrita.
- O CSV contém somente os campos selecionados; preserve o EVTX original.
- Uma falha durante o processamento pode deixar um CSV parcial.
- Não considere um arquivo parcial como exportação concluída.
- Campos como `MachineName` e `Message` podem conter informações sensíveis.

## Padrão adotado nos scripts

As rotinas são organizadas com:

1. Cabeçalho explicando finalidade, pré-requisitos e autoria.
2. Blocos lógicos separados por comentários.
3. Comentários nos comandos e parâmetros relevantes.
4. Tratamento básico de erros.
5. Explicação das limitações e do alcance dos resultados.
6. Valores de exemplo ou parâmetros para adaptação ao ambiente.

Alguns arquivos também incluem, em comentários, o texto de referência das publicações no LinkedIn.

Esses comentários são mantidos como apoio editorial e não devem ser confundidos com comandos a executar.

## Validação inicial

Foram realizados testes locais em Windows 11 Pro, com os seguintes cenários observados:

| Script | Cenário conferido |
|---|---|
| 001 | Consulta de sistema, memória e uptime. |
| 002 | Classificação de unidades acima e abaixo do limite de espaço livre. |
| 002-5 | Consulta de dispositivos e volumes, incluindo volume com aviso de saúde. |
| 003 | Listagem de serviços automáticos fora de execução. |
| 004 | Conexões TCP com resultados de sucesso e falha. |
| 005 | Consulta com eventos encontrados nos logs System e Application. |
| 006 | Exportação, leitura do CSV e recusa de sobrescrita. |

Esses testes são uma validação básica no ambiente utilizado.

Não representam cobertura de todos os caminhos de erro nem certificação de compatibilidade com todas as versões de Windows, PowerShell, drivers ou provedores.

## Segurança e uso responsável

Antes de executar ou compartilhar alterações:

- Revise o código e os valores configurados.
- Teste em um ambiente apropriado.
- Utilize somente destinos e recursos autorizados.
- Não inclua senhas, tokens ou credenciais no código.
- Não publique dados de clientes ou detalhes internos sem autorização.
- Revise nomes de máquinas, IPs, domínios e caminhos nas saídas de diagnóstico.
- Mantenha arquivos de teste e relatórios sensíveis fora do repositório.
- Preserve os arquivos originais usados em análises.
- Não trate uma mensagem `OK`, `Healthy` ou `SUCESSO` como garantia completa do ambiente.
- Não execute ações corretivas em massa apenas com base em uma listagem.

O objetivo das rotinas de diagnóstico é apoiar a investigação, não substituir a análise técnica do contexto.

## Versionamento

A identificação do script e a versão do código têm funções diferentes:

- `001`, `002`, `002-5` e demais números identificam a sequência da série.
- `1.0.0`, `1.0.1` e outras versões identificam a evolução do código.

Como convenção do projeto:

| Tipo de mudança | Exemplo |
|---|---|
| Primeira versão organizada para publicação | `1.0.0` |
| Correção sem mudança na forma de uso | `1.0.1` |
| Recurso adicional compatível com o uso anterior | `1.1.0` |
| Mudança que exige adaptar a forma de execução | `2.0.0` |

O histórico de commits será utilizado para registrar as alterações.

A indicação de versão no cabeçalho não significa, por si só, que exista uma tag ou uma release publicada.

## Ideias para evolução

Possíveis próximos passos, ainda não apresentados como recursos disponíveis:

- Rotinas Linux em Bash.
- Documentação complementar por script.
- Organização dos textos do LinkedIn em `docs/posts-linkedin`.
- Histórico consolidado em `CHANGELOG.md`.
- Validação automatizada de sintaxe e estilo.
- Testes automatizados.
- Exportações e integrações adicionais.
- Empacotamento de funções reutilizáveis.

## Sugestões e contribuições

Sugestões de melhoria podem incluir:

- Correções de código ou documentação.
- Exemplos genéricos.
- Melhorias no tratamento de erros.
- Cenários de teste.
- Relatos de compatibilidade.
- Novos temas úteis à rotina de infraestrutura.

Ao relatar um problema, informe:

- Script utilizado.
- Versão do Windows e do PowerShell.
- Comando executado.
- Comportamento esperado.
- Resultado observado.
- Mensagem de erro, quando houver.

Remova informações sensíveis antes de compartilhar.

## Licença

A licença de uso deste projeto ainda está em definição.

Este README não concede uma licença de reutilização. Consulte o arquivo `LICENSE` quando ele for adicionado para conhecer os termos adotados.

## Autor

João Fernandes

Profissional de tecnologia com mais de 20 anos de experiência em infraestrutura, cloud, redes, segurança da informação e bancos de dados.

GitHub: [joaofernandespn](https://github.com/joaofernandespn)

Este repositório faz parte do projeto Scripts de Infra para LinkedIn.