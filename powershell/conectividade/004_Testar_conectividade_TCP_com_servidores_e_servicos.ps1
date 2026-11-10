<#
.SYNOPSIS
    Testa conectividade TCP com uma lista de servidores e portas.

.DESCRIPTION
    Finalidade:
    Testar combinações de servidor e porta TCP e apresentar
    o resultado em uma tabela, sem alterar configurações.

    Pré-requisitos:
    - Windows com o cmdlet Test-NetConnection disponível.
    - Destinos e portas autorizados para teste.
    - Substituição dos exemplos pelos destinos reais do ambiente.

    Limitações:
    - SUCESSO confirma o estabelecimento da conexão TCP.
    - Não valida autenticação, TLS ou funcionamento da aplicação.
    - FALHA não identifica, isoladamente, a causa do problema.
    - Os testes são sequenciais e podem demorar em destinos inacessíveis.
    - O IP exibido é o RemoteAddress retornado pelo teste,
      não uma lista de todos os endereços associados ao nome.

    Autor/Contexto:
    João Fernandes — Scripts de Infra para LinkedIn.
    Script 004: conectividade TCP com servidores e serviços.
    Versão: 1.0.0

.EXAMPLE
    .\004_Testar_conectividade_TCP_com_servidores_e_servicos.ps1

    Antes de executar, configure a lista $Destinos.
#>

<#
TEXTO DE REFERÊNCIA PARA O LINKEDIN

“O servidor responde ao ping, mas a aplicação não conecta.”

Nesse cenário, vale testar diretamente a combinação de servidor
e porta utilizada pela aplicação, em vez de depender apenas do ping.

O Test-NetConnection -Port permite testar a conexão TCP com o destino
e apresenta o resultado em TcpTestSucceeded.

O script abaixo organiza a verificação em uma única tabela:

- Servidor consultado.
- Endereço IP retornado.
- Porta testada.
- Resultado da conexão.
- Detalhes do resultado ou de erros na execução.
#>

# 1. Configuração dos destinos
# Exemplos: substitua os nomes e confirme as portas reais dos serviços.
$Destinos = @(
    [PSCustomObject]@{
        Servidor = "web01.seudominio.local"
        Porta    = 443
    }
    [PSCustomObject]@{
        Servidor = "srv01.seudominio.local"
        Porta    = 3389
    }
    [PSCustomObject]@{
        Servidor = "sql01.seudominio.local"
        Porta    = 1433
    }
)

# 2. Validação dos pré-requisitos
try {
    # Interrompe antes dos testes se o cmdlet não estiver disponível.
    $null = Get-Command -Name Test-NetConnection -ErrorAction Stop
}
catch {
    Write-Warning (
        "Test-NetConnection não está disponível nesta sessão: {0}" -f
        $_.Exception.Message
    )

    return
}

# Evita executar uma lista sem destinos.
if (@($Destinos).Count -eq 0) {
    Write-Warning "Nenhum destino foi configurado para teste."
    return
}

# 3. Execução dos testes
# @() mantém os resultados como coleção, mesmo com apenas um item.
$Resultados = @(
    foreach ($Destino in $Destinos) {
        try {
            # Confere se o nome ou IP foi informado.
            $Servidor = [string]$Destino.Servidor

            if ([string]::IsNullOrWhiteSpace($Servidor)) {
                throw "O nome ou IP do servidor não foi informado."
            }

            # Remove espaços acidentais no início e no fim.
            $Servidor = $Servidor.Trim()

            # Aceita somente uma porta inteira no intervalo permitido.
            $Porta = 0

            if (
                -not [int]::TryParse([string]$Destino.Porta, [ref]$Porta) -or
                $Porta -lt 1 -or
                $Porta -gt 65535
            ) {
                throw "A porta deve ser um número inteiro entre 1 e 65535."
            }

            # Splatting organiza os parâmetros da consulta.
            # Os avisos são suprimidos para manter o resumo em uma tabela.
            # Erros terminantes são tratados pelo catch de cada destino.
            $Parametros = @{
                ComputerName     = $Servidor
                Port             = $Porta
                InformationLevel = "Detailed"
                WarningAction    = "SilentlyContinue"
                ErrorAction      = "Stop"
            }

            $Teste = Test-NetConnection @Parametros

            # Evita registrar uma falha comum caso nenhum objeto seja retornado.
            if ($null -eq $Teste) {
                throw "O teste não retornou informações sobre a conexão."
            }

            # Organiza o resultado e diferencia conexão, falha e ausência de IP.
            [PSCustomObject]@{
                Servidor = $Servidor
                IP       = [string]$Teste.RemoteAddress
                Porta    = $Porta

                Conexao = if ($Teste.TcpTestSucceeded) {
                    "SUCESSO"
                }
                else {
                    "FALHA"
                }

                Detalhe = if ($Teste.TcpTestSucceeded) {
                    "Conexão TCP estabelecida."
                }
                elseif (
                    [string]::IsNullOrWhiteSpace(
                        [string]$Teste.RemoteAddress
                    )
                ) {
                    "Conexão não estabelecida; nenhum IP remoto foi retornado. Verifique a resolução do nome."
                }
                else {
                    "Conexão TCP não estabelecida. Verifique serviço, porta e caminho de rede."
                }
            }
        }
        catch {
            # Registra o erro deste destino e continua com os demais.
            [PSCustomObject]@{
                Servidor = $Destino.Servidor
                IP       = $null
                Porta    = $Destino.Porta
                Conexao  = "ERRO"
                Detalhe  = $_.Exception.Message
            }
        }
    }
)

# 4. Apresentação do resumo
$Resultados |
    Format-Table Servidor, IP, Porta, Conexao, Detalhe -AutoSize -Wrap

# 5. Orientação para interpretar o resultado
Write-Output (
    "SUCESSO confirma somente a conexão TCP. " +
    "FALHA não identifica, isoladamente, a causa do problema. " +
    "ERRO indica falha na validação ou na execução do teste."
)

<#
COMO INTERPRETAR

SUCESSO:
A conexão TCP com o destino e a porta foi estabelecida.
Isso não valida autenticação, TLS, consultas ao banco
ou transações da aplicação.

FALHA:
O teste não confirmou o estabelecimento da conexão TCP.
O resultado, isoladamente, não determina a causa do problema.

Quando nenhum IP remoto é retornado, o resumo orienta conferir
a resolução do nome, sem afirmar que essa seja a causa definitiva.

ERRO:
A validação dos dados ou a execução do teste gerou uma exceção
capturada pelo script. A mensagem aparece na coluna Detalhe.

Os destinos são testados sequencialmente. Um destino inacessível
pode aumentar o tempo total de execução.

Qual combinação de servidor e porta não pode faltar
no seu checklist de troubleshooting?
#>

#PowerShell #Redes #Troubleshooting #Infraestrutura #SysAdmin
