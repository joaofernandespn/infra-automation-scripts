# Scripts de Automação e Diagnóstico de Infraestrutura

Biblioteca de scripts comentados em PowerShell e Python para apoiar rotinas de diagnóstico e automação de Analistas de Infraestrutura e Sysadmins.

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

Os scripts PowerShell são voltados ao Windows. A série em Python foi iniciada com o Script 011, validado em Windows 11 Pro.

As rotinas atuais consultam:

- Informações do sistema operacional, memória e uptime.
- Espaço livre nas unidades locais.
- Saúde reportada dos dispositivos de armazenamento e dos volumes.
- Serviços automáticos fora de execução.
- Conectividade TCP com servidores e serviços.
- Eventos críticos e erros nos logs do Windows.
- Arquivos EVTX para exportação de campos selecionados em CSV.
- Certificados vencidos ou próximos do vencimento nos repositórios do computador local.
- Resolução DNS de um nome em servidores DNS informados, com consulta separada por servidor.
- Indícios de reinicialização pendente no Registro do computador local.
- Contas reportadas como bloqueadas no Windows local ou no Active Directory.

Os scripts de diagnóstico não iniciam serviços, não executam reparos de armazenamento e não apagam registros.

O script de conversão de EVTX para CSV cria um arquivo de saída. O teste de conectividade TCP realiza conexões aos destinos configurados.

O Script 008 consulta servidores DNS informados pelo operador, mas não altera registros, cache DNS nem o arquivo Hosts.

O Script 009 consulta três indicadores de reinicialização pendente no Registro local, sem modificar valores ou reiniciar o computador.

O Script 010 permite consultar contas bloqueadas no computador local, no Active Directory ou em ambas as origens. Não desbloqueia, habilita ou modifica contas.

Os Scripts 011 e 012 são os primeiros scripts em Python da série. O 011 consulta o ambiente do processo Python que o executa. O 012 consulta o ambiente de pacotes (`pip`, pasta de pacotes e ambiente virtual). Ambos usam apenas a biblioteca padrão. Não instalam pacotes, não alteram configurações e não gravam arquivos.

A pasta `bash` está reservada para futuras rotinas Linux. Ainda não há scripts Bash nesta versão inicial.

## Estrutura do projeto

