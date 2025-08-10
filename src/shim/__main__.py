from pathlib import Path
from questionary import autocomplete
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich import box
from typing import Any
from yaml import safe_load
from .runner import run

recipes_dir: Path = Path("recipes")
recipes: list[Path] = sorted({
    flow_file.parent.relative_to(recipes_dir)
    for flow_file in recipes_dir.rglob("flow.json")
})

def deploy() -> None:
    autocomplete("Please select a recipe", choices = []).ask()
    for line in run("--help"):
        print(line)

def destroy() -> None:
    for line in run("--help"):
        print(line)

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
        meta_version: str = "(no version provided)"
        meta_description: str = "(no description provided)"
        meta_components: str = "(no components provided)"
        if ((meta_file := recipes_dir / recipe / "meta.yml").exists()):
            meta: dict[str, Any] = safe_load(meta_file.read_bytes())
            if meta['version']:
                meta_version = meta['version']
            if meta['description']:
                meta_description = meta['description']
            if meta['components']:
                meta_components = "\n".join([
                    f"[link={component}]{component}[/link]"
                    for component in meta['components']
                ])
        table.add_row(str(recipe), meta_version, meta_description, meta_components)
    panel: Panel = Panel.fit(table, border_style = "bright_blue")
    console.print(panel)
