from pathlib import Path
from typing import Any
from yaml import safe_load

def get_meta(recipe: Path) -> dict[str, Any]:
    meta: dict[str, Any] = safe_load((recipe / "meta.yml").read_bytes())
    meta_version: str = meta['version'] or "(no version provided)"
    meta_description: str = meta['description'] or "(no description provided)"
    meta_components: str = "(no components provided)"
    if meta['components']:
        meta_components = "\n".join([
            f"[link={component}]{component}[/link]"
            for component in meta['components']
        ])
    return {
        'version': meta_version,
        'description': meta_description,
        'components': meta_components
    }