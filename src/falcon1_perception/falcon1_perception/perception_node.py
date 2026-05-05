# MOCK MODE ONLY
import numpy as np
import rclpy
from rclpy.node import Node
from sensor_msgs.msg import Image
from std_msgs.msg import Float32MultiArray

from falcon1_perception.tool_detector import MockDetector


class PerceptionNode(Node):
    def __init__(self):
        super().__init__('perception_node')
        self.detector = MockDetector()
        self.pub = self.create_publisher(Float32MultiArray, 'detections', 10)
        self.create_subscription(Image, 'image_raw', self.image_callback, 10)

    def image_callback(self, msg: Image):
        image = np.frombuffer(msg.data, dtype=np.uint8).reshape(
            msg.height, msg.width, -1
        )
        detections = self.detector.detect(image)
        out = Float32MultiArray()
        out.data = detections.flatten().tolist()
        self.pub.publish(out)


def main():
    rclpy.init()
    rclpy.spin(PerceptionNode())
    rclpy.shutdown()


if __name__ == '__main__':
    main()
