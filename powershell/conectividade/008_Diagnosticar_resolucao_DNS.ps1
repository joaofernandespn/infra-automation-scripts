<#
Finalidade: Consultar um nome em servidores DNS informados.
Pre-requisitos: Windows, PowerShell 5.1+, Resolve-DnsName
disponivel e acesso aos servidores DNS autorizados.
Autor: Joao Fernandes | Scripts de Infra para LinkedIn
Versao: 1.0.0

Entrada:
- Nome DNS para consultar, sem URL ou endereco IP.
- IPs dos servidores DNS separados por virgula.
- Tipo A, AAAA, CNAME ou SRV. Enter seleciona A.

Saida:
Objetos com servidor consultado, nome, tipo, registro,
dados, TTL, momento da coleta e eventual mensagem de erro.

Escopo:
- Consulta sequencial por servidor.
- Preserva os registros da secao Answer.
- Ignora o arquivo Hosts e nao usa fallback LLMNR/NetBIOS.
- Nao inclui consulta reversa PTR.

Limites:
- Diferencas nas respostas nao confirmam erro.
- RESPOSTA nao comprova funcionamento de aplicacoes.
- SEM RESPOSTAS indica ausencia de registros na secao Answer.
- ERRO preserva a mensagem da excecao para investigacao.
- Nao altera DNS, nao limpa cache e nao modifica o arquivo Hosts.
- Requer operador para responder as perguntas no terminal.
- A validacao do nome e basica, nao uma verificacao completa DNS.
- Revise nomes, enderecos e mensagens antes de compartilhar.

Execucao a partir da raiz do repositorio:
.\powershell\conectividade\008_Diagnosticar_resolucao_DNS.ps1

Para visualizar todos os campos:
.\powershell\conectividade\008_Diagnosticar_resolucao_DNS.ps1 |
    Format-List *
#>
#Requires -Version 5.1

[CmdletBinding()]
param()

# 1. Validar o comando antes de solicitar as entradas
try {
    $null = Get-Command Resolve-DnsName -ErrorAction Stop
}
catch {
    $PSCmdlet.ThrowTerminatingError($_)
}

# 2. Solicitar o nome DNS
do {
    $Nome = (Read-Host 'Nome DNS para consultar, nao IP').Trim()
    $Endereco = $null
    $NomeValido = $true

    if ([string]::IsNullOrWhiteSpace($Nome)) {
        Write-Warning 'Informe um nome DNS.'
        $NomeValido = $false
    }
    elseif ([System.Net.IPAddress]::TryParse(
        $Nome, [ref]$Endereco
    )) {
        Write-Warning 'Informe um nome DNS. Consulta reversa nao incluida.'
        $NomeValido = $false
    }
    elseif ($Nome -match '[\s,/:\\]') {
        Write-Warning 'Informe somente o nome, sem URL, porta ou virgulas.'
        $NomeValido = $false
    }
} while (-not $NomeValido)

# 3. Solicitar e validar os servidores DNS
# Virgulas separam servidores; pontos separam partes do IPv4.
do {
    $Entrada = Read-Host 'IPs DNS (ex.: 192.0.2.10,192.0.2.11)'
    $IPsValidos = @()
    $EntradaValida = $true

    foreach ($Item in ($Entrada -split ',')) {
        $Texto = $Item.Trim()
        $Endereco = $null

        # Impedir que numeros isolados sejam convertidos para IPv4.
        $FormatoIPv4 = $Texto -match '^[0-9]{1,3}(\.[0-9]{1,3}){3}$'
        $FormatoIPv6 = $Texto.Contains(':')
        $FormatoValido = $FormatoIPv4 -or $FormatoIPv6

        if (-not $FormatoValido) {
            Write-Warning "Formato invalido: '$Texto'. Use IPv4 completo ou IPv6."
            $EntradaValida = $false
            continue
        }

        # Conferir as faixas e a estrutura do endereco.
        if (-not [System.Net.IPAddress]::TryParse(
            $Texto, [ref]$Endereco
        )) {
            Write-Warning "IP invalido: '$Texto'"
            $EntradaValida = $false
            continue
        }

        # Evitar interpretacao ambigua de IPv4 com zeros a esquerda.
        if ($FormatoIPv4 -and
            $Texto -match '(^|\.)0[0-9]') {
            Write-Warning "Remova zeros a esquerda: '$Texto'"
            $EntradaValida = $false
            continue
        }

        $IPsValidos += $Endereco.ToString()
    }
} while (-not $EntradaValida)

