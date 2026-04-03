# APP ↔ AGENT ALIGNMENT REPORT
## DK Parking — Main App vs SDK Agent
## Date: 2026-04-04
## Status: Read-only analysis — no changes made to either project

---

## 1. پروژه‌ها

| پروژه | مسیر | توضیح |
|---|---|---|
| **اپلیکیشن اصلی** | `C:\Users\Pezhm\dk-parking` | محصول فعلی در حال توسعه |
| **SDK Agent** | `C:\Users\Pezhm\DK-PARKING-AGENT\DK-PARKING-AGENT` | هدف V1 — معماری AR-native |

---

## 2. Stack اپلیکیشن اصلی

| بخش | تکنولوژی |
|---|---|
| Frontend | React + Vite + TailwindCSS (PWA) |
| Mobile wrapper | Capacitor (`@capacitor/android` v7.4.4) |
| Build artifact | `parking-app-debug.apk` موجود است |
| Backend server | Node.js/Express روی `https://parking-app-b8fm.onrender.com` |
| Database | Supabase `qnvgtkxcdbirzoeceltt` |
| Map | Mapbox GL v2.15 |
| ML/Vision | TensorFlow.js + COCO-SSD (on-device) |

---

## 3. Stack SDK Agent

| بخش | تکنولوژی |
|---|---|
| iOS SDK | Swift Package — ARKit + Core ML |
| Android SDK | Kotlin AAR — ARCore + TFLite |
| Backend server | Node.js/Express روی `https://dk-parking-agent.onrender.com` |
| Database | Supabase `qnvgtkxcdbirzoeceltt` (همان پروژه) |
| Measurement | ARCore/ARKit metric scale |

---

## 4. نقاط هم‌راستا ✅

| موضوع | توضیح |
|---|---|
| **Supabase project** | هر دو از `qnvgtkxcdbirzoeceltt` استفاده می‌کنند. جداول SDK (telemetry_events, dataset_regions) با جداول موجود اپ اصلی (parking_rules_10m, parking_spots, ...) تداخل ندارند. |
| **Privacy principle** | `ComplianceGuard.jsx` می‌گوید "No Image Storage, Local Processing" — مطابق `privacy_and_telemetry_spec.md` §2 |
| **Offline evaluation** | هر دو پروژه ارزیابی را on-device انجام می‌دهند، بدون نیاز به شبکه |
| **Confidence engine** | هر دو یک confidence score می‌سازند (روش و وزن‌ها متفاوت است) |
| **Backend جداست** | اپ اصلی از `parking-app-b8fm.onrender.com`، SDK از `dk-parking-agent.onrender.com` — هیچ conflict ای ندارند |
| **UNAVAILABLE/UNVERIFIABLE state** | هر دو پروژه یک state مسدودکننده برای کیفیت پایین دارند |

---

## 5. ناهماهنگی‌های مهم ❌

### 5.1 Decision States متفاوت

| اپ اصلی (`core/decisionEngine.js`) | SDK Agent (`DecisionState.kt/.swift`) |
|---|---|
| `SAFE` | `LEGAL_WITH_BUFFER` |
| `RISK` | `LEGAL_AT_MARGIN` |
| `NOT_ALLOWED` | `ILLEGAL` |
| `UNAVAILABLE` | `UNVERIFIABLE` |

اپ اصلی 4 state دارد، SDK 5 state دارد (یک state اضافی برای حالت‌های خاص).

→ اگر این دو قرار است یک محصول باشند، این **PC-001 parity criteria** را نقض می‌کند.

---

### 5.2 Legal threshold اشتباه در اپ اصلی

```js
// MeasureCamera.jsx — line 17
const LEGAL_LIMIT = 14.0; // قانون ۱۴ متر ❌
```

آستانه‌های قانونی دانمارک در `LEGAL_THRESHOLDS.md` و `RuleFamily.kt`:

| Rule Family | آستانه صحیح |
|---|---|
| `pedestrian_crossing` | **5.0 m** |
| `intersection` | **10.0 m** |
| `bus_stop` | **12.0 m** |
| `fire_hydrant` | **3.0 m** |
| `marked_line` | overlap-based |
| `solid_yellow_curb` | overlap-based |