```text
infra-automation-scripts/
├── README.md
├── powershell/
│   ├── active-directory/
│   │   └── 010_Listar_contas_bloqueadas_Windows_AD.ps1
│   ├── armazenamento/
│   │   ├── 002_Identificar_discos_com_pouco_espaco_livre.ps1
│   │   └── 002-5_Consultar_a_saude_reportada_dos_discos.ps1
│   ├── certificados/
│   │   └── 007_Consultar_certificados_proximos_do_vencimento.ps1
│   ├── conectividade/
│   │   ├── 004_Testar_conectividade_TCP_com_servidores_e_servicos.ps1
│   │   └── 008_Diagnosticar_resolucao_DNS.ps1
│   ├── eventos/
│   │   ├── 005_Consultar_erros_eventos_críticos_24_hs.ps1
│   │   └── 006_Converter_EVTX_to_CSV.ps1
│   ├── servicos/
│   │   └── 003_ConsutarServices_Fora_Execucao.ps1
│   └── sistema/
│       ├── 001_ConsutarServer_Memo_Uptime.ps1
│       └── 009_Consultar_indicios_de_reinicializacao_pendente.ps1
├── python/
│   └── sistema/
│       ├── 011_Consultar_ambiente_Python.py
│       └── 012_Consultar_ambiente_de_pacotes_pip.py
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
| 007 | [Certificados vencidos ou próximos do vencimento](powershell/certificados/007_Consultar_certificados_proximos_do_vencimento.ps1) | Consultar vencimentos nos repositórios My, WebHosting e Remote Desktop do computador local. |
| 008 | [Diagnóstico de resolução DNS](powershell/conectividade/008_Diagnosticar_resolucao_DNS.ps1) | Consultar um nome em servidores DNS informados, separadamente, nos tipos A, AAAA, CNAME ou SRV. |
| 009 | [Indícios de reinicialização pendente](powershell/sistema/009_Consultar_indicios_de_reinicializacao_pendente.ps1) | Consultar três indicadores no Registro local, sem reiniciar o computador. |
| 010 | [Contas bloqueadas no Windows e no AD](powershell/active-directory/010_Listar_contas_bloqueadas_Windows_AD.ps1) | Listar contas reportadas como bloqueadas no computador local, no Active Directory ou em ambas as origens. |
| 011 | [Consulta do ambiente Python](python/sistema/011_Consultar_ambiente_Python.py) | Apresentar versão, executável, sistema operacional e caminhos do processo Python em execução. |
| 012 | [Ambiente de pacotes e pip](python/sistema/012_Consultar_ambiente_de_pacotes_pip.py) | Apresentar ambiente virtual, pasta de pacotes, pip do interpretador e comparação com o comando `pip` do PATH. |

## Pré-requisitos

Confira sempre o cabeçalho do script antes da execução.

De forma geral, as rotinas atuais exigem:

- Windows.
- Windows PowerShell 5.1 ou PowerShell 7, conforme a disponibilidade dos módulos e cmdlets utilizados.
- Permissão para consultar os recursos envolvidos.
- Git instalado para clonar e atualizar a cópia local do repositório.
- Revisão dos parâmetros, destinos e caminhos antes de executar.
- Python 3.6 ou superior para os scripts em Python, conforme o cabeçalho de cada arquivo.

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
| 007 | Provedor `Certificate` disponível e permissão de leitura nos repositórios consultados em `Cert:\LocalMachine`. Repositórios ausentes são informados e não impedem as demais consultas. |
| 008 | Cmdlet `Resolve-DnsName` disponível e acesso de rede aos servidores DNS autorizados. A execução é interativa: nome, IPs e tipo são informados no terminal. |
| 009 | Permissão de leitura nas chaves consultadas em `HKEY_LOCAL_MACHINE`. Usa a visão de 64 bits do Registro quando o Windows é de 64 bits. |
| 010 | Para consulta local: `Get-CimInstance` e acesso às classes `Win32_ComputerSystem` e `Win32_UserAccount`. Para AD: módulo `ActiveDirectory` disponível e funcional, acesso ao controlador informado e permissão de consulta. |
| 011 | Python instalado e acessível pelo comando `python`. Usa somente a biblioteca padrão. A validação atual cobre CPython 3.15.2 em Windows 11 Pro. |
| 012 | Python 3.8 ou superior, pelo uso de `importlib.metadata`. Usa somente a biblioteca padrão e executa `pip --version` para consultar a versão e o local do pip. |

A disponibilidade de um cmdlet em uma sessão não garante que todos os recursos possam ser consultados com as permissões atuais.

## Como começar

### 1. Obter uma cópia do projeto

No PowerShell, entre na pasta em que deseja armazenar o repositório e execute:

```powershell
git clone https://github.com/joaofernandespn/infra-automation-scripts.git
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

### 007 — Consultar certificados vencidos ou próximos do vencimento

Consulta os seguintes repositórios do computador local:

- `Cert:\LocalMachine\My`
- `Cert:\LocalMachine\WebHosting`
- `Cert:\LocalMachine\Remote Desktop`

Inclui todos os certificados vencidos encontrados e os que vencem até o momento da consulta acrescido da quantidade de dias informada.

A janela padrão é de 30 dias. O parâmetro `Dias` aceita valores de 1 a 3650.

Apresenta:

- Computador e repositório de origem.
- Assunto e emissor.
- Data e hora do vencimento.
- Situação: `VENCIDO` ou `A VENCER`.
- Thumbprint.
- Momento da coleta.

#### Execução padrão

```powershell
.\powershell\certificados\007_Consultar_certificados_proximos_do_vencimento.ps1
```

#### Execução com janela personalizada

```powershell
.\powershell\certificados\007_Consultar_certificados_proximos_do_vencimento.ps1 `
    -Dias 365 `
    -Verbose
```

#### Visualizar os detalhes

```powershell
.\powershell\certificados\007_Consultar_certificados_proximos_do_vencimento.ps1 `
    -Dias 365 |
    Format-List *