# Normalizar os enderecos e remover servidores repetidos.
[ipaddress[]]$ServidoresDNS = @(
    $IPsValidos | Select-Object -Unique
)

# 4. Solicitar o tipo de registro
do {
    $Tipo = (Read-Host 'Tipo: A, AAAA, CNAME ou SRV [Enter = A]').Trim()

    if ([string]::IsNullOrWhiteSpace($Tipo)) {
        $Tipo = 'A'
    }

    $Tipo = $Tipo.ToUpperInvariant()

    if ($Tipo -notin @('A', 'AAAA', 'CNAME', 'SRV')) {
        Write-Warning 'Escolha A, AAAA, CNAME ou SRV.'
    }
} while ($Tipo -notin @('A', 'AAAA', 'CNAME', 'SRV'))

# 5. Consultar cada servidor de forma independente
foreach ($Servidor in $ServidoresDNS) {
    $IP = $Servidor.ToString()
    $Coleta = Get-Date

    Write-Verbose "Consultando $Nome ($Tipo) em $IP"

    try {
        # Consultar DNS sem arquivo Hosts ou fallback LLMNR/NetBIOS.
        $Registros = @(
            Resolve-DnsName -Name $Nome -Server $IP -Type $Tipo `
                -DnsOnly -NoHostsFile -ErrorAction Stop
        )

        # Separar respostas das secoes de autoridade e adicionais.
        $Respostas = @(
            $Registros | Where-Object { $_.Section -eq 'Answer' }
        )

        # Retornar um objeto mesmo sem registros na secao Answer.
        if ($Respostas.Count -eq 0) {
            [PSCustomObject]@{
                ServidorDNS  = $IP
                Consulta     = $Nome
                TipoConsulta = $Tipo
                Situacao     = 'SEM RESPOSTAS'
                Registro     = $null
                TipoRegistro = $null
                Dados        = $null
                TTL          = $null
                ColetadoEm   = $Coleta
                Detalhe      = 'Sem registros na secao Answer.'
            }

            continue
        }

        # 6. Preservar cada registro e seu tipo real
        foreach ($R in $Respostas) {
            $Dados = switch ([string]$R.Type) {
                'A' {
                    $R.IPAddress
                }
                'AAAA' {
                    $R.IPAddress
                }
                'CNAME' {
                    $R.NameHost
                }
                'SRV' {
                    '{0}:{1}; prioridade={2}; peso={3}' -f
                        $R.NameTarget, $R.Port, $R.Priority, $R.Weight
                }
                default {
                    $R | Out-String
                }
            }

            # Retornar objetos sem aplicar formatacao ao pipeline.
            [PSCustomObject]@{
                ServidorDNS  = $IP
                Consulta     = $Nome
                TipoConsulta = $Tipo
                Situacao     = 'RESPOSTA'
                Registro     = $R.Name
                TipoRegistro = [string]$R.Type
                Dados        = $Dados
                TTL          = $R.TTL
                ColetadoEm   = $Coleta
                Detalhe      = $null
            }
        }
    }
    catch {
        # 7. Registrar a falha e continuar no proximo servidor
        [PSCustomObject]@{
            ServidorDNS  = $IP
            Consulta     = $Nome
            TipoConsulta = $Tipo
            Situacao     = 'ERRO'
            Registro     = $null
            TipoRegistro = $null
            Dados        = $null
            TTL          = $null
            ColetadoEm   = $Coleta
            Detalhe      = $_.Exception.Message
        }
    }
}