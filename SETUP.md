# DK Parking — Development Setup Guide

## Prerequisites (Windows)

Install these in order:

1. **Node.js LTS** — https://nodejs.org
2. **Java JDK 17** — https://adoptium.net
3. **Android Studio** — https://developer.android.com/studio
   - In SDK Manager: install Android 14 (API 34) SDK
   - Create an AVD (emulator) with Pixel 7 / API 34
4. **Python 3.10+** — https://python.org (for ML training)
5. **Git** — https://git-scm.com

Set environment variables (add to System Environment Variables):
```
ANDROID_HOME = C:\Users\<you>\AppData\Local\Android\Sdk
JAVA_HOME = C:\Program Files\Eclipse Adoptium\jdk-17...
```
Add to PATH:
```
%ANDROID_HOME%\platform-tools
%ANDROID_HOME%\tools
%JAVA_HOME%\bin
```

---

## Mobile App Setup

```bash
# 1. Install dependencies
npm install

# 2. Start Metro bundler
npm start

# 3. Run on Android emulator (new terminal)
npm run android
```

---

## Backend Setup

```bash
cd backend
npm install
cp .env.example .env
# Fill in SUPABASE_URL and SUPABASE_SERVICE_KEY in .env

# Run locally
npm run dev
```

---

## Supabase Setup

1. Create a new project at https://supabase.com
2. Go to SQL Editor → paste contents of `backend/supabase_schema.sql`
3. Run the SQL
4. Copy your Project URL and Service Role key to `backend/.env`

---

## ML Training Setup

```bash
cd ml-training
pip install ultralytics torch torchvision pyyaml

# Collect and label 500+ plate images first (see collect_dataset.py)
# Then:
python train.py

# After training succeeds:
python export_tflite.py   # for Android
python export_coreml.py   # for iOS (Mac only)

# Copy models to:
cp runs/dk_plate_v1/weights/best-int8.tflite ../src/ml/models/dk_plate.tflite
```

---

## Running Tests

```bash
npm test
```

Expected: all tests in `__tests__/` pass.

---

## iOS Build (Mac required)

```bash
cd ios
pod install
cd ..
npm run ios
```

---

## Deployment — Backend to Render

1. Push `backend/` to a GitHub repo
2. Create a new Web Service at https://render.com
3. Build command: `npm install`
4. Start command: `npm start`
5. Add environment variables from `.env.example`
6. Deploy — free tier is sufficient for MVP

---

## Next Steps After Setup

1. ✅ Confirm Android emulator shows the app
2. ✅ Confirm test suite passes (`npm test`)
3. ✅ Deploy backend to Render
4. ✅ Run Supabase schema
5. 🔲 Collect 500+ Danish plate images
6. 🔲 Label with Roboflow → train YOLOv8n
7. 🔲 Integrate compiled TFLite into Android native module
8. 🔲 Field test at Copenhagen intersections
