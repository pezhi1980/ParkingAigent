"""
Export YOLOv8n → TFLite (Android)
===================================
Run AFTER train.py succeeds.

Requirements:
  pip install ultralytics tensorflow

Usage:
  python export_tflite.py --weights runs/dk_plate_v1/weights/best.pt
"""

import argparse
from ultralytics import YOLO

parser = argparse.ArgumentParser()
parser.add_argument('--weights', default='runs/dk_plate_v1/weights/best.pt')
parser.add_argument('--imgsz', type=int, default=320)  # smaller for mobile
args = parser.parse_args()

model = YOLO(args.weights)

# Export to TFLite (INT8 quantized for faster inference on Android)
model.export(
    format='tflite',
    imgsz=args.imgsz,
    int8=True,                  # quantize to INT8 — 4x faster on mobile NPU
    data='dataset.yaml',       # needed for INT8 calibration
)

print(f'\n✅ TFLite model exported')
print(f'   Copy the .tflite file to: src/ml/models/dk_plate.tflite')
print(f'\n📱 Android inference target: <200ms per frame on mid-range device')
