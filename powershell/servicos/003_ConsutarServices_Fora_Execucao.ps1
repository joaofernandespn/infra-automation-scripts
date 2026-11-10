<#
.SYNOPSIS
    Lista serviços automáticos que não estão em execução.

.DESCRIPTION
    Finalidade:
    Consultar os serviços do computador local com StartMode igual a Auto
    e apresentar aqueles cujo estado atual seja diferente de Running.

    O script apenas consulta informações.
    Não inicia, para, reinicia ou modifica serviços.

    Pré-requisitos:
    - Windows com Windows PowerShell 5.1 ou PowerShell 7.
    - Cmdlet Get-CimInstance disponível.
    - Permissão para consultar a classe Win32_Service local.
    - Windows 10 ou Windows Server 2016 e posteriores para suporte
      à propriedade DelayedAutoStart.

    Limitações:
    - A consulta representa o estado no momento da coleta.
    - Um serviço listado não representa, isoladamente, falha confirmada.
    - O script não analisa dependências, gatilhos ou eventos dos serviços.

    Autor/Contexto:
    João Fernandes — Scripts de Infra para LinkedIn.
    Script 003: serviços automáticos fora de execução.
    Versão: 1.0.0

.EXAMPLE
    .\003_ConsutarServices_Fora_Execucao.ps1
#>

<# 
3. Serviços automáticos fora de execução
Servidor reiniciado, sistema aparentemente disponível... mas aquela aplicação continua sem funcionar?

Antes de sair reiniciando serviços, vale conferir quais estão configurados para inicialização automática e não estão em execução.

Uma consulta à classe Win32_Service permite comparar o modo de inicialização com o estado atual de cada serviço.

Com o script abaixo, você consegue:

- Identificar serviços automáticos fora de execução.
- Visualizar nome técnico, nome de exibição e estado atual.
- Verificar a indicação de inicialização automática atrasada.
- Fazer o levantamento sem alterar o ambiente.
#>


# 1. Configuração
# Filtra na origem somente serviços com inicialização automática.
$Filtro = "StartMode='Auto'"

# 2. Consulta e tratamento de erros
try {
    # @() mantém o resultado como coleção, mesmo com zero ou um item.
    $Servicos = @(
        Get-CimInstance -ClassName Win32_Service `
            -Filter $Filtro `
            -ErrorAction Stop
    )

    # 3. Seleção dos serviços fora de execução
    # Inclui qualquer estado diferente de Running, não apenas Stopped.
    $ForaDeExecucao = @(
        $Servicos |
            Where-Object { $_.State -ne "Running" }
    )

    # 4. Apresentação dos resultados
    if ($Servicos.Count -eq 0) {
        Write-Output "Nenhum serviço automático retornado pela consulta."
    }
    elseif ($ForaDeExecucao.Count -eq 0) {
        Write-Output (
                        "Todos os serviços automáticos retornados estavam em execução " +
                        "no momento da consulta."
                     )
    }
    else {
        Write-Output (
            "Serviços automáticos fora de execução: {0}" -f
            $ForaDeExecucao.Count
        )

        # Mostra também se o serviço possui início automático atrasado.
        $ForaDeExecucao |
            Sort-Object DisplayName |
            Select-Object Name, DisplayName, State, StartMode,
                DelayedAutoStart |
            Format-Table -AutoSize -Wrap
        # A lista orienta a investigação; não confirma uma falha
        Write-Output (
            "Revise os serviços listados antes de qualquer intervenção. " +
            "Estado diferente de Running não confirma, isoladamente, uma falha."
                     )
    }
}
catch {
    # Uma falha na consulta não significa ausência de serviços parados.
    Write-Warning (
        "Falha ao consultar os serviços: {0}" -f
        $_.Exception.Message
    )
}


<#
Atenção na análise
A lista é um ponto de investigação, não uma autorização para iniciar todos os serviços. 
A propriedade DelayedAutoStart, por exemplo, identifica serviços programados para iniciar após os demais serviços automáticos, com um pequeno atraso. 
Considere esse contexto ao executar a consulta logo após o boot.

Na sua rotina, qual serviço você costuma verificar primeiro quando uma aplicação não volta após a reinicialização?
#>

#PowerShell #Infraestrutura #WindowsServer #SysAdmin #Automacao