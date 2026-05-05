import numpy as np


class ToolDetector:
    def __init__(self):
        self.mock_mode = True

    def detect(self, image: np.ndarray) -> np.ndarray:
        h, w = image.shape[:2]
        return np.array([
            [10, 10, w // 3, h // 3, 0.95, 0],
            [w // 3, h // 3, 2 * w // 3, 2 * h // 3, 0.88, 1],
            [2 * w // 3, 2 * h // 3, w - 10, h - 10, 0.92, 2],
        ], dtype=np.float32)
