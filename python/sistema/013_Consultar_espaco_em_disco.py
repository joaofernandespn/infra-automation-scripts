# Finalidade:
#     Consultar o espaco em disco (total, usado, livre e percentual livre)
#     das unidades fixas do computador ou de caminhos informados, e sinalizar
#     as que estao abaixo de um limite de espaco livre.
#
# Pre-requisitos:
#     Python 3.8 ou superior.
#     Nenhum pacote externo necessario (biblioteca padrao).
#
# Autor:
#     Joao Fernandes
#
# Contexto:
#     Projeto Scripts de Infra para LinkedIn | Script 013.
#
# Versao:
#     1.0.0
#
# Uso:
#     python 013_Consultar_espaco_em_disco.py
#     python 013_Consultar_espaco_em_disco.py --limite 20
#     python 013_Consultar_espaco_em_disco.py C:\ D:\Dados
#
# Codigos de saida:
#     0 = todas as consultas OK e nenhuma unidade abaixo do limite.
#     1 = erro de execucao ou falha ao consultar algum caminho.
#     2 = consulta OK, mas ao menos uma unidade abaixo do limite.
#
# Limitacoes:
#     Somente leitura: nao apaga, move nem altera arquivos.
#     Sem argumentos, consulta as unidades fixas no Windows e apenas a raiz
#     do sistema em outros sistemas; nao lista discos de rede nem removiveis.
#     Valores em GiB (1 GiB = 1024^3 bytes), como o Explorador do Windows
#     costuma exibir como "GB".


# 1. Importacao dos modulos da biblioteca padrao.
import argparse
import ctypes
import os
import shutil
import sys
from datetime import datetime

# Limite padrao de espaco livre, em %. Pode ser trocado com --limite.
LIMITE_PADRAO = 15.0

# Bytes em 1 GiB e codigo do Windows para disco fixo (DRIVE_FIXED).
GIB = 1024 ** 3
DRIVE_FIXED = 3


# 2. Leitura e validacao dos argumentos.
class LeitorArgumentos(argparse.ArgumentParser):
    """Argumento invalido sai com codigo 1 (o 2 e reservado ao alerta)."""

    def error(self, message):
        self.print_usage(sys.stderr)
        print(f"ERRO: {message}", file=sys.stderr)
        sys.exit(1)


def ler_argumentos():
    parser = LeitorArgumentos(
        description="Consulta o espaco em disco e sinaliza pouco espaco livre."
    )
    parser.add_argument(
        "caminhos",
        nargs="*",
        help="Caminhos a consultar. Sem informar, usa as unidades fixas.",
    )
    parser.add_argument(
        "--limite",
        type=float,
        default=LIMITE_PADRAO,
        help=f"Alerta abaixo deste %% livre (padrao: {LIMITE_PADRAO:g}).",
    )
    args = parser.parse_args()

    if not 0 <= args.limite <= 100:
        parser.error("--limite deve estar entre 0 e 100.")
    return args


# 3. Funcoes de consulta.
def listar_unidades_fixas():
    """Retorna as raizes a consultar quando nenhum caminho foi informado."""
    if os.name != "nt":
        return [os.path.abspath(os.sep)]

    # GetLogicalDrives devolve um mapa de bits: bit 0 = A:, bit 1 = B: ...
    mascara = ctypes.windll.kernel32.GetLogicalDrives()
    unidades = []
    for posicao in range(26):
        if mascara & (1 << posicao):
            raiz = f"{chr(65 + posicao)}:\\"
            # Mantem apenas discos fixos (ignora CD, rede e removiveis).
            if ctypes.windll.kernel32.GetDriveTypeW(raiz) == DRIVE_FIXED:
                unidades.append(raiz)
    return unidades


def consultar_caminho(caminho, limite):
    """Retorna um dicionario com os dados do caminho ou o erro ocorrido."""
    try:
        total, usado, livre = shutil.disk_usage(caminho)
    except (OSError, ValueError) as erro:
        return {"caminho": caminho, "erro": f"{type(erro).__name__}: {erro}"}

    if total <= 0:
        return {"caminho": caminho, "erro": "tamanho total reportado: 0"}

    percentual_livre = livre / total * 100
    return {
        "caminho": caminho,
        "total": total / GIB,
        "usado": usado / GIB,
        "livre": livre / GIB,
        "percentual": percentual_livre,
        "alerta": percentual_livre < limite,
        "erro": None,
    }


# 4. Apresentacao do relatorio no terminal.
def apresentar(resultados, limite):
    print("=" * 72)
    print("SCRIPT 013 - CONSULTAR ESPACO EM DISCO")
    print("=" * 72)
    print(f"Momento da coleta: "
          f"{datetime.now().astimezone().isoformat(timespec='seconds')}")
    print(f"Limite de alerta: abaixo de {limite:g}% livre")
    print("-" * 72)
    print(f"{'Caminho':<22}{'Total GiB':>10}{'Usado GiB':>11}"
          f"{'Livre GiB':>11}{'Livre %':>9}  Status")

    for item in resultados:
        if item["erro"]:
            print(f"{item['caminho']:<22}  ERRO - {item['erro']}")
            continue
        status = "ALERTA" if item["alerta"] else "OK"
        print(f"{item['caminho']:<22}{item['total']:>10.1f}"
              f"{item['usado']:>11.1f}{item['livre']:>11.1f}"
              f"{item['percentual']:>9.1f}  {status}")

    print("-" * 72)
    print("Consulta concluida.")
    print("Nenhum arquivo foi apagado, movido ou alterado.")


# 5. Fluxo principal e tratamento basico de erros.
def main():
    try:
        args = ler_argumentos()
        caminhos = args.caminhos or listar_unidades_fixas()

        if not caminhos:
            print("ERRO: nenhum caminho para consultar.", file=sys.stderr)
            return 1

        resultados = [consultar_caminho(c, args.limite) for c in caminhos]
        apresentar(resultados, args.limite)

        if any(item["erro"] for item in resultados):
            return 1
        if any(item["alerta"] for item in resultados):
            return 2
        return 0
    except Exception as erro:
        print(
            f"ERRO: consulta nao concluida. {type(erro).__name__}: {erro}",
            file=sys.stderr,
        )
        return 1


if __name__ == "__main__":
    sys.exit(main())
