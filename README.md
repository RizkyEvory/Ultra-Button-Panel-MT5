<div align="center">

```
███╗   ███╗██╗  ██╗██████╗ ██╗    ██╗   ██╗ ██████╗██╗██╗  ██╗██╗  ██╗
████╗ ████║██║  ██║██╔══██╗██║    ██║   ██║██╔════╝██║██║  ██║██║  ██║
██╔████╔██║███████║██║  ██║██║    ██║   ██║██║     ██║███████║███████║
██║╚██╔╝██║╚════██║██║  ██║██║    ██║   ██║██║     ██║╚════██║╚════██║
██║ ╚═╝ ██║     ██║██████╔╝██║    ╚██████╔╝╚██████╗██║     ██║     ██║
╚═╝     ╚═╝     ╚═╝╚═════╝ ╚═╝     ╚═════╝  ╚═════╝╚═╝     ╚═╝     ╚═╝
```

# 🎯 Ultra Button Panel MT5
### *Premium Semi-Manual Trading Panel for MetaTrader 5*

[![Version](https://img.shields.io/badge/version-2.01-blueviolet?style=for-the-badge)](https://github.com/RizkyEvory)
[![Platform](https://img.shields.io/badge/platform-MetaTrader%205-blue?style=for-the-badge)](https://www.metatrader5.com)
[![Language](https://img.shields.io/badge/language-MQL5-orange?style=for-the-badge)](https://www.mql5.com)
[![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)](LICENSE)
[![Author](https://img.shields.io/badge/author-M4DI~UciH4-purple?style=for-the-badge)](https://github.com/RizkyEvory)

**One-Click Trading · Smart Risk Calculator · Multi-TP · Trailing Stop · Session Filter**

[📥 Download](#-installation) · [📖 Documentation](#-features) · [🐛 Report Bug](https://github.com/RizkyEvory/issues) · [💡 Request Feature](https://github.com/RizkyEvory/issues)

</div>

---

## 📌 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Panel Layout](#-panel-layout)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Keyboard Shortcuts](#️-keyboard-shortcuts)
- [Supported Markets](#-supported-markets)
- [Risk Warning](#-risk-warning)
- [Changelog](#-changelog)
- [Author](#-author)

---

## 🔭 Overview

**M4DI~UciH4 Ultra Button Panel** adalah semi-manual trading panel premium untuk MetaTrader 5 yang dirancang untuk trader yang menginginkan eksekusi cepat, manajemen risiko yang akurat, dan kontrol penuh atas setiap trade — semua dari satu panel yang elegan di chart.

Panel ini **bukan EA otomatis**. Semua keputusan trading tetap di tangan kamu. Panel hanya mempercepat dan menyederhanakan eksekusi order, manajemen posisi, dan monitoring.

```
┌─────────────────────────────────────┐
│  Tanpa Panel          Dengan Panel  │
│  ─────────────        ───────────── │
│  Buka dialog order → Klik BUY/SELL  │
│  Hitung lot manual → AUTO calculate │
│  Set SL/TP manual  → Set sekali     │
│  Monitor 3 TP      → Auto partial   │
│  Close manual      → 1 tombol       │
└─────────────────────────────────────┘
```

---

## ✨ Features

### ⚡ One-Click Buy / Sell
Eksekusi market order instan dengan satu klik. Harga **Ask** dan **Bid** ditampilkan realtime langsung di dalam tombol BUY dan SELL. Support konfirmasi dialog opsional untuk mencegah fat-finger.

- ✅ Eksekusi instan tanpa dialog tambahan
- ✅ Harga realtime di dalam tombol
- ✅ Cooldown protection anti double-click (2 detik)
- ✅ Auto-handle requote, off-quote, no connection
- ✅ Optional confirmation dialog

---

### 🧮 Smart Risk Calculator
Kalkulasi lot size otomatis berdasarkan persentase risiko akun. Formula universal yang akurat untuk semua jenis instrumen.

```
Formula:
Lot = Risk($) ÷ (SL_points × PointValue)

Dimana:
Risk($)     = AccountBalance × RiskPercent / 100
PointValue  = (SL_points × _Point) / TickSize × TickValue
```

- ✅ Support Forex, Gold (XAUUSD), Indices (US30, NAS100), Crypto
- ✅ Auto-detect digit count per symbol
- ✅ Auto-round ke lot step minimum broker
- ✅ Tampilkan risk amount dalam $ realtime
- ✅ Update otomatis saat SL atau balance berubah

---

### 🎯 Multi Take Profit (TP1 / TP2 / TP3)
Tiga level take profit dengan partial close otomatis. Setiap TP bisa di-toggle aktif/nonaktif secara independen.

| Level | Default Distance | Default Close % |
|-------|-----------------|-----------------|
| TP1   | 300 points      | 50% posisi      |
| TP2   | 600 points      | 30% posisi      |
| TP3   | 1000 points     | 20% posisi      |

- ✅ Partial close otomatis saat harga menyentuh setiap TP
- ✅ Auto geser SL ke Break Even setelah TP1 tercapai (opsional)
- ✅ Garis TP ditampilkan di chart (dashed, warna gold)
- ✅ TP Tracker rebuild otomatis saat EA restart
- ✅ Setiap TP independen — bisa aktif/nonaktif per level

---

### 🔄 Trailing Stop & Break Even

**Break Even:**
Geser SL ke harga entry + offset kecil dengan satu klik. Posisi terlindungi dari loss meskipun harga berbalik.

**Trailing Stop:**
SL otomatis mengikuti harga saat posisi profit. Aktifkan/nonaktifkan kapan saja dengan toggle button atau tekan `T`.

```
Trailing Logic:
IF profit_points >= TrailingStart THEN
   newSL = currentPrice - TrailingDistance
   IF newSL > currentSL + TrailingStep THEN
      ModifySL(newSL)
```

| Parameter        | Default | Keterangan                              |
|------------------|---------|-----------------------------------------|
| TrailingStart    | 200 pts | Mulai trailing setelah profit N points  |
| TrailingStep     | 100 pts | Minimum pergerakan sebelum update SL    |
| TrailingDistance | 150 pts | Jarak SL dari harga saat ini            |
| BE_Offset        | 10 pts  | Offset SL dari entry saat Break Even    |

---

### ✂️ Partial Close
Tutup sebagian posisi dengan satu klik tanpa perlu buka dialog.

- **25%** — Ambil profit kecil, biarkan sisanya jalan
- **50%** — Tutup setengah posisi
- **75%** — Tutup sebagian besar, sisakan sedikit

Auto-handle jika hasil lot partial < minimum lot broker → tutup semua.

---

### 🌐 Session Filter Visual
Indicator visual tiga sesi trading utama dunia.

| Session   | Jam (GMT)     | Karakteristik         |
|-----------|---------------|-----------------------|
| 🌏 Asia   | 00:00 – 09:00 | Low volatility, range |
| 🌍 London | 08:00 – 17:00 | High volatility       |
| 🌎 New York | 13:00 – 22:00 | Trend continuation   |

- ✅ Highlight session aktif secara realtime
- ✅ Overlap London-NY ditampilkan (kedua aktif)
- ✅ Optional: block trading di luar session tertentu

---

### 📊 Daily PnL Tracker
Monitor performa trading harian secara realtime.

- ✅ Daily Realized P&L ($)
- ✅ Floating P&L (posisi terbuka)
- ✅ Jumlah open trades & total lot
- ✅ Win Rate harian (wins/total)
- ✅ Reset otomatis setiap hari baru
- ✅ Persistent via GlobalVariable (tidak hilang saat EA restart)
- ✅ Update otomatis via `OnTradeTransaction()` saat SL/TP hit

---

### 📡 Spread & Swap Monitor
- ✅ Current spread dalam pips (realtime, update per tick)
- ✅ Swap Long & Short value
- ✅ Auto-block order jika spread melebihi threshold
- ✅ Visual warning saat spread terlalu lebar

---

### 🔧 Close Buttons
| Tombol         | Fungsi                                          |
|----------------|-------------------------------------------------|
| CLOSE ALL      | Tutup semua posisi (magic number EA)            |
| CLOSE BUY      | Tutup semua posisi Buy                          |
| CLOSE SELL     | Tutup semua posisi Sell                         |
| ✓ PROFIT       | Tutup semua posisi yang sedang floating profit  |
| ✗ LOSS         | Tutup semua posisi yang sedang floating loss    |

---

## 🖥️ Panel Layout

```
┌────────────────────────────────┐
│  M4DI~UciH4                    │  ← Drag area (geser panel)
│  ULTRA BUTTON PANEL • MT5      │
│  github.com/RizkyEvory • v2.01 │
├────────────────────────────────┤
│  XAUUSD  Spread: 1.8  ⚠ WARN  │  ← Symbol info
│  L: -2.40          S: -1.80   │
├─────────────────┬──────────────┤
│   ▲  BUY        │  ▼  SELL    │  ← One-click order
│   2341.85       │  2341.67    │
├────────────────────────────────┤
│  Lot: [−] 0.10 [+]  [AUTO]   │  ← Lot & Risk
│  SL:  [−] 500  [+]            │
│  Risk: 1.0%   Risk: $12.50    │
├────────────────────────────────┤
│  ━━━━ TP LEVELS ━━━━           │  ← Multi-TP
│  [☑ TP1]  300 pts | 50%       │
│  [☑ TP2]  600 pts | 30%       │
│  [☑ TP3] 1000 pts | 20%       │
├────────────────────────────────┤
│  ━━━ MANAGEMENT ━━━            │  ← BE & Trailing
│  [BREAK EVEN]  [TRAIL: OFF]   │
├────────────────────────────────┤
│  ━━━ PARTIAL CLOSE ━━━         │  ← Partial close
│  [  25%  ] [  50%  ] [  75%  ]│
├────────────────────────────────┤
│  [      CLOSE ALL            ] │  ← Close buttons
│  [ CLOSE BUY ] [ CLOSE SELL ] │
│  [  ✓ PROFIT ] [   ✗ LOSS   ] │
├────────────────────────────────┤
│  ━━━ SESSIONS ━━━              │  ← Session filter
│  [ ASIA ] [LONDON] [ N.YORK ] │
├────────────────────────────────┤
│  ━━━ DAILY STATS ━━━           │  ← Daily tracker
│  Daily P/L: +$47.30            │
│  Floating:  +$12.50            │
│  Open: 2 | Lots: 0.20          │
│  Win Rate: 68% (15/22)         │
├────────────────────────────────┤
│  M4DI~UciH4 © Keys: B/S/Q/E/T │  ← Footer
└────────────────────────────────┘
```

---

## 📥 Installation

### Method 1 — Manual
```
1. Download file M4DI_UciH4_Panel_v2_Fixed.mq5
2. Buka MetaTrader 5
3. Klik menu: File → Open Data Folder
4. Navigasi ke: MQL5 → Experts
5. Copy file .mq5 ke folder tersebut
6. Buka MetaEditor (F4 di MT5)
7. Buka file → Compile (F7)
8. Kembali ke MT5 → Navigator → Expert Advisors
9. Drag ke chart yang diinginkan
```

### Method 2 — MetaEditor
```
1. Buka MetaEditor (F4)
2. File → Open → pilih M4DI_UciH4_Panel_v2_Fixed.mq5
3. Tekan F7 untuk compile
4. Pastikan: 0 errors, 0 warnings
5. Drag dari Navigator ke chart
```

### ⚠️ Pastikan
- ✅ **AutoTrading** diaktifkan di MT5 (tombol hijau di toolbar)
- ✅ **Allow algo trading** dicentang di properties EA
- ✅ Chart tidak dalam mode offline

---

## ⚙️ Configuration

### 📌 Panel Settings

| Parameter | Default | Keterangan |
|-----------|---------|------------|
| `InpPanelX` | 20 | Posisi horizontal panel |
| `InpPanelY` | 50 | Posisi vertikal panel |
| `InpPanelDraggable` | true | Panel bisa di-drag dengan mouse |
| `InpPanelCorner` | TOP_LEFT | Anchor corner panel |

### 💰 Money Management

| Parameter | Default | Keterangan |
|-----------|---------|------------|
| `InpDefaultLot` | 0.01 | Lot awal saat panel dibuka |
| `InpRiskPercent` | 1.0% | Risk per trade dari balance |
| `InpDefaultSL` | 500 pts | Stop loss default |
| `InpMaxSpread` | 30 pts | Spread maksimal untuk trading |
| `InpSlippage` | 30 pts | Toleransi slippage eksekusi |
| `InpMagicNumber` | 20240301 | Identifikasi order EA |

### 🎯 TP Levels

| Parameter | Default | Keterangan |
|-----------|---------|------------|
| `InpTP1_Enabled` | true | Aktifkan TP1 |
| `InpTP1_Points` | 300 pts | Jarak TP1 dari entry |
| `InpTP1_Percent` | 50% | Persentase close di TP1 |
| `InpTP2_Enabled` | true | Aktifkan TP2 |
| `InpTP2_Points` | 600 pts | Jarak TP2 dari entry |
| `InpTP2_Percent` | 30% | Persentase close di TP2 |
| `InpTP3_Enabled` | true | Aktifkan TP3 |
| `InpTP3_Points` | 1000 pts | Jarak TP3 dari entry |
| `InpTP3_Percent` | 20% | Persentase close di TP3 |
| `InpMoveSLToBE_OnTP1` | true | Auto BE setelah TP1 hit |

### 🔄 Break Even & Trailing

| Parameter | Default | Keterangan |
|-----------|---------|------------|
| `InpBE_Offset` | 10 pts | Offset SL dari entry saat BE |
| `InpTrailingStart` | 200 pts | Profit minimum sebelum trailing aktif |
| `InpTrailingStep` | 100 pts | Minimum pergerakan harga untuk update SL |
| `InpTrailingDistance` | 150 pts | Jarak SL dari harga saat trailing |

### ⏰ Session Settings

| Parameter | Default | Keterangan |
|-----------|---------|------------|
| `InpGMT_Offset` | 3 | GMT offset server broker |
| `InpBlockOutsideSession` | false | Block order di luar session |
| `InpShowSessionFilter` | true | Tampilkan session indicator |

> **💡 Tip:** Cek GMT offset broker kamu di: Terminal → Market Watch → klik kanan → Symbols → Properties. Sesuaikan `InpGMT_Offset` agar session indicator akurat.

### 📊 Display Options

| Parameter | Default | Keterangan |
|-----------|---------|------------|
| `InpShowDailyStats` | true | Tampilkan daily statistics |
| `InpShowChartLines` | true | Tampilkan SL/TP lines di chart |
| `InpShowSpreadWarning` | true | Tampilkan warning spread tinggi |
| `InpEnableSounds` | true | Aktifkan sound alerts |
| `InpConfirmTrades` | false | Konfirmasi sebelum eksekusi order |

---

## ⌨️ Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `B` | Execute BUY order |
| `S` | Execute SELL order |
| `Q` | Close ALL positions |
| `E` | Apply Break Even ke semua posisi |
| `T` | Toggle Trailing Stop ON/OFF |

> **💡 Tip:** Pastikan fokus ada di chart window sebelum menggunakan keyboard shortcuts.

---

## 📈 Supported Markets

Panel ini kompatibel dengan semua instrumen di MT5 berkat formula risk calculator universal:

| Market | Contoh | Kompatibilitas |
|--------|--------|----------------|
| Forex Major | EURUSD, GBPUSD, USDJPY | ✅ Full |
| Forex Minor | EURGBP, AUDCAD, NZDCHF | ✅ Full |
| Forex Exotic | USDMXN, USDZAR | ✅ Full |
| Gold | XAUUSD | ✅ Full |
| Silver | XAGUSD | ✅ Full |
| Indices | US30, NAS100, SPX500 | ✅ Full |
| Crypto | BTCUSD, ETHUSD | ✅ Full |
| Energi | USOIL, UKOIL | ✅ Full |

---

## 🏗️ Technical Architecture

```
M4DI_UciH4_Panel_v2_Fixed.mq5
│
├── OnInit()              — Inisialisasi, build panel, load stats
├── OnDeinit()            — Cleanup objects, save stats
├── OnTick()              — Update harga, trailing, TP check
├── OnTimer()             — Refresh panel, session update (200ms)
├── OnChartEvent()        — Button clicks, drag, keyboard
├── OnTradeTransaction()  — Auto-update stats saat SL/TP hit
│
├── TRADING CORE
│   ├── ExecuteBuy/Sell()      — Order execution
│   ├── CanTrade()             — Pre-trade validation
│   ├── NormalizeLot()         — Lot normalization
│   ├── AutoCalculateLot()     — Risk-based lot calculator
│   ├── ProcessTrailing()      — Trailing stop logic
│   ├── CheckTPLevels()        — Multi-TP monitoring
│   └── GetFillingMode()       — Auto broker filling mode
│
├── PANEL UI
│   ├── CreatePanel()          — Build all UI objects
│   ├── RefreshPanel()         — Update all displays
│   ├── MoveAllObjects()       — Efficient drag (delta move)
│   └── Create*/Update*()      — Individual component handlers
│
└── DATA & STATS
    ├── LoadDailyStats()       — Load dari GlobalVariable
    ├── SaveDailyStats()       — Save ke GlobalVariable
    ├── RebuildTPTracker()     — Restore tracker setelah restart
    └── CheckNewDay()          — Auto-reset stats harian
```

**Dependencies (MT5 Standard Library):**
```cpp
#include <Trade\Trade.mqh>         // CTrade — order execution
#include <Trade\PositionInfo.mqh>  // CPositionInfo — position monitoring
#include <Trade\SymbolInfo.mqh>    // CSymbolInfo — symbol data
#include <Trade\AccountInfo.mqh>   // CAccountInfo — account data
#include <Trade\DealInfo.mqh>      // CDealInfo — deal history
```

---

## ⚠️ Risk Warning

> **PERINGATAN PENTING**
>
> Trading forex, emas, indices, dan cryptocurrency mengandung **risiko kerugian yang sangat tinggi** dan tidak cocok untuk semua investor. Nilai investasi dapat turun maupun naik. Anda mungkin kehilangan sebagian atau seluruh modal yang diinvestasikan.
>
> - Past performance **tidak menjamin** hasil di masa depan
> - Gunakan panel ini hanya jika kamu memahami risiko trading
> - Selalu test di **demo account** sebelum live trading
> - Atur risk per trade sesuai kemampuan keuangan kamu
> - Developer **tidak bertanggung jawab** atas kerugian trading

---

## 📋 Changelog

### v2.01 — Bug Fix Release
- 🔴 **FIX:** Hapus `Sleep()` dari `OnChartEvent()` — mencegah thread blocking
- 🔴 **FIX:** Drag panel pakai delta movement — tidak lag saat drag
- 🔴 **FIX:** TP2/TP3 tidak bergantung mutlak pada TP sebelumnya
- 🔴 **FIX:** `NormalizeLot()` menggunakan dynamic decimal precision
- 🔴 **FIX:** Risk calculator formula universal (Forex, Gold, Indices, Crypto)
- 🟡 **FIX:** Spread check tidak bergantung `InpShowSpreadWarning`
- 🟡 **FIX:** `RebuildTPTracker()` — restore TP tracker setelah EA restart
- 🟡 **FIX:** Cooldown 2 detik anti double-click order
- 🟡 **ADD:** `OnTradeTransaction()` — auto-update daily stats saat SL/TP hit

### v2.00 — Major Release
- ✨ One-Click Buy/Sell dengan harga realtime di tombol
- ✨ Smart Risk Calculator universal
- ✨ Multi-TP Levels (TP1/TP2/TP3) dengan partial auto-close
- ✨ Trailing Stop & Break Even
- ✨ Partial Close 25/50/75%
- ✨ Session Filter Visual (Asia/London/NY)
- ✨ Daily PnL Tracker dengan GlobalVariable persistence
- ✨ Spread & Swap Monitor
- ✨ Keyboard Shortcuts B/S/Q/E/T
- ✨ Chart lines SL/TP/BE/Entry per posisi
- ✨ GetFillingMode() auto-detect FOK/IOC/RETURN

---

## 👤 Author

<div align="center">

**M4DI~UciH4**

[![GitHub](https://img.shields.io/badge/GitHub-RizkyEvory-181717?style=for-the-badge&logo=github)](https://github.com/RizkyEvory)

*"Trade smart. Manage risk. Stay consistent."*

---

Jika project ini bermanfaat, kasih ⭐ di repo ini ya!

**© 2024 M4DI~UciH4 — All Rights Reserved**

</div>
