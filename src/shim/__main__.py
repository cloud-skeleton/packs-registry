from pathlib import Path
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich import box
from typing import Any
from yaml import safe_load
from .runner import run

def deploy() -> None:
    for line in run("--help"):
        print(line)

def destroy() -> None:
    for line in run("--help"):
        print(line)

def list() -> None:
    base_path: Path = Path("recipes")
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
    table.add_column("URL")
    dependency_file: Path
    for dependency_file in sorted(base_path.rglob("dependency.json")):
        recipe_dir: Path = dependency_file.parent
        recipe: str = "/".join(recipe_dir.relative_to(base_path).parts)
        meta_version: str = "(no version provided)"
        meta_description: str = "(no description provided)"
        meta_url: str = "(no URL provided)"
        if ((meta_file := recipe_dir / "meta.yml").exists()):
            meta: dict[str, Any] = safe_load(meta_file.read_bytes())
            if meta["version"]:
                meta_version = meta["version"]
            if meta["description"]:
                meta_description = meta["description"]
            if meta["url"]:
                meta_url = f"[link={meta['url']}]{meta['url']}[/link]"
        table.add_row(recipe, meta_version, meta_description, meta_url)
    panel: Panel = Panel.fit(table, border_style = "bright_blue")
    console.print(panel)
