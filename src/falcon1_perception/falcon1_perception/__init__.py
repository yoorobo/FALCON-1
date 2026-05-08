"""FALCON-1 perception package exports."""

from .tool_detector import ToolDetector

# Legacy code still imports MockDetector from this package.
MockDetector = ToolDetector

__all__ = ["MockDetector", "ToolDetector"]
