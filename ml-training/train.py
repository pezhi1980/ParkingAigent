"""
DK Parking — YOLOv8n License Plate Training Script
===================================================
Trains a YOLOv8n model to detect Danish license plates.

Requirements:
  pip install ultralytics torch torchvision

Dataset structure (YOLO format):
  ml-training/dataset/
    images/
      train/  (400+ images)
      val/    (100+ images)
    labels/
      train/  (matching .txt files)
      val/

Label format (YOLO): class_id cx cy w h  (all normalized 0–1)
  class_id = 0 (plate)

Usage:
  cd ml-training
  python train.py

Target: >90% mAP@0.5 at distances 5–15m in daylight
"""

from ultralytics import YOLO
import yaml
import os

# ── Config ────────────────────────────────────────────────────────────────────

PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))
DATASET_YAML = os.path.join(PROJECT_ROOT, 'dataset.yaml')
RUNS_DIR = os.path.join(PROJECT_ROOT, 'runs')

EPOCHS = 100
IMG_SIZE = 640
BATCH_SIZE = 16
PATIENCE = 20       # early stopping — stop if no improvement for 20 epochs
MODEL_BASE = 'yolov8n.pt'  # smallest YOLOv8 variant (3.2M params) — fast on-device

# ── Dataset YAML ─────────────────────────────────────────────────────────────

dataset_config = {
    'path': os.path.join(PROJECT_ROOT, 'dataset'),
    'train': 'images/train',
    'val': 'images/val',
    'names': {0: 'plate'},
    'nc': 1,
}

with open(DATASET_YAML, 'w') as f:
    yaml.dump(dataset_config, f)

print(f'Dataset YAML written to {DATASET_YAML}')

# ── Train ────────────────────────────────────────────────────────────────────

model = YOLO(MODEL_BASE)

results = model.train(
    data=DATASET_YAML,
    epochs=EPOCHS,
    imgsz=IMG_SIZE,
    batch=BATCH_SIZE,
    patience=PATIENCE,
    project=RUNS_DIR,
    name='dk_plate_v1',
    device='0' if __import__('torch').cuda.is_available() else 'cpu',
    # Augmentation — important for robustness in varying conditions
    hsv_h=0.015,     # hue variation (lighting)
    hsv_s=0.7,       # saturation variation
    hsv_v=0.4,       # brightness variation (overcast → sunny)
    degrees=5.0,     # small rotation (phone tilt)
    scale=0.5,       # scale jitter (different distances)
    shear=2.0,       # perspective shear
    perspective=0.0005,
    flipud=0.0,      # plates are always horizontal
    fliplr=0.5,      # mirror plates (valid — they're symmetric)
    mosaic=1.0,      # mosaic augmentation
    mixup=0.1,
    copy_paste=0.1,
)

print('\n✅ Training complete!')
print(f'Best model: {results.save_dir}/weights/best.pt')

# ── Validate ─────────────────────────────────────────────────────────────────

best_model = YOLO(f'{results.save_dir}/weights/best.pt')
metrics = best_model.val(data=DATASET_YAML)

map50 = metrics.box.map50
print(f'\n📊 Validation mAP@0.5: {map50:.3f}')
if map50 >= 0.90:
    print('✅ Target accuracy met (>90% mAP@0.5)')
else:
    print(f'⚠️  Below target — current: {map50:.1%}, target: 90%')
    print('   → Collect more data, especially at 10–15m distance in various light conditions')
