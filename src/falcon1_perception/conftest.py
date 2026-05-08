"""Pytest path bootstrap for local and reference perception tests."""

from __future__ import annotations

import sys
from pathlib import Path


def _prepend_path(path: Path) -> None:
    resolved = str(path.resolve())
    if resolved not in sys.path:
        sys.path.insert(0, resolved)


HERE = Path(__file__).resolve().parent
PROJECT_ROOT = HERE.parent.parent

_prepend_path(HERE)
_prepend_path(PROJECT_ROOT / "docs" / "references")
_prepend_path(
    PROJECT_ROOT
    / "docs"
    / "references"
    / "ros-repo-2"
    / "device"
    / "shoppinkki"
    / "shoppinkki_interfaces"
)
