<#
.SYNOPSIS
    Consulta separadamente a saúde reportada dos dispositivos e volumes.

.DESCRIPTION
    Finalidade:
    Apresentar a saúde e os estados operacionais dos dispositivos
    de armazenamento e dos volumes locais com letra de unidade.

    O script apenas consulta informações.
    Não executa CHKDSK, reparos ou alterações no armazenamento.
    Não realiza associação automática entre dispositivos e volumes.

    Pré-requisitos:
    - Windows com o módulo Storage.
    - Cmdlets Get-PhysicalDisk e Get-Volume disponíveis.
    - Permissão para consultar o armazenamento local.

    Limitações:
    - A visibilidade depende do hardware, dos drivers e do provedor.
    - Volumes sem letra de unidade não entram no relatório.
    - Os alertas resumidos consideram a coluna Saude.
    - A coluna Operacao deve ser analisada separadamente.

    Autor/Contexto:
    João Fernandes — Scripts de Infra para LinkedIn.
    Script 002-5: saúde reportada dos dispositivos e volumes.
    Versão: 1.0.0

.EXAMPLE
    .\002-5_Consultar_a_saude_reportada_dos_discos.ps1
#>

<#
Disco com espaço livre significa disco saudável? Não são a mesma coisa.

E existe outro detalhe importante: um dispositivo reportar Healthy não significa que todos os seus volumes também estejam sem avisos.

Por isso, neste script 2.5, vamos consultar duas camadas separadamente:

- A saúde reportada dos dispositivos de armazenamento.
- A saúde e o estado operacional dos volumes com letra de unidade.

O objetivo é identificar sinais que merecem investigação, sem executar reparos nem alterar o ambiente.

Script PowerShell
#>


# Bloco 1: consulta da saúde dos dispositivos
try {
    # Valida a disponibilidade do cmdlet antes da consulta.
    $null = Get-Command -Name Get-PhysicalDisk -ErrorAction Stop

    $Dispositivos = @(
        Get-PhysicalDisk -ErrorAction Stop
    )

    # Bloco 2: organização do relatório dos dispositivos
    $RelatorioDispositivos = @(
        foreach ($Dispositivo in $Dispositivos) {
            $Saude = [string]$Dispositivo.HealthStatus

            # Informação ausente não deve ser considerada saudável.
            if ([string]::IsNullOrWhiteSpace($Saude)) {
                $Saude = "Nao informado"
            }

            # Reúne todos os estados operacionais retornados.
            $Operacao = $Dispositivo.OperationalStatus -join ", "

            if ([string]::IsNullOrWhiteSpace($Operacao)) {
                $Operacao = "Nao informado"
            }

            [PSCustomObject]@{
                Id         = $Dispositivo.DeviceId
                Modelo     = $Dispositivo.FriendlyName
                Tipo       = [string]$Dispositivo.MediaType
                TamanhoGiB = [math]::Round(
                    $Dispositivo.Size / 1GB, 2
                )
                Saude      = $Saude
                Operacao   = $Operacao
            }
        }
    )

    # Bloco 3: apresentação e alerta dos dispositivos
    Write-Output "`n=== SAUDE REPORTADA DOS DISPOSITIVOS ==="

    if ($RelatorioDispositivos.Count -eq 0) {
        Write-Warning "Nenhum dispositivo retornado pelo provedor."
    }
    else {
        $RelatorioDispositivos |
            Sort-Object Id |
            Format-Table -AutoSize -Wrap

        $DispositivosParaRevisar = @(
            $RelatorioDispositivos |
                Where-Object { $_.Saude -ne "Healthy" }
        )

        if ($DispositivosParaRevisar.Count -gt 0) {
            Write-Warning (
                "{0} dispositivo(s) com saúde diferente de Healthy." -f
                $DispositivosParaRevisar.Count
            )
        }
        else {
            Write-Output (
                "Os dispositivos retornados reportaram Healthy. " +
                "Isso não determina a saúde dos volumes."
            )
        }
    }
}
catch {
    # A falha nesta consulta não impede a consulta dos volumes.
    Write-Warning (
        "Falha ao consultar os dispositivos: {0}" -f
        $_.Exception.Message
    )
}

