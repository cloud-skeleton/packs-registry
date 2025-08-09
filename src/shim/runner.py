from collections.abc import Iterator
from pathlib import Path
from subprocess import Popen, PIPE
from .installer import install

def run(command: str) -> Iterator[str]:
    app: Path = install()
    process: Popen = Popen(f"{app} {command}", stdout = PIPE, shell = True)
    while True:
        if not process.poll():
            break
        if not (stdout := process.stdout):
            continue
        yield stdout.readline().rstrip().decode("utf-8")