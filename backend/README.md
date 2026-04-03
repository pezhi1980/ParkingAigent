# DK Parking Engine — Backend API

Deployed on **Render** (`srv-d4kctj3uibrs73fduhr0`).
Database: **Supabase** (`qnvgtkxcdbirzoeceltt`).

## What this backend does

Per `SYSTEM_ARCHITECTURE.md` — the legal decision path runs **entirely on-device**.
This server handles only:

| Subsystem | Role |
|---|---|
| SS-04 Dataset Delivery | Serve regional dataset bundle metadata + signed download URLs |
| SS-10 Telemetry | Receive structured anonymous evaluation telemetry from iOS + Android |

The backend **never** touches the legal evaluation path.

---

## Endpoints

| Method | Path | Purpose |
|---|---|---|
| `GET` | `/health` | Health check (Render uses this) |
| `POST` | `/api/v1/telemetry/batch` | Ingest batch of telemetry events |
| `GET` | `/api/v1/dataset/regions` | List active dataset regions |
| `GET` | `/api/v1/dataset/regions/:regionId` | Get region metadata + signed download URL |
| `GET` | `/api/v1/dataset/regions/:regionId/check` | Lightweight version check |

---

## Setup on Render

1. Connect this repository to Render
2. Set **Root Directory** to `backend/`
3. **Build command:** `npm install`
4. **Start command:** `node server.js`
5. Add the following **Environment Variables** in Render dashboard:

| Variable | Value |
|---|---|
| `SUPABASE_URL` | `https://qnvgtkxcdbirzoeceltt.supabase.co` |
| `SUPABASE_SERVICE_ROLE_KEY` | *(from Supabase → Settings → API → service_role)* |
| `MOBILE_API_KEY` | *(random secret, shared with iOS/Android apps)* |

---

## Supabase setup

1. Open Supabase dashboard → `qnvgtkxcdbirzoeceltt`
2. Go to **SQL Editor**
3. Run the full contents of `supabase/schema.sql`
4. Go to **Storage** → **New bucket** → name: `dataset-bundles`, set to **private**

---

## Local development

```bash
cd backend
cp .env.example .env
# Fill in SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, MOBILE_API_KEY in .env
npm install
npm run dev
```

Test health:
```
curl http://localhost:3000/health
```

Test telemetry:
```bash
curl -X POST http://localhost:3000/api/v1/telemetry/batch \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your_mobile_api_key_here" \
  -d '{
    "platform": "ios",
    "events": [{
      "event_type": "session_started",
      "session_id": "00000000-0000-0000-0000-000000000001",
      "timestamp_utc": "2026-04-04T00:00:00Z",
      "sdk_version": "sdk-v1.0.0-ios",
      "policy_version": "policy-v1.0.0",
      "dataset_version": "REG-DK-001-STUB-v1.0.0",
      "dataset_region_id": "REG-DK-001",
      "platform": "ios",
      "os_version": "17.0"
    }]
  }'
```

---

## Privacy

All telemetry events are validated server-side against `privacy_and_telemetry_spec.md`:
- No camera frame, AR geometry, or GPS data accepted
- No user/device identifiers accepted
- Forbidden fields are stripped before storage
