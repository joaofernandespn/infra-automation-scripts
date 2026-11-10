<#
.SYNOPSIS
    Exporta os principais campos de um arquivo EVTX para CSV.

.DESCRIPTION
    Finalidade:
    Ler eventos de um arquivo exportado do Event Viewer e gerar
    um CSV, sem alterar o arquivo EVTX original.

    Pré-requisitos:
    - Windows com Windows PowerShell 5.1 ou PowerShell 7.
    - Cmdlet Get-WinEvent disponível.
    - Permissão de leitura no EVTX e de escrita na pasta de saída.
    - Pasta de saída existente.

    Limitações:
    - Exporta somente os campos selecionados no código.
    - Não substitui a preservação do EVTX original.
    - Não sobrescreve arquivos existentes.
    - Uma falha durante a exportação pode deixar um CSV parcial.

    Autor/Contexto:
    João Fernandes — Scripts de Infra para LinkedIn.
    Script 006: conversão de EVTX para CSV.
    Versão: 1.0.0

.PARAMETER Arquivo
    Caminho do arquivo EVTX que será consultado.

.PARAMETER Saida
    Caminho do CSV de destino.
    Quando omitido, usa o nome do EVTX com o sufixo _Eventos.csv
    na mesma pasta do arquivo original.

.PARAMETER Delimitador
    Separador dos campos: vírgula ou ponto e vírgula.
    O padrão é vírgula.

.EXAMPLE
    .\006_Converter_EVTX_to_CSV.ps1 -Arquivo "C:\Logs\Sistema.evtx"

.EXAMPLE
    .\006_Converter_EVTX_to_CSV.ps1 -Arquivo "C:\Logs\Sistema.evtx" -Saida "C:\Logs\Sistema.csv" -Delimitador ";"
#>

# 1. Parâmetros: define a origem e as opções de exportação
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Arquivo,

    [ValidateNotNullOrEmpty()]
    [string]$Saida,

    [ValidateSet(",", ";")]
    [string]$Delimitador = ","
)

try {
    # 2. Validação: confere o cmdlet e o arquivo de origem
    $null = Get-Command -Name Get-WinEvent -ErrorAction Stop

    if (-not (Test-Path -LiteralPath $Arquivo -PathType Leaf)) {
        throw "Arquivo de origem não encontrado: $Arquivo"
    }

    $Origem = Get-Item -LiteralPath $Arquivo -ErrorAction Stop

    if ($Origem.Extension -ine ".evtx") {
        throw "Informe um arquivo com extensão .evtx."
    }

    # 3. Destino: define um nome automático quando a saída for omitida
    if (-not $PSBoundParameters.ContainsKey("Saida")) {
        $Saida = Join-Path -Path $Origem.DirectoryName `
            -ChildPath "$($Origem.BaseName)_Eventos.csv"
    }

    # Obtém um caminho absoluto mesmo antes de o CSV existir
    $SaidaCompleta = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Saida)

    if ([System.IO.Path]::GetExtension($SaidaCompleta) -ine ".csv") {
        throw "O arquivo de saída deve ter extensão .csv."
    }

    $PastaSaida = Split-Path -Path $SaidaCompleta -Parent

    if (-not (Test-Path -LiteralPath $PastaSaida -PathType Container)) {
        throw "A pasta de saída não existe: $PastaSaida"
    }

    # Evita substituir arquivos ou diretórios existentes
    if (Test-Path -LiteralPath $SaidaCompleta) {
        throw "O destino já existe. Escolha outro nome: $SaidaCompleta"
    }

    # 4. Exportação: organiza os parâmetros do CSV
    $ParametrosCSV = @{
        LiteralPath       = $SaidaCompleta
        Delimiter         = $Delimitador
        NoTypeInformation = $true
        Encoding          = "UTF8"
        NoClobber         = $true
        ErrorAction       = "Stop"
    }

    # Lê o EVTX e exporta somente os campos selecionados
    Get-WinEvent -Path $Origem.FullName -ErrorAction Stop |
        Select-Object TimeCreated, Id, LevelDisplayName, ProviderName,
            LogName, RecordId, MachineName, Message |
        Export-Csv @ParametrosCSV

    # 5. Resultado: informa a conclusão somente após a exportação
    Write-Output "Conversão concluída."
    Write-Output "CSV gerado em: $SaidaCompleta"
}
catch {
    Write-Error -Message (
        "Não foi possível concluir a conversão: {0}" -f
        $_.Exception.Message
    )
}