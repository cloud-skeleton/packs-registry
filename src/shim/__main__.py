from rich import print
from .runner import run

def deploy() -> None:
    for line in run("--help"):
        print(line)

def destroy() -> None:
    for line in run("--help"):
        print(line)

def list() -> None:
    print("Hello, [bold magenta]World[/bold magenta]!", ":vampire:", locals())