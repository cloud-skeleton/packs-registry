from os import environ
from pathlib import Path
from stat import S_IEXEC
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

def install() -> Path:
    app: Path = _bin_dir() / "nomad-dtree"
    if app.exists():
        return app
    _download(APP_URL, app)
    app.chmod(app.stat().st_mode | S_IEXEC)
    return app
