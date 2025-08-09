from collections.abc import Iterator
from subprocess import Popen, PIPE

def run(command: str) -> Iterator[str]:
    process: Popen = Popen(command, stdout = PIPE, shell = True)
    while True:
        if not process.poll():
            break
        if not (stdout := process.stdout):
            continue
        yield stdout.readline().rstrip().decode("utf-8")