```

#### Cuidados de interpretação

- `A VENCER` indica um certificado ainda não vencido dentro da janela escolhida; não representa, isoladamente, urgência.
- Certificados vencidos entram no resultado independentemente de quanto tempo passou desde o vencimento.
- A ordenação considera vencimento e repositório.
- O mesmo certificado em repositórios diferentes permanece em registros separados.
- Repositórios ausentes são informados por aviso.
- Falhas de consulta são informadas e tornam o relatório parcial.
- Sem correspondências significa ausência de resultados apenas nos repositórios consultados com sucesso.
- O script não consulta certificados do usuário atual, outros computadores ou endpoints.
- Não confirma quais certificados estão em uso pelos serviços.
- Não valida cadeia de confiança, revogação, finalidade ou início da validade.
- Não renova, remove, importa ou altera certificados.
- Revise nomes, assuntos e emissores antes de compartilhar os resultados.

### 008 — Diagnosticar resolução DNS

Consulta um nome em um ou mais servidores DNS informados e apresenta o resultado de cada servidor separadamente.

Solicita:

- Nome DNS, sem URL, porta ou endereço IP.
- IPs dos servidores DNS, separados por vírgula.
- Tipo `A`, `AAAA`, `CNAME` ou `SRV`. Enter seleciona `A`.

Apresenta:

- Servidor DNS consultado.
- Nome e tipo da consulta.
- Situação: `RESPOSTA`, `SEM RESPOSTAS` ou `ERRO`.
- Registro e tipo retornados.
- Dados e TTL.
- Momento da coleta e detalhe do erro.

#### Execução

```powershell
.\powershell\conectividade\008_Diagnosticar_resolucao_DNS.ps1
```

#### Visualizar os detalhes

```powershell
.\powershell\conectividade\008_Diagnosticar_resolucao_DNS.ps1 |
    Format-List *
```

#### Cuidados de interpretação

- Diferenças entre servidores, inclusive na ordem dos endereços, não confirmam erro por si só.
- `RESPOSTA` não comprova o funcionamento de sites ou aplicações.
- `SEM RESPOSTAS` indica ausência de registros na seção `Answer`.
- `ERRO` preserva a mensagem da exceção; a falha de um servidor não impede as consultas aos demais.
- O script usa `-DnsOnly` e `-NoHostsFile`, sem consultar o arquivo Hosts.
- Consultas reversas (PTR) não estão incluídas.
- A validação do nome é básica e não verifica toda a sintaxe DNS.
- Não altera DNS, não limpa cache e não modifica o arquivo Hosts.
- Consulte somente servidores autorizados e revise nomes e IPs antes de compartilhar a saída.


### 009 — Consultar indícios de reinicialização pendente

Consulta três indicadores no Registro do computador local:

- Chave `RebootPending` do Component Based Servicing.
- Chave `RebootRequired` do Windows Update.
- Conteúdo não vazio no valor `PendingFileRenameOperations` do Session Manager.

Apresenta:

- Computador e verificação realizada.
- Situação: `INDICIO ENCONTRADO`, `NAO ENCONTRADO` ou `ERRO`.
- Local consultado e visão do Registro.
- Momento da coleta.
- Detalhes do resultado ou da falha.

#### Execução

```powershell
.\powershell\sistema\009_Consultar_indicios_de_reinicializacao_pendente.ps1
```

#### Visualizar os detalhes

```powershell
.\powershell\sistema\009_Consultar_indicios_de_reinicializacao_pendente.ps1 |
    Format-List *
```

#### Cuidados de interpretação

- A ausência dos três indicadores não garante ausência de outras pendências.
- Um indicador encontrado não determina a causa ou a urgência para reiniciar.
- A contagem de entradas textuais não representa o número de arquivos ou operações.
- Falhas de leitura tornam a cobertura parcial.
- O script não consulta computadores remotos.
- Não instala atualizações, modifica o Registro ou reinicia o computador.

### 010 — Listar contas bloqueadas no Windows e no AD

Permite selecionar:

- `Local`: contas locais deste computador.
- `AD`: contas de usuário no Active Directory, pelo controlador informado.
- `Ambos`: executa as consultas separadamente.

Não exige informar previamente o nome de um usuário.

Usa `Win32_UserAccount` na consulta local e
`Search-ADAccount -LockedOut -UsersOnly` na consulta AD.

Apresenta duas coleções:

- `Contas`: nome, login, origem, destino consultado, estado reportado,
  SID e momento da coleta.
- `Cobertura`: situação e quantidade retornada por origem,
  com detalhes de eventuais falhas.

#### Execução interativa

```powershell
.\powershell\active-directory\010_Listar_contas_bloqueadas_Windows_AD.ps1
```

#### Consultar somente contas locais

```powershell
.\powershell\active-directory\010_Listar_contas_bloqueadas_Windows_AD.ps1 `
    -Escopo Local
```

#### Consultar o AD

