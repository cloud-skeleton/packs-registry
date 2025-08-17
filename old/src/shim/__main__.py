from pathlib import Path
from questionary import select, text
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich import box
from sys import argv
from typing import Any
from yaml import safe_load
from .processor import process
from .runner import run

recipes_dir: Path = Path("recipes")
recipes: list[Path] = sorted({
    flow_file.parent.relative_to(recipes_dir)
    for flow_file in recipes_dir.rglob("flow.json")
    if (meta_file := (flow_file.parent / "meta.yml")).exists()
        and {"components", "description", "entrypoint", "version"} <= set(safe_load(meta_file.read_bytes()))
})

def deploy() -> None:
    recipe: str = select("Please select a recipe", choices = [ str(recipe) for recipe in recipes ]).ask()
    meta: dict[str, Any] = safe_load((recipes_dir / recipe / "meta.yml").read_bytes())
    variables: dict[str, Any] = {
        name: text(
            name,
            default = str(default_value) if default_value else "",
            validate = lambda item: len(item) > 0
        ).ask()
        for name, default_value in meta['variables'].items()
    }
    with process(recipes_dir / recipe, variables) as recipe_temp:
        for line in run(
            f"run --job={meta['entrypoint']}"
            f" --fs-depfile-path={recipe_temp / 'flow.json'}"
            f" --fs-jobs-path={recipe_temp / 'jobs'}"
        ):
            print(line)

def destroy() -> None:
    for line in run("--help"):
        print(line)

def info() -> None:
    if len(argv) < 2:
        raise SystemExit("Missing recipe!")
    recipe: Path = recipes_dir / argv[1]
    if not recipe.is_dir():
        raise SystemExit("Invalid recipe path!")
    meta: dict[str, Any] = safe_load((recipe / "meta.yml").read_bytes())


def list() -> None:
    console: Console = Console()
    table: Table = Table(
        title = "🍳 Available Recipes",
        title_style = "bold magenta",
        header_style = "bold cyan"
    )
    table.box = box.ROUNDED
    table.add_column("Recipe", style = "bold yellow", no_wrap = True)
    table.add_column("Version")
    table.add_column("Description")
    table.add_column("Components")
    for recipe in recipes:
        # meta: dict[str, Any] = safe_load((recipes_dir / recipe / "meta.yml").read_bytes())
        # meta_version: str = meta['version'] or "(no version provided)"
        # meta_description: str = meta['description'] or "(no description provided)"
        # meta_components: str = "(no components provided)"
        # if meta['components']:
        #     meta_components = "\n".join([
        #         f"[link={component}]{component}[/link]"
        #         for component in meta['components']
        #     ])
        table.add_row(str(recipe), meta_version, meta_description, meta_components)
    panel: Panel = Panel.fit(table, border_style = "bright_blue")
    console.print(panel)
