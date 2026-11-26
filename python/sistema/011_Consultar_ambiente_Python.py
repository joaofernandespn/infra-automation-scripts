# Finalidade:
#     Consultar o ambiente Python utilizado para executar este script.
#
# Pre-requisitos:
#     Python 3.6 ou superior.
#     Nenhum pacote externo necessario.
#
# Autor:
#     Joao Fernandes
#
# Contexto:
#     Projeto Scripts de Infra para LinkedIn | Script 011.
#
# Versao:
#     1.0.0
#
# Limitacoes:
#     Consulta somente o ambiente do processo atual.
#     Nao inventaria todas as instalacoes do Python.
#     Nao valida bibliotecas externas nem a saude do Windows.


# 1. Importacao dos modulos da biblioteca padrao.
import os
import platform
import sys
from datetime import datetime


# 2. Coleta das informacoes do ambiente.
def coletar_ambiente():
    """Retorna as informacoes consultadas em um dicionario."""

    return {
        # Usa o fuso horario local e inclui seu deslocamento em relacao ao UTC.
        "Momento da coleta": datetime.now().astimezone().isoformat(
            timespec="seconds"
        ),
        "Versao do Python": platform.python_version(),
        "Implementacao": platform.python_implementation(),

        # Identifica o interpretador que esta executando este arquivo.
        "Executavel Python": sys.executable or "Nao informado",

        # Apresenta separadamente os dados reportados do sistema operacional.
        "Sistema operacional": platform.system(),
        "Release reportada": platform.release(),
        "Versao do sistema": platform.version(),

        # Representa o terminal/processo, nao necessariamente a pasta do script.
        "Diretorio de trabalho": os.getcwd(),

        # Identifica o caminho absoluto deste arquivo.
        "Arquivo executado": os.path.abspath(__file__),
    }


# 3. Apresentacao do relatorio no terminal.
def apresentar_relatorio(dados):
    """Exibe os campos coletados, preservando caminhos completos."""

    print("=" * 64)
    print("SCRIPT 011 - CONSULTAR AMBIENTE PYTHON")
    print("=" * 64)

    for campo, valor in dados.items():
        print(f"{campo}: {valor}")

    print("-" * 64)
    print("Consulta concluida.")
    print("Escopo: ambiente do processo Python atual.")
    print("Nenhuma configuracao foi alterada pelo script.")


# 4. Fluxo principal e tratamento basico de erros.
def main():
    try:
        dados = coletar_ambiente()
        apresentar_relatorio(dados)
        return 0

    except Exception as erro:
        # Informa a falha sem apresentar um relatorio como se estivesse completo.
        print(
            f"ERRO: consulta nao concluida. "
            f"{type(erro).__name__}: {erro}",
            file=sys.stderr,
        )
        return 1


# 5. Executa o fluxo principal somente quando este arquivo e iniciado diretamente.
if __name__ == "__main__":
    sys.exit(main())