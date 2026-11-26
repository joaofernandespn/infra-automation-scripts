# Finalidade:
#     Consultar o ambiente de pacotes do Python que executa este script:
#     ambiente virtual, pasta de pacotes, pip e pacotes visiveis.
#
# Pre-requisitos:
#     Python 3.8 ou superior (usa importlib.metadata).
#     Nenhum pacote externo necessario.
#
# Autor:
#     Joao Fernandes
#
# Contexto:
#     Projeto Scripts de Infra para LinkedIn | Script 012.
#
# Versao:
#     1.0.0
#
# Limitacoes:
#     Consulta somente o interpretador que executa este script.
#     Nao instala, atualiza nem remove pacotes.
#     Nao acessa a rede nem verifica vulnerabilidades ou versoes novas.
#     O teste de escrita reportado pelo sistema nao garante que uma
#     instalacao sera permitida (permissoes, politicas e proxy).


# 1. Importacao dos modulos da biblioteca padrao.
import importlib.metadata as metadata
import importlib.util
import os
import shutil
import site
import subprocess
import sys
import sysconfig
from datetime import datetime

# Tempo maximo, em segundos, para cada consulta ao pip.
TEMPO_LIMITE = 15


# 2. Funcoes auxiliares.
def consultar_pip(comando):
    """Executa 'pip --version' e retorna (texto, erro)."""
    try:
        # capture_output guarda a saida; timeout evita travar a consulta.
        resultado = subprocess.run(
            comando,
            capture_output=True,
            text=True,
            timeout=TEMPO_LIMITE,
            check=False,
        )
    except (OSError, subprocess.SubprocessError) as erro:
        return None, f"{type(erro).__name__}: {erro}"

    if resultado.returncode != 0:
        detalhe = (resultado.stderr or resultado.stdout).strip() or "sem detalhe"
        return None, f"codigo {resultado.returncode}: {detalhe}"

    return resultado.stdout.strip(), None


def contar_pacotes():
    """Conta os nomes de pacotes visiveis para este interpretador."""
    nomes = set()
    for dist in metadata.distributions():
        nome = dist.metadata["Name"]
        if nome:
            nomes.add(nome.lower())
    return len(nomes)


def comparar_pips(pip_modulo, pip_comando):
    """Compara o pip do interpretador com o pip encontrado no PATH."""
    if pip_modulo is None:
        return "NAO VERIFICADO (pip do interpretador indisponivel)"
    if pip_comando is None:
        return "NAO VERIFICADO (comando pip nao consultado)"
    if pip_modulo == pip_comando:
        return "MESMO PIP"
    return "DIFERENTE - o comando pip nao e o pip deste Python"


# 3. Coleta das informacoes.
def coletar():
    """Retorna uma lista de (campo, valor) na ordem de apresentacao."""

    # Em ambiente virtual, sys.prefix difere de sys.base_prefix.
    em_venv = sys.prefix != sys.base_prefix
    pasta_pacotes = sysconfig.get_paths().get("purelib") or "Nao informado"

    # Teste de escrita informado pelo sistema, sem criar nenhum arquivo.
    if os.path.isdir(pasta_pacotes):
        escrita = "SIM" if os.access(pasta_pacotes, os.W_OK) else "NAO"
    else:
        escrita = "Pasta nao encontrada"

    # Consulta o pip pelo proprio interpretador e pelo comando do PATH.
    tem_modulo_pip = importlib.util.find_spec("pip") is not None
    if tem_modulo_pip:
        pip_modulo, erro_modulo = consultar_pip(
            [sys.executable, "-m", "pip", "--version"]
        )
    else:
        pip_modulo, erro_modulo = None, "modulo pip nao encontrado"

    caminho_pip = shutil.which("pip")
    if caminho_pip:
        pip_comando, erro_comando = consultar_pip([caminho_pip, "--version"])
    else:
        pip_comando, erro_comando = None, "comando pip nao encontrado no PATH"

    return [
        ("Momento da coleta",
         datetime.now().astimezone().isoformat(timespec="seconds")),
        ("Executavel Python", sys.executable or "Nao informado"),
        ("Versao do Python", sys.version.split()[0]),
        ("Ambiente virtual", "SIM" if em_venv else "NAO"),
        ("Prefixo em uso", sys.prefix),
        ("Prefixo base", sys.base_prefix),
        ("Variavel VIRTUAL_ENV", os.environ.get("VIRTUAL_ENV", "Nao definida")),
        ("Pasta de pacotes (site-packages)", pasta_pacotes),
        ("Escrita reportada na pasta", escrita),
        ("Pacotes de usuario habilitados", "SIM" if site.ENABLE_USER_SITE else "NAO"),
        ("Pacotes visiveis ao interpretador", contar_pacotes()),
        ("pip via 'python -m pip'", pip_modulo or f"INDISPONIVEL ({erro_modulo})"),
        ("Comando pip no PATH", caminho_pip or "Nao encontrado"),
        ("pip via comando do PATH", pip_comando or f"INDISPONIVEL ({erro_comando})"),
        ("Comparacao dos dois pip", comparar_pips(pip_modulo, pip_comando)),
    ]


# 4. Apresentacao do relatorio no terminal.
def apresentar(campos):
    print("=" * 64)
    print("SCRIPT 012 - CONSULTAR AMBIENTE DE PACOTES (PIP)")
    print("=" * 64)

    for campo, valor in campos:
        print(f"{campo}: {valor}")

    print("-" * 64)
    print("Consulta concluida.")
    print("Escopo: interpretador que executou este script.")
    print("Nenhum pacote foi instalado, alterado ou removido.")


# 5. Fluxo principal e tratamento basico de erros.
def main():
    try:
        apresentar(coletar())
        return 0
    except Exception as erro:
        print(
            f"ERRO: consulta nao concluida. {type(erro).__name__}: {erro}",
            file=sys.stderr,
        )
        return 1


if __name__ == "__main__":
    sys.exit(main())