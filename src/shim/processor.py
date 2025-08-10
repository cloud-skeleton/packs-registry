from contextlib import contextmanager
from jinja2 import Template
from pathlib import Path
from shutil import copytree, rmtree
from typing import Iterator, Any

recipes_dir: Path = Path("recipes")

@contextmanager
def process(recipe: Path, variables: dict[str, Any]) -> Iterator[Path]:
    recipe_temp: Path = Path(f".venv/.cache/{recipe}")
    try:
        copytree(recipe, recipe_temp, symlinks = True)
        for job in (recipe_temp / "jobs").rglob("*.hcl"):
            job.write_text(Template(job.read_text()).render(**variables))
        yield recipe_temp
    finally:
        rmtree(recipe_temp)
