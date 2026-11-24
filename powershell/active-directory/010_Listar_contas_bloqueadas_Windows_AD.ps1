<#
.SYNOPSIS
    Lista contas reportadas como bloqueadas no Windows local ou no AD.

.DESCRIPTION
    Finalidade:
    Listar contas bloqueadas sem exigir que o operador conheça
    previamente o nome do usuário.

    Escopos:
    - Local: contas locais do computador onde o script é executado.
    - AD: contas de usuário do domínio consultado.
    - Ambos: executa as duas consultas separadamente.

    Fontes:
    - Local: classe CIM Win32_UserAccount.
    - AD: Search-ADAccount -LockedOut -UsersOnly.

    Pré-requisitos:
    - Windows com PowerShell 5.1 ou posterior.
    - Permissão para consultar os recursos selecionados.
    - Para consulta local: Get-CimInstance disponível.
    - Para AD: módulo ActiveDirectory disponível e funcional,
      acesso ao controlador informado e permissão de consulta.
    - Uso somente em ambientes autorizados.

    Limitações:
    - A consulta local abrange somente este computador.
    - A consulta AD usa um controlador informado pelo operador.
    - Não consulta automaticamente todos os domínios ou a floresta.
    - O estado das contas pode mudar durante ou após a coleta.
    - A visão retornada pelo AD depende do controlador consultado.
    - Não lista bloqueios do Microsoft Entra ID ou de aplicações.
    - Conta bloqueada e conta desabilitada são condições diferentes.
    - Nome completo local pode não estar preenchido.
    - No AD, Nome corresponde à propriedade Name, não necessariamente
      ao nome completo ou ao DisplayName da pessoa.
    - Não identifica a origem ou a causa dos bloqueios.
    - Não consulta histórico de eventos.
    - Em controlador de domínio, o escopo local não é executado
      para evitar confusão entre contas locais e de domínio.
    - Falhas de consulta não são tratadas como ausência de bloqueios.
    - Não desbloqueia, habilita ou altera contas.

    Autor/Contexto:
    João Fernandes — Scripts de Infra para LinkedIn.
    Script 010: contas bloqueadas no Windows local e no AD.
    Versão: 1.0.0
    Validação:
    - Consulta AD sem contas bloqueadas retornadas, sem erro reportado.
    - Consulta local sem contas bloqueadas retornadas, sem erro reportado.
    - Escopo Ambos em controlador de domínio: consulta local recusada
      pela proteção do script e consulta AD mantida.
    - Resumo, cobertura e aviso de consulta parcial conferidos.
    - Listagem com contas bloqueadas e retorno com PassThru
      ainda não testados.

.EXAMPLE
    .\010_Listar_contas_bloqueadas_Windows_AD.ps1

    Solicita o escopo e, quando necessário, o controlador do AD.

.EXAMPLE
    .\010_Listar_contas_bloqueadas_Windows_AD.ps1 -Escopo Local

    Consulta somente as contas locais deste computador.

.EXAMPLE
    .\010_Listar_contas_bloqueadas_Windows_AD.ps1 `
        -Escopo AD `
        -ServidorAD "dc01.seudominio.local"

    Consulta contas bloqueadas no AD pelo controlador informado.