# Bloco 4: consulta da saúde dos volumes
try {
    $null = Get-Command -Name Get-Volume -ErrorAction Stop

    # Escopo: somente volumes com letra de unidade.
    # Volumes sem letra não entram neste relatório.
    $Volumes = @(
        Get-Volume -ErrorAction Stop |
            Where-Object { $_.DriveLetter }
    )

    # Bloco 5: organização do relatório dos volumes
    $RelatorioVolumes = @(
        foreach ($Volume in $Volumes) {
            $Saude = [string]$Volume.HealthStatus

            if ([string]::IsNullOrWhiteSpace($Saude)) {
                $Saude = "Nao informado"
            }

            $Operacao = $Volume.OperationalStatus -join ", "

            if ([string]::IsNullOrWhiteSpace($Operacao)) {
                $Operacao = "Nao informado"
            }

            [PSCustomObject]@{
                Unidade = "{0}:" -f $Volume.DriveLetter
                Rotulo  = $Volume.FileSystemLabel
                Sistema = $Volume.FileSystem
                Saude   = $Saude
                Operacao = $Operacao
            }
        }
    )

    # Bloco 6: apresentação e alerta dos volumes
    Write-Output "`n=== SAUDE REPORTADA DOS VOLUMES ==="

    if ($RelatorioVolumes.Count -eq 0) {
        Write-Warning "Nenhum volume com letra de unidade foi retornado."
    }
    else {
        $RelatorioVolumes |
            Sort-Object Unidade |
            Format-Table -AutoSize -Wrap

        $VolumesParaRevisar = @(
            $RelatorioVolumes |
                Where-Object { $_.Saude -ne "Healthy" }
        )

        if ($VolumesParaRevisar.Count -gt 0) {
            Write-Warning (
                "{0} volume(s) com saúde diferente de Healthy." -f
                $VolumesParaRevisar.Count
            )

            Write-Output (
                "Unidades para investigar: {0}" -f
                ($VolumesParaRevisar.Unidade -join ", ")
            )
        }
        else {
            Write-Output (
                "Os volumes retornados reportaram Healthy."
            )
        }
    }
}
catch {
    Write-Warning (
        "Falha ao consultar os volumes: {0}" -f
        $_.Exception.Message
    )
}

# Bloco 7: esclarecimento sobre o alcance da consulta
Write-Output (
    "`nDispositivos e volumes são avaliados separadamente. " +
    "Considere também os estados operacionais apresentados."
)

Write-Output (
    "Esta consulta não substitui diagnóstico do hardware, " +
    "verificação do sistema de arquivos ou backup."
)

<#
Como interpretar o resultado
A coluna Saude pode apresentar:

- Healthy: saúde reportada como normal.
- Warning: aviso de saúde que precisa ser investigado.
- Unhealthy: estado de saúde comprometido.
- Unknown: saúde desconhecida.
- Nao informado: indicação adicionada pelo script quando a propriedade não retorna informação.

A coluna Operacao complementa a análise. Um disco pode apresentar mais de um estado operacional; por isso, o script reúne esses valores na mesma coluna, sem ocultá-los.

Um cuidado importante
Healthy não é um certificado de que o disco nunca apresentará falhas. É uma indicação geral da saúde reportada naquele momento, e não um diagnóstico completo de desgaste, superfície ou integridade dos dados.

Em ambientes com RAID, storage ou máquinas virtuais, a visibilidade pode ser limitada à camada exposta ao Windows. Não presuma que o relatório mostra todos os discos físicos por trás dessa camada.

O objetivo é simples: acrescentar uma verificação ao diagnóstico, sem confundir espaço disponível com saúde do armazenamento.

Na sua rotina, você monitora apenas o espaço disponível ou também acompanha a saúde dos discos?
E se você já encontrou um dispositivo com Healthy, mas um volume com Warning compartilhe nos comentários:
Como investigou esse cenário?

#>

#PowerShell #Infraestrutura #WindowsServer #SysAdmin #Monitoramento #Automacao