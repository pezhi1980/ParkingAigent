"""
Export YOLOv8n → CoreML (iOS)
================================
Must be run on a Mac with Xcode installed.

Requirements:
  pip install ultralytics coremltools

Usage:
  python export_coreml.py --weights runs/dk_plate_v1/weights/best.pt
"""

import argparse
from ultralytics import YOLO

parser = argparse.ArgumentParser()
parser.add_argument('--weights', default='runs/dk_plate_v1/weights/best.pt')
parser.add_argument('--imgsz', type=int, default=320)
args = parser.parse_args()

model = YOLO(args.weights)

model.export(
    format='coreml',
    imgsz=args.imgsz,
    nms=True,  # include NMS in the model for simpler iOS integration
)

print(f'\n✅ CoreML model exported (.mlpackage)')
print(f'   Copy to: src/ml/models/dk_plate.mlpackage')
print(f'   Then compile in Xcode to: dk_plate.mlmodelc')
print(f'\n📱 iOS inference target: <150ms per frame on iPhone 12+')
