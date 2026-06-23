"""
Dataset collection helper for DK license plates.
================================================
Scrapes publicly available images of Danish cars and extracts/validates
plate regions. All images must be manually reviewed before use.

Target: 500+ images across:
  - Distance: 3–20m from camera
  - Lighting: sunny, overcast, shade
  - Angle: 0–15° tilt
  - Vehicle types: cars, vans, trucks, motorcycles (no plate — skip)
  - Plate types: standard white (520×110mm), trailer plates

Usage:
  python collect_dataset.py --output dataset/images/train --count 400
"""

import os
import argparse
import hashlib
import requests
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--output', default='dataset/images/train')
parser.add_argument('--count', type=int, default=400)
args = parser.parse_args()

output_dir = Path(args.output)
output_dir.mkdir(parents=True, exist_ok=True)

print(f'Dataset directory: {output_dir.resolve()}')
print(f'\n📋 Manual collection checklist:')
print(f'   1. Take photos of cars at 5m, 10m, 12m, 15m from camera')
print(f'   2. Vary: morning/afternoon/overcast light')
print(f'   3. Vary: phone tilt 0°, 5°, 10°, 15°')
print(f'   4. Include: front plates, rear plates')
print(f'   5. Include: cars, vans, SUVs')
print(f'   6. Blur any distinguishable faces before labeling')
print(f'\n🏷️  Labeling tool: https://roboflow.com (free for <1000 images)')
print(f'   Label class: "plate"')
print(f'   Export format: YOLO v8')
print(f'\nTarget: {args.count} images in {output_dir}')
