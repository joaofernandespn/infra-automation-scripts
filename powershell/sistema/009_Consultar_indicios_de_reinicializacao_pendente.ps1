<#
.SYNOPSIS
    Consulta indícios de reinicialização pendente no Windows local.

.DESCRIPTION
    Finalidade:
    Consultar três indicadores de reinicialização pendente no Registro
    do computador local, sem alterar configurações ou reiniciar o sistema.

    Verificações:
    - Existência da chave RebootPending do Component Based Servicing.
    - Existência da chave RebootRequired do Windows Update.
    - Conteúdo não vazio no valor PendingFileRenameOperations
      do Session Manager.

    Pré-requisitos:
    - Windows com Windows PowerShell 5.1 ou PowerShell 7.
    - Permissão de leitura nas chaves do Registro consultadas.
    - Execução local em um computador autorizado.

    Limitações:
    - Os resultados se restringem aos três indicadores consultados.
    - A ausência de indicadores não garante que nenhuma aplicação
      ou outro componente esteja aguardando reinicialização.
    - Um indicador encontrado não determina, isoladamente,
      a causa, a urgência ou a janela adequada para reiniciar.
    - PendingFileRenameOperations pode conter operações solicitadas
      por instaladores, drivers ou outros componentes.
    - O script não identifica o programa responsável pelas operações.
    - O estado pode mudar durante ou após a coleta.
    - Falhas de leitura tornam a cobertura da consulta parcial.
    - Não consulta computadores remotos, Configuration Manager,
      alterações de nome do computador ou ingresso em domínio.
    - Não instala atualizações, remove indicadores, altera o Registro
      ou reinicia o computador.

    Autor/Contexto:
    João Fernandes — Scripts de Infra para LinkedIn.
    Script 009: indícios de reinicialização pendente no Windows.
    Versão: 1.0.0
    Validação: pendente de testes no ambiente do projeto.

.EXAMPLE
    .\009_Consultar_indicios_de_reinicializacao_pendente.ps1

    Apresenta os objetos com o resultado de cada verificação
    e um resumo informativo no terminal.

.EXAMPLE
    .\009_Consultar_indicios_de_reinicializacao_pendente.ps1 |
        Format-Table Verificacao, Situacao, Detalhe -AutoSize -Wrap

    Apresenta uma tabela resumida das verificações.

.EXAMPLE
    .\009_Consultar_indicios_de_reinicializacao_pendente.ps1 |
        Format-List *

    Apresenta todos os campos de cada resultado.

.EXAMPLE
    $Resultados = @(
        .\009_Consultar_indicios_de_reinicializacao_pendente.ps1
    )

    $Resultados | Where-Object Situacao -eq 'INDICIO ENCONTRADO'

    Armazena os objetos e seleciona os indicadores encontrados.
#>

<#
TEXTO DE REFERÊNCIA PARA O LINKEDIN

"A manutenção terminou. Mas ficou alguma reinicialização pendente?"

Antes de encerrar a atividade, vale consultar os indicadores
e entender o que o computador está reportando.

O script verifica três pontos do Registro local:

- Component Based Servicing: RebootPending.
- Windows Update: RebootRequired.
- Session Manager: PendingFileRenameOperations.

Cada verificação apresenta uma situação independente:

- INDICIO ENCONTRADO.
- NAO ENCONTRADO.
- ERRO.

A ausência desses indicadores não garante que todos os componentes
estejam livres de pendências de reinicialização.

O script apenas consulta: não altera o Registro, não instala
atualizações e não reinicia o computador.
#>

#Requires -Version 5.1

[CmdletBinding()]
param()

# 1. Validação do ambiente
# A consulta usa o Registro do Windows e não se aplica a outros sistemas.
if (
    [System.Environment]::OSVersion.Platform -ne
    [System.PlatformID]::Win32NT
) {
    throw "Este script deve ser executado no Windows."
}

