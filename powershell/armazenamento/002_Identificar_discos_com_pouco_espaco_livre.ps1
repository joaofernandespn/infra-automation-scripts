<#
.SYNOPSIS
    Identifica unidades locais com pouco espaço livre.

.DESCRIPTION
    Finalidade:
    Consultar a capacidade e o espaço livre das unidades lógicas locais
    classificadas pelo Windows como disco fixo (DriveType=3).

    Pré-requisitos:
    - Windows com Windows PowerShell 5.1 ou PowerShell 7.
    - Acesso à classe CIM Win32_LogicalDisk no computador local.

    Autor/Contexto:
    João Fernandes — Scripts de Infra para LinkedIn.
    Versão: 1.0.0

    Observações:
    - As capacidades são apresentadas em GiB.
    - O alerta aparece somente no console.
    - Não exclui arquivos, altera configurações ou envia notificações.
    - Não avalia a saúde dos discos físicos.
    - A classificação usa o percentual antes do arredondamento.

.PARAMETER LimiteLivre
    Percentual mínimo desejado de espaço livre.
    Unidades abaixo desse valor recebem a classificação ATENCAO.

.EXAMPLE
    .\002_Identificar_discos_com_pouco_espaco_livre.ps1

    Utiliza o limite padrão de 20%.

.EXAMPLE
    .\002_Identificar_discos_com_pouco_espaco_livre.ps1 -LimiteLivre 15

    Utiliza um limite de 15%.
#>

# Bloco 1: define e valida o percentual mínimo desejado
[CmdletBinding()]
param (
    [ValidateRange(0, 100)]
    [double]$LimiteLivre = 20
)

<#
TEXTO DE REFERÊNCIA PARA O LINKEDIN

2. Identificar discos com pouco espaço livre

Descobrir que o disco está quase cheio só quando o chamado chega?
Melhor ter essa informação antes.

Uma checagem simples com PowerShell ajuda a visualizar o espaço
disponível e identificar quais unidades precisam de atenção.

O script consulta as unidades lógicas locais do tipo fixo usando
Win32_LogicalDisk com o filtro DriveType=3.

Com ele, você consegue:

- Consultar a capacidade de cada unidade.
- Visualizar o espaço livre em GiB e em percentual.
- Sinalizar unidades abaixo do limite configurado.
- Apresentar primeiro as unidades com menor percentual livre.

Tudo isso com foco em prevenção, sem excluir arquivos
ou alterar configurações.
#>

try {
    # Bloco 2: consulta unidades com capacidade e espaço livre válidos
    # ErrorAction Stop permite tratar falhas na consulta no bloco catch
    $Discos = @(
        Get-CimInstance -ClassName Win32_LogicalDisk `
            -Filter "DriveType=3" `
            -ErrorAction Stop |
            Where-Object {
                $_.Size -gt 0 -and $null -ne $_.FreeSpace
            }
    )

    if ($Discos.Count -eq 0) {
        Write-Warning "Nenhuma unidade local com dados válidos foi encontrada."
    }
    else {
        # Bloco 3: calcula os valores sem arredondar antes da classificação
        $Relatorio = foreach ($Disco in $Discos) {
            $PercentualLivre = ($Disco.FreeSpace / $Disco.Size) * 100

            [PSCustomObject]@{
                Unidade    = $Disco.DeviceID
                TamanhoGiB = [math]::Round($Disco.Size / 1GB, 2)
                LivreGiB   = [math]::Round($Disco.FreeSpace / 1GB, 2)
                LivrePct   = [math]::Round($PercentualLivre, 2)
                Situacao   = if ($PercentualLivre -lt $LimiteLivre) {
                    "ATENCAO"
                }
                else {
                    "OK"
                }
            }
        }

        # Bloco 4: informa o limite e ordena pelo percentual livre
        Write-Verbose "Limite de espaço livre utilizado: $LimiteLivre%"

        $Relatorio |
            Sort-Object LivrePct, Unidade |
            Format-Table -AutoSize
    }
}
catch {
    Write-Error -Message (
        "Falha ao consultar o espaço livre das unidades: {0}" -f
        $_.Exception.Message
    )
}

<#
COMO INTERPRETAR

Com o limite padrão de 20%, o script marca como ATENCAO as unidades
com menos de 20% de espaço livre.

Uma unidade com exatamente 20% permanece como OK, pois o operador
-lt significa "menor que".

A classificação usa o valor antes do arredondamento. Um percentual
ligeiramente abaixo de 20% pode aparecer como 20,00 na tabela e,
ainda assim, receber ATENCAO.

O alerta aparece no console durante a execução:
este script não envia notificações nem realiza limpeza automática.

Na sua rotina, qual limite você utiliza para investigar
o espaço em disco: 10%, 20% ou outro valor?
#>


<#
Como Testar

Primeiro, use o comportamento padrão:

.\002_Identificar_discos_com_pouco_espaco_livre.ps1

Depois, confira o parâmetro com outro limite:

.\002_Identificar_discos_com_pouco_espaco_livre.ps1 -LimiteLivre 15 -Verbose
#>

#PowerShell #Infraestrutura #WindowsServer #SysAdmin #Automacao