```powershell
.\powershell\active-directory\010_Listar_contas_bloqueadas_Windows_AD.ps1 `
    -Escopo AD `
    -ServidorAD "dc01.seudominio.local"
```

Substitua o controlador de exemplo pelo destino autorizado.

#### Retornar objetos para análise

```powershell
$Relatorio = .\powershell\active-directory\010_Listar_contas_bloqueadas_Windows_AD.ps1 `
    -Escopo Local `
    -PassThru

$Relatorio.Contas | Format-List *
$Relatorio.Cobertura | Format-List *
```

#### Cuidados de interpretação

- Consulta o estado reportado, não o histórico de eventos de bloqueio.
- Conta bloqueada e conta desabilitada são condições diferentes.
- A consulta local abrange apenas o computador onde o script é executado.
- Em controlador de domínio, o script recusa a consulta local e orienta usar AD.
- No escopo `Ambos`, a falha de uma origem não impede a consulta da outra.
- A consulta AD usa o controlador informado; não consulta automaticamente toda a floresta.
- O estado pode mudar durante ou após a coleta.
- No AD, o campo `Nome` usa a propriedade `Name`, não necessariamente o nome completo da pessoa.
- Na consulta local, se `FullName` estiver vazio, o campo `Nome` usa o nome da conta.
- O script não consulta Microsoft Entra ID ou bloqueios de aplicações.
- Não identifica a causa do bloqueio.
- Uma falha não deve ser interpretada como ausência de contas bloqueadas.
- Não desbloqueia, habilita ou modifica contas.

### 011 — Consultar o ambiente Python

Apresenta:

- Momento da coleta, com deslocamento em relação ao UTC.
- Versão e implementação do Python.
- Caminho do executável Python.
- Sistema operacional, release e versão reportados.
- Diretório de trabalho atual.
- Caminho absoluto do arquivo executado.

#### Execução

```powershell
python .\python\sistema\011_Consultar_ambiente_Python.py
```

Para consultar o código de saída no PowerShell:

```powershell
$LASTEXITCODE
```

O código `0` indica consulta concluída. O código `1` indica falha capturada pelo script.

#### Cuidados de interpretação

- Consulta somente o ambiente do processo que executou o script.
- Não faz inventário de todas as instalações do Python.
- Outro terminal pode resolver o comando `python` para um interpretador diferente.
- O diretório de trabalho depende de onde o script foi iniciado e pode ser diferente da pasta do arquivo.
- Não valida o `pip`, bibliotecas externas ou a saúde do Windows.
- Não instala, altera configurações nem grava arquivos.
- Revise caminhos e nomes de usuário antes de compartilhar a saída.

### 012 — Consultar o ambiente de pacotes (pip)

Apresenta:

- Executável e versão do Python.
- Se o interpretador está em ambiente virtual.
- Prefixo em uso e prefixo base.
- Pasta de pacotes (`site-packages`) e escrita reportada pelo sistema.
- Quantidade de pacotes visíveis ao interpretador.
- Resultado de `python -m pip --version`.
- Comando `pip` encontrado no PATH e seu resultado.
- Comparação entre os dois `pip`.

#### Execução

```powershell
python .\python\sistema\012_Consultar_ambiente_de_pacotes_pip.py
```

Para consultar o código de saída no PowerShell:

```powershell
$LASTEXITCODE
```

O código `0` indica consulta concluída. O código `1` indica falha capturada pelo script.

#### Cuidados de interpretação

- Consulta somente o interpretador que executou o script.
- `MESMO PIP` compara o texto retornado por `pip --version`, incluindo o caminho.
- `DIFERENTE` indica que o comando `pip` do PATH pertence a outro ambiente.
- `NAO VERIFICADO` indica que um dos dois não pôde ser consultado.
- A ausência de variável `VIRTUAL_ENV` não significa ausência de ambiente virtual; o script usa os prefixos do Python.
- `Escrita reportada` vem do sistema e não garante que uma instalação será permitida.
- Não valida versões de pacotes, vulnerabilidades, rede ou configuração de proxy.
- Não instala, atualiza nem remove pacotes.
- Revise caminhos e nomes de usuário antes de compartilhar a saída.

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

O Script 007 foi testado em um computador Windows local e em um servidor Windows, com os seguintes cenários observados:

