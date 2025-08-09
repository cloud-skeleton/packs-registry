from pathlib import Path
from .installer import install
from .runner import run

def deploy() -> None:
    app: Path = install()
    for line in run(f"{app} --help"):
        print(line)

def destroy() -> None:
    app: Path = install()
    for line in run(f"{app} --help"):
        print(line)