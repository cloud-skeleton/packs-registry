from os import environ
from pathlib import Path
from stat import S_IEXEC
from subprocess import Popen, PIPE
from urllib.request import urlopen

VERSION: str = "1.1.0"
APP_URL: str = f"https://github.com/sagarrakshe/nomad-dtree/releases/download/v{VERSION}/nomad-dtree"

def _bin_dir() -> Path:
    if not (venv := environ.get("VIRTUAL_ENV")):
        raise RuntimeError("Not running inside a virtual environment.")
    return Path(venv) / "bin"

def _download(url: str, destination: Path) -> None:
    with urlopen(url) as response:
        destination.write_bytes(response.read())

def _install() -> Path:
    app: Path = _bin_dir() / "nomad-dtree"
    if app.exists():
        return app
    _download(APP_URL, app)
    app.chmod(app.stat().st_mode | S_IEXEC)
    return app

def _run(command):
    process: Popen = Popen(command, stdout = PIPE, shell = True)
    while True:
        if not process.poll():
            break
        if not (stdout := process.stdout):
            continue
        yield stdout.readline().rstrip().decode("utf-8")

def main():
    app: Path = _install()
    for line in _run(f"{app} --help"):
        print(line)
