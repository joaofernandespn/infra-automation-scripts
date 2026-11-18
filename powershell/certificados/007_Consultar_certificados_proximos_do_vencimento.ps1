<#
Finalidade: Consultar certificados vencidos ou proximos do vencimento.
Pre-requisitos: Windows, PowerShell 5.1+ e leitura nos repositorios.
Autor: Joao Fernandes | Scripts de Infra para LinkedIn
Versao: 1.0.0 | Testes iniciais realizados; cobertura parcial.
Escopo: My, WebHosting e Remote Desktop do computador local.
Limites: Nao valida cadeia, revogacao, bindings ou uso pelo servico.
Nao altera certificados. Datas e nomes podem conter dados internos.
#>
#Requires -Version 5.1

# 1. Parametros e configuracao
[CmdletBinding()]
param(
    [ValidateRange(1, 3650)]
    [int]$Dias = 30
)
$Agora = Get-Date
$Limite = $Agora.AddDays($Dias)
$Repositorios = 'My', 'WebHosting', 'Remote Desktop'
$Falhas = 0
$Consultados = 0
$Ausentes = 0

# 2. Validar o provedor antes da coleta
try {
    $null = Get-PSProvider Certificate -ErrorAction Stop
}
catch {
    $PSCmdlet.ThrowTerminatingError($_)
}

# 3. Consultar cada repositorio de forma independente
$Resultado = @(
    foreach ($Nome in $Repositorios) {
        $Caminho = "Cert:\LocalMachine\$Nome"
        try {
            if (-not (Test-Path -LiteralPath $Caminho -ErrorAction Stop)) {
                $Ausentes++
                Write-Warning "Repositorio ausente: $Caminho"
                continue
            }
            # Coleta completa antes de considerar a consulta concluida.
            $Certificados = @(
                Get-ChildItem -LiteralPath $Caminho -ErrorAction Stop
            )
            $Consultados++
            Write-Verbose "$Caminho : $($Certificados.Count) certificados."

            foreach ($Cert in $Certificados) {
                # Inclui todos os vencidos e os que vencem ate o limite.
                if ($Cert.NotAfter -le $Limite) {
                    [PSCustomObject]@{
                        Computador = $env:COMPUTERNAME
                        Repositorio = $Caminho
                        Assunto = $Cert.Subject
                        Emissor = $Cert.Issuer
                        Vencimento = $Cert.NotAfter
                        Situacao = if ($Cert.NotAfter -le $Agora) {
                            'VENCIDO'
                        } else { 'A VENCER' }
                        Thumbprint = $Cert.Thumbprint
                        ColetadoEm = $Agora
                    }
                }
            }
        }
        catch {
            $Falhas++
            Write-Warning "Falha em ${Caminho}: $($_.Exception.Message)"
        }
    }
)

# 4. Informar cobertura e retornar objetos sem formatacao
Write-Host "Cobertura: $Consultados consultados; $Ausentes ausentes; $Falhas falhas."
if ($Falhas -gt 0) {
    Write-Warning 'Relatorio parcial. Falha nao equivale a ausencia de alertas.'
}
if ($Resultado.Count -eq 0) {
    Write-Host 'Sem correspondencias apenas nos repositorios consultados.'
}
$Resultado | Sort-Object Vencimento, Repositorio