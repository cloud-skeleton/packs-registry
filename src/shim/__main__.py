from .runner import run

def deploy() -> None:
    for line in run("--help"):
        print(line)

def destroy() -> None:
    for line in run("--help"):
        print(line)