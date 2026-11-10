<#
.SYNOPSIS
    Consulta eventos críticos e erros nos logs System e Application.

.DESCRIPTION
    Finalidade:
    Consultar os eventos críticos e erros do computador local dentro
    de um período configurável, sem modificar os registros.

    Pré-requisitos:
    - Windows com Windows PowerShell 5.1 ou PowerShell 7.
    - Cmdlet Get-WinEvent disponível.
    - Permissão de leitura nos logs System e Application.

    Limitações:
    - O resultado apresenta somente eventos dos níveis 1 e 2.
    - O limite é aplicado ao total combinado dos logs consultados.
    - A quantidade retornada não representa necessariamente todos
      os eventos correspondentes ao período.
    - A ausência de eventos não comprova ausência de problemas.
    - Um evento isolado não confirma a causa de um incidente.

    Autor/Contexto:
    João Fernandes — Scripts de Infra para LinkedIn.
    Script 005: eventos críticos e erros recentes.
    Versão: 1.0.0

.PARAMETER Horas
    Quantidade de horas anteriores ao momento da execução.
    O padrão é 24 horas.

.PARAMETER LimiteEventos
    Quantidade máxima de eventos retornados na consulta.
    O padrão é 50 eventos no total.

.EXAMPLE
    .\005_Consultar_erros_eventos_críticos_24_hs.ps1

    Consulta até 50 eventos críticos ou erros das últimas 24 horas.

.EXAMPLE
    .\005_Consultar_erros_eventos_críticos_24_hs.ps1 `
        -Horas 48 -LimiteEventos 100

    Consulta até 100 eventos críticos ou erros das últimas 48 horas.
#>

# 1. Parâmetros: define o período e o limite da consulta
[CmdletBinding()]
param (
    [ValidateRange(1, 2147483647)]
    [int]$Horas = 24,

    [ValidateRange(1, 2147483647)]
    [int]$LimiteEventos = 50
)

<#
TEXTO DE REFERÊNCIA PARA O LINKEDIN

O servidor apresentou instabilidade e agora você precisa
descobrir por onde começar?

Em vez de navegar manualmente por vários registros no Visualizador
de Eventos, uma consulta direcionada ajuda a organizar a investigação.

Com o Get-WinEvent, podemos filtrar os logs na própria consulta
e limitar a quantidade de eventos retornados.

Neste script:

- O período padrão é de 24 horas.
- Os logs consultados são System e Application.
- O resultado fica limitado a 50 eventos no total, por padrão.
- Os resultados vêm dos mais recentes para os mais antigos.
- A ausência de eventos é diferenciada de uma falha na consulta.
#>

try {
    # 2. Configuração: define os logs e os níveis consultados
    $Logs = @("System", "Application")

    # Níveis do Windows Event Log: 1 = Crítico; 2 = Erro
    $Niveis = @(1, 2)

    # Confirma a disponibilidade do cmdlet antes de consultar
    $null = Get-Command -Name Get-WinEvent -ErrorAction Stop

    # Define uma janela com início e fim fixos para esta execução
    $Fim = Get-Date
    $Inicio = $Fim.AddHours(-$Horas)

    # 3. Construção do filtro: aplicado na consulta dos eventos
    $Filtro = @{
        LogName   = $Logs
        StartTime = $Inicio
        EndTime   = $Fim
        Level     = $Niveis
    }

    # Exibe o escopo mesmo quando não houver eventos correspondentes
    Write-Output (
        "Período: {0:dd/MM/yyyy HH:mm:ss} até {1:dd/MM/yyyy HH:mm:ss}" -f
        $Inicio, $Fim
    )

    Write-Output (
        "Logs: {0} | Níveis: Crítico e Erro | Limite total: {1}" -f
        ($Logs -join ", "), $LimiteEventos
    )

    # 4. Consulta: limita o total combinado dos logs
    # ErrorAction Stop permite tratar a ausência de eventos e outras falhas
    $Eventos = @(
        Get-WinEvent -FilterHashtable $Filtro `
            -MaxEvents $LimiteEventos `
            -ErrorAction Stop
    )

    # 5. Apresentação: informa a quantidade retornada
    Write-Output (
        "Eventos retornados: {0}" -f $Eventos.Count
    )

    if ($Eventos.Count -eq 0) {
        Write-Output (
            "Nenhum evento crítico ou erro encontrado " +
            "nos logs e no período consultados."
        )
    }
    else {
        # Atingir o limite não comprova que existam eventos adicionais
        if ($Eventos.Count -eq $LimiteEventos) {
            Write-Warning (
                "O resultado atingiu o limite configurado. " +
                "Pode haver outros eventos correspondentes no período."
            )
        }

        # Format-List facilita a leitura das mensagens mais extensas
        $Eventos |
            Select-Object TimeCreated, LogName, Id,
                LevelDisplayName, ProviderName, Message |
            Format-List
    }
}
catch {
    # Ausência de correspondências não equivale a falha de acesso
    if ($_.FullyQualifiedErrorId -like "NoMatchingEventsFound*") {
        Write-Output "Eventos retornados: 0"

        Write-Output (
            "Nenhum evento crítico ou erro encontrado " +
            "nos logs e no período consultados."
        )
    }
    else {
        Write-Warning (
            "Falha ao consultar os logs. " +
            "Não considere esta execução uma consulta completa: {0}" -f
            $_.Exception.Message
        )
    }
}

<#
COMO INTERPRETAR A CONSULTA

LogName, StartTime, EndTime e Level delimitam quais registros
entram no resultado.

MaxEvents limita a quantidade total retornada:
com o padrão de 50, se houver mais correspondências,
somente as 50 mais recentes serão apresentadas.

Quando o resultado atingir exatamente o limite, o script avisa
que pode haver outros eventos. Ele não realiza uma contagem
adicional para confirmar essa possibilidade.

A ausência de correspondências significa apenas que não foram
encontrados eventos dos níveis selecionados nos logs e no período
consultados. Isso não comprova que o computador esteja sem problemas.

Use a saída como triagem: relacione horário, origem e mensagem
dos eventos com o momento do incidente, em vez de considerar
qualquer erro isolado como causa confirmada.

Quando surge uma instabilidade, você começa pelos eventos
do System ou do Application?

#PowerShell #WindowsServer #Monitoramento #Troubleshooting #Infraestrutura
#>