# 2. Identificação do computador e configuração das verificações
$Computador = [System.Environment]::MachineName

# Usa a visão de 64 bits em Windows de 64 bits, mesmo quando
# o processo PowerShell for de 32 bits.
$VisaoRegistro = if ([System.Environment]::Is64BitOperatingSystem) {
    [Microsoft.Win32.RegistryView]::Registry64
}
else {
    [Microsoft.Win32.RegistryView]::Registry32
}

# Os caminhos abaixo são os indicadores consultados pela rotina,
# não destinos de escrita ou configurações a serem alteradas.
$Verificacoes = @(
    [PSCustomObject]@{
        Nome = 'Component Based Servicing'
        Tipo = 'CHAVE'
        Caminho = (
            'SOFTWARE\Microsoft\Windows\CurrentVersion\' +
            'Component Based Servicing\RebootPending'
        )
        Valor = $null
    }

    [PSCustomObject]@{
        Nome = 'Windows Update'
        Tipo = 'CHAVE'
        Caminho = (
            'SOFTWARE\Microsoft\Windows\CurrentVersion\' +
            'WindowsUpdate\Auto Update\RebootRequired'
        )
        Valor = $null
    }

    [PSCustomObject]@{
        Nome = 'Operacoes pendentes em arquivos'
        Tipo = 'VALOR'
        Caminho = 'SYSTEM\CurrentControlSet\Control\Session Manager'
        Valor = 'PendingFileRenameOperations'
    }
)

# 3. Consulta independente de cada indicador
# @() mantém a saída como coleção mesmo se houver somente um resultado.
$Resultados = @(
    foreach ($Verificacao in $Verificacoes) {
        $Base = $null
        $Chave = $null
        $Encontrado = $false
        $Situacao = 'NAO ENCONTRADO'
        $Detalhe = ''
        $ColetadoEm = Get-Date

        $LocalConsultado = 'HKEY_LOCAL_MACHINE\{0}' -f (
            $Verificacao.Caminho
        )

        if ($Verificacao.Tipo -eq 'VALOR') {
            $LocalConsultado = '{0} -> {1}' -f (
                $LocalConsultado,
                $Verificacao.Valor
            )
        }

        try {
            Write-Verbose (
                "Consultando {0}: {1}" -f
                $Verificacao.Nome,
                $LocalConsultado
            )

            # Abre o Registro local na visão definida anteriormente.
            $Base = [Microsoft.Win32.RegistryKey]::OpenBaseKey(
                [Microsoft.Win32.RegistryHive]::LocalMachine,
                $VisaoRegistro
            )

            # O segundo argumento $false abre a chave somente para leitura.
            # Uma chave inexistente retorna $null; falhas de acesso
            # são tratadas pelo catch desta verificação.
            $Chave = $Base.OpenSubKey(
                $Verificacao.Caminho,
                $false
            )

            if ($null -eq $Chave) {
                $Detalhe = 'Chave consultada inexistente.'
            }
            elseif ($Verificacao.Tipo -eq 'CHAVE') {
                # Para estes indicadores, verifica somente a existência.
                $Encontrado = $true
                $Detalhe = 'Chave indicadora presente.'
            }
            elseif (
                $Chave.GetValueNames() -notcontains
                $Verificacao.Valor
            ) {
                $Detalhe = 'Valor consultado inexistente.'
            }
            else {
                # O formato esperado é REG_MULTI_SZ, uma lista de textos.
                $TipoValor = $Chave.GetValueKind($Verificacao.Valor)

                if (
                    $TipoValor -ne
                    [Microsoft.Win32.RegistryValueKind]::MultiString
                ) {
                    throw (
                        (
                            "Tipo inesperado para {0}: {1}. " +
                            "Esperado: MultiString (REG_MULTI_SZ)."
                        ) -f $Verificacao.Valor, $TipoValor
                    )
                }

                # Lê sem expandir eventuais referências a variáveis.
                $Dados = $Chave.GetValue(
                    $Verificacao.Valor,
                    $null,
                    [Microsoft.Win32.RegistryValueOptions]::
                        DoNotExpandEnvironmentNames
                )

                if ($null -eq $Dados) {
                    throw (
                        "O valor foi identificado, mas a leitura " +
                        "não retornou dados. O estado pode ter mudado."
                    )
                }

                # A lista pode incluir textos vazios; eles não são
                # suficientes para classificar um indicador como presente.
                $EntradasComConteudo = @(
                    $Dados | Where-Object {
                        -not [string]::IsNullOrWhiteSpace([string]$_)
                    }
                )

                $Encontrado = $EntradasComConteudo.Count -gt 0

                if ($Encontrado) {
                    # Conta entradas textuais, não operações:
                    # origem e destino podem ocupar entradas separadas.
                    $Detalhe = (
                         (
                            "Valor com conteúdo: {0} entrada(s) textual(is) " +
                            "não vazia(s). A contagem não representa " +
                            "o número de operações."
                         ) -f $EntradasComConteudo.Count
                                )
                }
                else {
                    $Detalhe = (
                        'Valor presente, mas sem entradas textuais ' +
                        'não vazias.'
                    )
                }
            }

            if ($Encontrado) {
                $Situacao = 'INDICIO ENCONTRADO'
            }
        }
        catch {
            # Uma falha não impede a consulta dos demais indicadores.
            $Situacao = 'ERRO'
            $Detalhe = $_.Exception.Message
        }
        finally {
            # Libera os identificadores abertos durante esta verificação.
            if ($null -ne $Chave) {
                $Chave.Dispose()
            }

            if ($null -ne $Base) {
                $Base.Dispose()
            }
        }

        # O mesmo conjunto de campos é usado em todas as situações.
        # Os dados internos de PendingFileRenameOperations não são expostos.
        [PSCustomObject]@{
            Computador     = $Computador
            Verificacao    = $Verificacao.Nome
            Situacao       = $Situacao
            LocalConsultado = $LocalConsultado
            VisaoRegistro  = [string]$VisaoRegistro
            ColetadoEm     = $ColetadoEm
            Detalhe        = $Detalhe
        }
    }
)

