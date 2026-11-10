<#
.SYNOPSIS
    Consulta informações do sistema, memória e tempo desde o último boot.

.DESCRIPTION
    Finalidade:
    Apresentar informações básicas do computador local para uma
    verificação inicial de infraestrutura, sem alterar o ambiente.

    Pré-requisitos:
    - Windows com Windows PowerShell 5.1 ou PowerShell 7.
    - Acesso às classes CIM consultadas no computador local.

    Autor/Contexto:
    João Fernandes — Scripts de Infra para LinkedIn.
    Versão: 1.0.0

    Observações:
    - A memória é apresentada em GiB, utilizando conversão binária.
    - A memória total corresponde ao valor reportado por
      Win32_ComputerSystem, não a um inventário dos módulos instalados.
    - O uptime é calculado a partir de LastBootUpTime.

.EXAMPLE
    .\001_ConsutarServer_Memo_Uptime.ps1
#>

[CmdletBinding()]
param ()

try {
    # 1. Coleta: consulta o sistema operacional e o computador local
    # ErrorAction Stop permite tratar falhas no bloco catch
    $Sistema = Get-CimInstance -ClassName Win32_OperatingSystem `
        -ErrorAction Stop

    $Computador = Get-CimInstance -ClassName Win32_ComputerSystem `
        -ErrorAction Stop

    # 2. Validação: evita calcular o uptime sem a data de inicialização
    if ($null -eq $Sistema.LastBootUpTime) {
        throw "A consulta não retornou a data da última inicialização."
    }

    # 3. Cálculos: obtém o uptime e converte as unidades de memória
    $Uptime = (Get-Date) - $Sistema.LastBootUpTime

    # TotalPhysicalMemory é informado em bytes
    $MemoriaTotalGiB = [math]::Round(
        $Computador.TotalPhysicalMemory / 1GB, 2
    )

    # FreePhysicalMemory vem em KB: multiplica por 1KB antes de converter
    $MemoriaLivreGiB = [math]::Round(
        ($Sistema.FreePhysicalMemory * 1KB) / 1GB, 2
    )

    # 4. Organização: reúne os resultados em um objeto
    $Relatorio = [PSCustomObject]@{
        Servidor        = $Computador.Name
        Sistema         = $Sistema.Caption
        Versao          = $Sistema.Version
        MemoriaTotalGiB = $MemoriaTotalGiB
        MemoriaLivreGiB = $MemoriaLivreGiB
        UltimoBoot      = $Sistema.LastBootUpTime
        TempoLigado     = "{0} dias, {1} horas e {2} minutos" -f `
            $Uptime.Days, $Uptime.Hours, $Uptime.Minutes
    }

    # 5. Apresentação: exibe as informações em formato de lista
    $Relatorio | Format-List
}
catch {
    Write-Error -Message (
        "Falha ao consultar as informações do computador: {0}" -f
        $_.Exception.Message
    )
}