.EXAMPLE
    $Relatorio = .\010_Listar_contas_bloqueadas_Windows_AD.ps1 `
        -Escopo Ambos `
        -ServidorAD "dc01.seudominio.local" `
        -PassThru

    $Relatorio.Contas | Format-List *
    $Relatorio.Cobertura | Format-List *

    Retorna contas e cobertura em um objeto para análise.
    Substitua o controlador de exemplo pelo destino autorizado.
#>

<#
TEXTO DE REFERÊNCIA PARA O LINKEDIN

"Quais usuários estão com a conta bloqueada?"

Você não precisa conhecer previamente o login para começar
a triagem.

O script permite escolher entre:
- Contas locais do Windows.
- Contas do Active Directory.
- Ambas.

Apresenta nome, conta, origem e momento da coleta, além da
cobertura das consultas.

Não desbloqueia nem altera contas.
A lista apoia a triagem, mas não identifica a causa do bloqueio.
#>

#Requires -Version 5.1

[CmdletBinding()]
param(
    [ValidateSet('Local', 'AD', 'Ambos')]
    [string]$Escopo,

    [string]$ServidorAD,

    [switch]$PassThru
)

# 1. Validação do ambiente
if (
    [System.Environment]::OSVersion.Platform -ne
    [System.PlatformID]::Win32NT
) {
    throw 'Este script deve ser executado no Windows.'
}

$Computador = [System.Environment]::MachineName

# 2. Seleção interativa do escopo
if ([string]::IsNullOrWhiteSpace($Escopo)) {
    Write-Host '1 - Contas locais deste computador'
    Write-Host '2 - Contas do Active Directory'
    Write-Host '3 - Ambas'

    $Opcao = Read-Host 'Escolha o escopo'

    $Escopo = switch ($Opcao.Trim()) {
        '1' { 'Local' }
        '2' { 'AD' }
        '3' { 'Ambos' }
        default {
            throw 'Opção inválida. Execute novamente e escolha 1, 2 ou 3.'
        }
    }
}

# 3. Definição do destino AD
if ($Escopo -in @('AD', 'Ambos')) {
    if ([string]::IsNullOrWhiteSpace($ServidorAD)) {
        $ServidorAD = Read-Host (
            'Digite o nome ou FQDN do controlador autorizado'
        )
    }

    if ([string]::IsNullOrWhiteSpace($ServidorAD)) {
        throw 'Nenhum controlador foi informado.'
    }

    $ServidorAD = $ServidorAD.Trim()

    if ($ServidorAD -match '[\s,\\/]') {
        throw (
            'Informe somente um controlador, ' +
            'sem espaços, vírgulas ou barras.'
        )
    }
}

$Fontes = switch ($Escopo) {
    'Local' { 'Local' }
    'AD'    { 'AD' }
    'Ambos' { 'Local'; 'AD' }
}

$Contas = [System.Collections.Generic.List[object]]::new()
$Cobertura = [System.Collections.Generic.List[object]]::new()

# 4. Consulta independente de cada origem
foreach ($Fonte in $Fontes) {
    $ColetadoEm = Get-Date
    $Situacao = 'CONCLUIDA'
    $Quantidade = 0
    $Detalhe = ''
    $Destino = if ($Fonte -eq 'Local') {
        $Computador
    }
    else {
        $ServidorAD
    }

    try {
        # Monta primeiro os resultados da origem.
        # Em caso de falha, não publica uma lista parcial como completa.
        $ContasDaFonte = @(
            if ($Fonte -eq 'Local') {
                # 4.1. Contas locais do Windows
                $null = Get-Command Get-CimInstance -ErrorAction Stop

                $Sistema = Get-CimInstance `
                    -ClassName Win32_ComputerSystem `
                    -ErrorAction Stop

                if ($null -eq $Sistema) {
                    throw 'Não foi possível identificar o tipo do computador.'
                }

                # Evita consultar o escopo local em um DC como se
                # ele tivesse a mesma semântica de uma estação.
                if ($Sistema.DomainRole -in @(4, 5)) {
                    throw (
                        'Este computador é um controlador de domínio. ' +
                        'Utilize o escopo AD para consultar as contas.'
                    )
                }

                # Restringe a consulta a contas locais bloqueadas.
                $UsuariosLocais = @(
                    Get-CimInstance `
                        -ClassName Win32_UserAccount `
                        -Filter 'LocalAccount=True AND Lockout=True' `
                        -ErrorAction Stop
                )

                foreach ($Conta in $UsuariosLocais) {
                    [PSCustomObject]@{
                        Origem = 'LOCAL'
                        DestinoConsultado = $Computador

                        # Não inventa nome completo quando ele está vazio.
                        Nome = if (
                            [string]::IsNullOrWhiteSpace($Conta.FullName)
                        ) {
                            $Conta.Name
                        }
                        else {
                            $Conta.FullName
                        }

                        Conta = $Conta.Name
                        Dominio = $Conta.Domain
                        Bloqueada = [bool]$Conta.Lockout
                        Habilitada = -not [bool]$Conta.Disabled
                        SID = [string]$Conta.SID
                        ColetadoEm = $ColetadoEm
                    }
                }
            }
            else {
                # 4.2. Contas de usuário bloqueadas no AD
                # Importa apenas para esta sessão; não instala módulos.
                Import-Module ActiveDirectory -ErrorAction Stop

                $null = Get-Command Search-ADAccount -ErrorAction Stop

                $UsuariosAD = @(
                    Search-ADAccount `
                        -LockedOut `
                        -UsersOnly `
                        -Server $ServidorAD `
                        -ErrorAction Stop
                )

                foreach ($Conta in $UsuariosAD) {
                    [PSCustomObject]@{
                        Origem = 'AD'
                        DestinoConsultado = $ServidorAD
                        Nome = $Conta.Name
                        Conta = $Conta.SamAccountName

                        # Não confunde o servidor consultado com o
                        # nome DNS do domínio da conta.
                        Dominio = $null

                        Bloqueada = [bool]$Conta.LockedOut
                        Habilitada = $Conta.Enabled
                        SID = [string]$Conta.SID
                        ColetadoEm = $ColetadoEm
                    }
                }
            }
        )

        foreach ($Conta in $ContasDaFonte) {
            $Contas.Add($Conta)
        }

        $Quantidade = $ContasDaFonte.Count

        if ($Quantidade -gt 0) {
            $Detalhe = 'Contas bloqueadas retornadas pela origem consultada.'
        }
        else {
            $Situacao = 'SEM CONTAS BLOQUEADAS'
            $Detalhe = (
                'Nenhuma conta bloqueada retornada ' +
                'pela consulta nesta origem.'
            )
        }
    }
    catch {
        # Uma origem com erro não impede a consulta da outra.
        $Situacao = 'ERRO'
        $Detalhe = $_.Exception.Message
    }

    # 5. Registro da cobertura
    $Cobertura.Add(
        [PSCustomObject]@{
            Origem = $Fonte
            DestinoConsultado = $Destino
            Situacao = $Situacao
            QuantidadeRetornada = $Quantidade
            ColetadoEm = $ColetadoEm
            Detalhe = $Detalhe
        }
    )
}