| Cenário do Script 007 | Resultado observado |
|---|---|
| Três repositórios disponíveis | Consultas concluídas sem falhas reportadas. |
| Repositório WebHosting ausente | Aviso apresentado e demais consultas mantidas. |
| Nenhuma correspondência | Mensagem informativa apresentada. |
| Janela personalizada de 365 dias | Retorno de certificados classificados como `A VENCER`. |
| Identificação e ordenação | Repositório de origem apresentado e resultados ordenados por vencimento. |

Os cenários de certificado vencido e falha de leitura de repositório ainda não foram testados.

Esses testes são uma validação básica no ambiente utilizado.

Não representam cobertura de todos os caminhos de erro nem certificação de compatibilidade com todas as versões de Windows, PowerShell, drivers ou provedores.

O Script 008 foi testado em um computador Windows local, com os seguintes cenários observados:

| Cenário do Script 008 | Resultado observado |
|---|---|
| Consulta tipo `A` em dois servidores DNS | Resultados separados por servidor, com múltiplos registros preservados. |
| IP incompleto, inválido ou separado por vírgulas | Entrada rejeitada. |
| Lista com IP válido e itens inválidos | Entrada rejeitada. |
| Tipos inválidos | Entrada rejeitada. |

Os demais tipos, IPv6, nome vazio ou IP no campo de nome, Enter como tipo padrão, falha de consulta e ausência de registros em `Answer` ainda não foram testados na versão atual.

### Validação do Script 009

| Cenário | Resultado observado |
|---|---|
| Consulta local na visão `Registry64` | Três verificações concluídas, sem falhas reportadas. |
| Chaves `RebootPending` e `RebootRequired` ausentes | Classificadas como `NAO ENCONTRADO`. |
| `PendingFileRenameOperations` com conteúdo | Classificado como `INDICIO ENCONTRADO`. |
| Mensagem de contagem após correção | Quantidade de entradas textuais exibida corretamente. |
| Resumo | Coerente com as verificações apresentadas. |

Permanecem sem teste: presença das duas chaves indicadoras,
valor ausente ou vazio, tipo inesperado, falha de leitura
e demais combinações de Windows e PowerShell.

### Validação do Script 010

| Cenário | Resultado observado |
|---|---|
| Escopo AD | Consulta concluída sem contas bloqueadas retornadas e sem erro reportado. |
| Escopo Local em computador Windows | Consulta concluída sem contas bloqueadas retornadas e sem erro reportado. |
| Escopo Ambos em controlador de domínio | Consulta local recusada pela proteção do script; consulta AD mantida. |
| Cobertura | Origens apresentadas separadamente, com aviso quando uma delas não foi consultada. |

Permanecem sem teste: listagem com contas bloqueadas,
retorno com `PassThru` e demais caminhos de erro.

Os testes da implementação anterior baseada em eventos 4740
não validam esta implementação de consulta de contas bloqueadas.

### Validação do Script 011

O Script 011 foi testado em uma máquina virtual com Windows 11 Pro, versão 10.0.26300, usando CPython 3.15.2.

| Cenário | Resultado observado |
|---|---|
| Execução a partir da raiz do projeto | Relatório apresentado sem erro. |
| Versão e implementação | Python 3.15.2 e CPython. |
| Executável identificado | Caminho do interpretador apresentado. |
| Diretório de trabalho e arquivo executado | Raiz do projeto e caminho completo do script, apresentados separadamente. |
| Código de saída | `0` |

Permanecem sem teste: caminhos de erro, outros sistemas operacionais, outras versões do Python e a versão mínima declarada no cabeçalho.

### Validação do Script 012

O Script 012 foi testado em uma máquina virtual com Windows 11 Pro, usando CPython 3.15.2 e pip 26.2.2.

| Cenário | Resultado observado |
|---|---|
| Python instalado, sem ambiente virtual | `Ambiente virtual: NAO`; `python -m pip` e comando `pip` do PATH apontaram para o mesmo pip. |
| Execução com o Python de um ambiente virtual criado para teste | `Ambiente virtual: SIM`; prefixo e pasta de pacotes dentro do ambiente virtual. |
| Comando `pip` do PATH fora do ambiente virtual | Comparação `DIFERENTE`, apesar da mesma versão do pip. |

Permanecem sem teste: `pip` ausente, comando `pip` ausente do PATH, falha ao executar o pip, outros sistemas operacionais, outras versões do Python e a versão mínima declarada.

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

- Ampliar a série em Python, mantendo documentação, tratamento de erros e validação por cenário.
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