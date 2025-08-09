from collections.abc import Iterator
from os import environ
from pathlib import Path
from subprocess import Popen, PIPE
from .installer import install

def run(command: str) -> Iterator[str]:
    app: Path = install()
    environ.update({
        "CERT_FILE": environ.get("NOMAD_CLIENT_CERT", ""),
        "FS_JOBS_PATH": "recipes",
        "KEY_FILE":  environ.get("NOMAD_CLIENT_KEY", ""),
        "ROOT_CA_FILE":  environ.get("NOMAD_CACERT", ""),
    })
    process: Popen = Popen(f"{app} {command}", stdout = PIPE, shell = True)
    while True:
        if not process.poll():
            break
        if not (stdout := process.stdout):
            continue
        yield stdout.readline().rstrip().decode("utf-8")