# 6. Organização dos resultados
$Relatorio = [PSCustomObject]@{
    Escopo = $Escopo
    Contas = @(
        $Contas | Sort-Object Origem, Conta
    )
    Cobertura = @($Cobertura.ToArray())
}

$Falhas = @(
    $Relatorio.Cobertura |
        Where-Object Situacao -eq 'ERRO'
).Count

Write-Host (
    'Origens: {0}; contas bloqueadas retornadas: {1}; falhas: {2}' -f
    $Relatorio.Cobertura.Count,
    $Relatorio.Contas.Count,
    $Falhas
)

if ($Falhas -gt 0) {
    Write-Warning (
        'Cobertura parcial ou indisponível. ' +
        'Confira os erros antes de interpretar os resultados.'
    )
}

# 7. Entrega dos objetos ou apresentação no terminal
if ($PassThru) {
    $Relatorio
}
else {
    Write-Host "`nCONTAS BLOQUEADAS"

    if ($Relatorio.Contas.Count -gt 0) {
        $Relatorio.Contas |
            Format-Table Origem, Nome, Conta, DestinoConsultado,
                Habilitada -AutoSize -Wrap
    }
    else {
        Write-Host (
            'Nenhuma conta retornada. Confira a cobertura para ' +
            'diferenciar ausência de bloqueios de falha na consulta.'
        )
    }

    Write-Host "`nCOBERTURA DAS CONSULTAS"

    $Relatorio.Cobertura |
        Format-Table Origem, DestinoConsultado, Situacao,
            QuantidadeRetornada, Detalhe -AutoSize -Wrap
}