# 4. Resumo da cobertura
$Indicios = @(
    $Resultados |
        Where-Object Situacao -eq 'INDICIO ENCONTRADO'
).Count

$Falhas = @(
    $Resultados |
        Where-Object Situacao -eq 'ERRO'
).Count

$ConsultasConcluidas = $Resultados.Count - $Falhas

# Write-Host mantém as mensagens fora do fluxo de objetos de sucesso.
Write-Host (
    "Verificacoes: {0}; concluidas: {1}; indicios: {2}; falhas: {3}" -f
    $Resultados.Count,
    $ConsultasConcluidas,
    $Indicios,
    $Falhas
)

if ($Falhas -gt 0) {
    Write-Warning (
        'Relatorio parcial: uma ou mais verificacoes falharam. ' +
        'Consulte os resultados com situacao ERRO.'
    )
}

# A presença de indícios e a cobertura da consulta são avaliadas
# separadamente: pode haver indícios mesmo em um relatório parcial.
if ($Indicios -gt 0) {
    Write-Host (
        'Foram encontrados indicios. Analise as evidencias e a janela ' +
        'de manutencao antes de decidir sobre uma reinicializacao.'
    )
}
elseif ($Falhas -eq 0) {
    Write-Host (
        'Nenhum indicio encontrado nas verificacoes realizadas. ' +
        'Isso nao garante ausencia de outras pendencias.'
    )
}
else {
    Write-Host (
        'Nenhum indicio nas verificacoes concluidas, mas a cobertura ' +
        'e parcial devido a falhas de consulta.'
    )
}

# 5. Entrega dos resultados
# Retorna objetos, sem Format-Table, para permitir filtros,
# visualizações e exportações escolhidas pelo operador.
$Resultados