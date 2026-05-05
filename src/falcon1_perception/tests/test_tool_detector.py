import numpy as np

from falcon1_perception.tool_detector import ToolDetector


def test_tool_detector_mock_mode():
    detector = ToolDetector()

    # Create a dummy image 640x480
    dummy_image = np.zeros((480, 640, 3), dtype=np.uint8)

    # Run detection
    results = detector.detect(dummy_image)

    # Verify shape is (N, 6)
    assert results.shape == (3, 6), f"Expected shape (3, 6), got {results.shape}"

    # Verify coordinates are within image bounds
    h, w = dummy_image.shape[:2]
    for box in results:
        x1, y1, x2, y2, conf, cls_id = box
        assert 0 <= x1 <= w
        assert 0 <= x2 <= w
        assert 0 <= y1 <= h
        assert 0 <= y2 <= h
        assert 0.0 <= conf <= 1.0