عدد 14m در هیچ یک از آستانه‌های قانونی دانمارک وجود ندارد.

---

### 5.3 روش اندازه‌گیری کاملاً متفاوت

| اپ اصلی | SDK Agent |
|---|---|
| **Gyroscope + trigonometry** | **ARCore/ARKit metric scale** |
| زاویه گوشی (beta) + ارتفاع دوربین → `distance = height × tan(angle)` | Ground plane detection + perpendicular distance geometry |
| دقت: وابسته به دقت gyro و ارتفاع دستی کاربر | دقت: RSS error budget (0.18m + 0.10m + 0.20m + ...) |
| هیچ AR plane نمی‌سازد | AR plane stability score + metric scale score |

---

### 5.4 پلتفرم متفاوت

| اپ اصلی | SDK Agent |
|---|---|
| JavaScript (React) + Capacitor wrapper | Native Swift (iOS) / Kotlin (Android) |
| کد JS در Capacitor WebView اجرا می‌شود | کد native مستقیم روی دستگاه |

نمی‌توان `DKParkingSDK.swift` یا `DKParkingSDK.kt` را مستقیماً در پروژه Capacitor/JS import کرد.
برای ادغام، باید یک **Capacitor Plugin** ساخته شود که SDK native را expose کند.

---

### 5.5 Compliance text متفاوت

| اپ اصلی (`ComplianceGuard.jsx`) | SDK Agent (`user_disclosures_and_copy.md`) |
|---|---|
| متن سفارشی: "Use at Your Own Risk..." | متن قفل‌شده per §6 |
| هیچ اشاره‌ای به آستانه‌های قانونی نیست | Limitations notice قفل‌شده اجباری |

---

### 5.6 Telemetry

| اپ اصلی | SDK Agent |
|---|---|
| هیچ telemetry به SDK backend ارسال نمی‌شود | `TelemetryUploader.swift/.kt` آماده است |
| سرور اصلی فقط داده پارکینگ sync می‌کند | Backend SDK جداول telemetry_events دارد |

---

## 6. دو سرور موجود در Render

| سرور | URL | نقش |
|---|---|---|
| اپ اصلی | `https://parking-app-b8fm.onrender.com` | Chat AI (`/api/chat`) + parking data sync |
| SDK Agent | `https://dk-parking-agent.onrender.com` | Telemetry (`/api/v1/telemetry/batch`) + Dataset delivery |

هر دو از همان Supabase استفاده می‌کنند ولی جداول کاملاً مجزا هستند — تداخل نیست.

---

## 7. نتیجه‌گیری کلی

```
اپ اصلی (dk-parking):
  → محصول فعلی، JavaScript/Capacitor
  → Gyroscope-based measurement
  → Decision states: SAFE / RISK / NOT_ALLOWED / UNAVAILABLE
  → Legal limit: 14m (اشتباه)
  → در حال استفاده، APK ساخته شده

SDK Agent (DK-PARKING-AGENT):
  → هدف V1، Native Swift/Kotlin
  → ARCore/ARKit-based measurement
  → Decision states: 5 state قفل‌شده
  → Legal thresholds: 5m/10m/12m (صحیح)
  → کد آماده، device run انجام نشده
```

---

## 8. اقدامات پیشنهادی (نیاز به تصمیم)

اگر هدف این است که اپ اصلی با Agent هماهنگ شود:

| اقدام | اولویت | توضیح |
|---|---|---|
| اصلاح `LEGAL_LIMIT` از 14m به rule-family based thresholds | **بالا** | فوری — این عدد قانوناً اشتباه است |
| هماهنگ‌سازی decision state vocabulary | **بالا** | `SAFE`→`LEGAL_WITH_BUFFER`، `UNAVAILABLE`→`UNVERIFIABLE` |
| اصلاح compliance text با `user_disclosures_and_copy.md` | **بالا** | قانونی |
| اتصال telemetry اپ اصلی به SDK backend | **متوسط** | برای observability |
| ساخت Capacitor Plugin برای SDK native | **پایین** | اگر ادغام کامل مد نظر است |

---

## 9. تغییرات

هیچ تغییری در هیچ‌کدام از پروژه‌ها ایجاد نشد. این سند فقط گزارش تحلیل است.
