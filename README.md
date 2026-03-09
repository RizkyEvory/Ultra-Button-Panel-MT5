<div align="center">

# 🎯 M4DI~UciH4 ULTRA BUTTON PANEL v3.02

### Premium Semi-Manual Trading Panel for MetaTrader 5

[![MQL5](https://img.shields.io/badge/MQL5-Expert%20Advisor-blue?style=for-the-badge&logo=metatrader5)](https://www.mql5.com/)
[![Version](https://img.shields.io/badge/Version-3.02-green?style=for-the-badge)](https://github.com/RizkyEvory/M4DI-UciH4-Panel)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-MT5-orange?style=for-the-badge)](https://www.metatrader5.com/)

<p align="center">
  <img src="https://img.shields.io/badge/One--Click%20Trading-✓-brightgreen?style=flat-square" alt="One-Click Trading"/>
  <img src="https://img.shields.io/badge/Pending%20Orders-✓-brightgreen?style=flat-square" alt="Pending Orders"/>
  <img src="https://img.shields.io/badge/Martingale%20%2F%20Grid-✓-brightgreen?style=flat-square" alt="Martingale/Grid"/>
  <img src="https://img.shields.io/badge/Auto%20Close-✓-brightgreen?style=flat-square" alt="Auto Close"/>
  <img src="https://img.shields.io/badge/Multi--TP-✓-brightgreen?style=flat-square" alt="Multi-TP"/>
</p>

---

**Panel trading semi-manual all-in-one untuk MT5 dengan fitur lengkap:**  
*One-Click Trading, Pending Orders, Martingale/Grid, Auto Close Profit/Loss,*  
*Flip/Reverse Position, Multi-TP Partial Close, Trailing Stop, Break Even, dan banyak lagi!*

[📥 Download](#-instalasi) • [📖 Dokumentasi](#-fitur-utama) • [🐛 Report Bug](https://github.com/RizkyEvory/M4DI-UciH4-Panel/issues) • [💡 Request Feature](https://github.com/RizkyEvory/M4DI-UciH4-Panel/issues)

</div>

---

## 📸 Screenshot

<div align="center">

| Panel Utama | Trading View |
|:-----------:|:------------:|
| ![Panel](screenshots/panel-main.png) | ![Trading](screenshots/trading-view.png) |

</div>

> 📌 *Screenshot akan ditambahkan setelah testing*

---

## ✨ Fitur Utama

### 🎯 One-Click Trading
- Tombol **BUY** dan **SELL** dengan tampilan harga real-time
- Spread indicator dengan warning jika spread tinggi
- Session filter (Asia, London, New York)

### 📋 Pending Orders
- **Buy Limit** - Pasang order beli di bawah harga saat ini
- **Buy Stop** - Pasang order beli di atas harga saat ini (breakout)
- **Sell Limit** - Pasang order jual di atas harga saat ini
- **Sell Stop** - Pasang order jual di bawah harga saat ini (breakout)
- Adjustable distance dari harga saat ini
- Cancel all pending dengan satu klik

### 🔢 Martingale & Grid Mode
| Mode | Deskripsi |
|------|-----------|
| **Martingale** | Lot otomatis dikali setiap posisi baru (Lot Multiplier) |
| **Grid** | Buka posisi baru setiap X points melawan arah (Grid Step) |

### 💵 Auto Close
- **Auto Close Profit** - Tutup semua posisi saat floating profit mencapai target ($)
- **Auto Close Loss** - Tutup semua posisi saat floating loss mencapai batas ($)

### 🔄 Flip / Reverse Position
- Tutup semua posisi dan langsung buka posisi **berlawanan**
- Lot posisi baru = total lot posisi dominan sebelumnya
- Hotkey: **F**

### 🎯 Multi-TP (Partial Close)
| Level | Default Distance | Default Close % |
|-------|------------------|-----------------|
| TP1 | 300 points | 50% |
| TP2 | 600 points | 30% |
| TP3 | 1000 points | 20% |

- Opsi pindahkan SL ke Break Even setelah TP1 hit

### 🔒 Break Even & Trailing Stop
- **Manual Break Even** - Klik tombol untuk pindahkan SL ke entry + offset
- **Auto Break Even** - Otomatis aktif saat profit mencapai X points
- **Auto Trailing** - Trailing stop otomatis mengikuti harga
- Configurable: Start, Step, dan Distance

### 📊 Daily Statistics
- Real-time floating P/L
- Daily realized P/L
- Win rate percentage
- Total trades & lots

### ⌨️ Hotkeys
| Key | Fungsi |
|-----|--------|
| **B** | Buy |
| **S** | Sell |
| **Q** | Close All Positions |
| **E** | Break Even |
| **T** | Toggle Trailing |
| **F** | Flip/Reverse Position |
| **G** | Toggle Grid Mode |

---

## 📥 Instalasi

### Metode 1: Manual Installation

1. **Download** file `M4DI_UciH4_Panel_v3.mq5`

2. **Buka** MetaTrader 5

3. **Copy** file ke folder Experts:
   ```
   File → Open Data Folder → MQL5 → Experts
   ```

4. **Compile** file:
   - Buka MetaEditor (F4)
   - Buka file `M4DI_UciH4_Panel_v3.mq5`
   - Tekan **F7** atau klik Compile

5. **Attach** ke chart:
   - Kembali ke MT5
   - Navigator → Expert Advisors → M4DI_UciH4_Panel_v3
   - Drag & drop ke chart

6. **Enable** Auto Trading:
   - Pastikan tombol "Algo Trading" di toolbar aktif (hijau)
   - Di properties EA, centang "Allow Algo Trading"

### Metode 2: Clone Repository

```bash
git clone https://github.com/RizkyEvory/M4DI-UciH4-Panel.git
```

Lalu copy folder ke `MQL5/Experts/`

---

## ⚙️ Parameter Settings

### 📌 Panel Settings
| Parameter | Default | Deskripsi |
|-----------|---------|-----------|
| `InpPanelX` | 20 | Posisi X panel |
| `InpPanelY` | 50 | Posisi Y panel |
| `InpPanelDraggable` | true | Panel bisa di-drag |
| `InpPanelCorner` | CORNER_LEFT_UPPER | Posisi corner panel |

### 💰 Money Management
| Parameter | Default | Deskripsi |
|-----------|---------|-----------|
| `InpDefaultLot` | 0.01 | Lot size default |
| `InpRiskPercent` | 1.0 | Risk per trade (%) |
| `InpDefaultSL` | 500 | Stop Loss default (points) |
| `InpMaxSpread` | 30 | Max spread allowed (points) |
| `InpSlippage` | 30 | Slippage tolerance (points) |
| `InpOrderCooldown` | 0 | Cooldown antar order (detik) |
| `InpMagicNumber` | 20240301 | Magic number EA |

### 📋 Pending Order
| Parameter | Default | Deskripsi |
|-----------|---------|-----------|
| `InpPendingDistance` | 200 | Jarak pending dari harga (points) |
| `InpPendingExpiry` | 0 | Expiry pending order (jam, 0=GTC) |

### 🔢 Martingale / Grid
| Parameter | Default | Deskripsi |
|-----------|---------|-----------|
| `InpMartingaleEnabled` | false | Enable Martingale Mode |
| `InpLotMultiplier` | 2.0 | Lot multiplier untuk Martingale |
| `InpMaxMartingaleLot` | 1.0 | Max lot untuk Martingale (safety) |
| `InpGridEnabled` | false | Enable Grid Mode |
| `InpGridStep` | 200 | Grid step (points) |
| `InpGridMaxLevels` | 5 | Max grid levels |
| `InpGridLotMultiplier` | 1.0 | Grid lot multiplier (1=fixed) |

### 💵 Auto Close
| Parameter | Default | Deskripsi |
|-----------|---------|-----------|
| `InpAutoCloseProfitOn` | false | Enable auto close by profit |
| `InpAutoCloseProfit` | 10.0 | Target floating profit ($) |
| `InpAutoCloseLossOn` | false | Enable auto close by loss |
| `InpAutoCloseLoss` | 20.0 | Max floating loss ($) |

### 🎯 TP Levels
| Parameter | Default | Deskripsi |
|-----------|---------|-----------|
| `InpTP1_Enabled` | true | Enable TP1 |
| `InpTP1_Points` | 300 | TP1 distance (points) |
| `InpTP1_Percent` | 50 | TP1 close percent |
| `InpTP2_Enabled` | true | Enable TP2 |
| `InpTP2_Points` | 600 | TP2 distance (points) |
| `InpTP2_Percent` | 30 | TP2 close percent |
| `InpTP3_Enabled` | true | Enable TP3 |
| `InpTP3_Points` | 1000 | TP3 distance (points) |
| `InpTP3_Percent` | 20 | TP3 close percent |
| `InpMoveSLToBE_OnTP1` | true | Move SL to BE after TP1 |

### 🔄 Break Even & Trailing
| Parameter | Default | Deskripsi |
|-----------|---------|-----------|
| `InpBE_Offset` | 10 | Break Even offset (points) |
| `InpAutoBreakEven` | true | Auto Break Even |
| `InpAutoBE_Points` | 200 | Auto BE aktif saat profit >= X points |
| `InpAutoTrailing` | true | Auto Trailing Stop |
| `InpTrailingStart` | 200 | Trailing mulai saat profit >= X points |
| `InpTrailingStep` | 100 | Trailing step (points) |
| `InpTrailingDistance` | 150 | Trailing distance dari harga (points) |

### ⏰ Session Settings
| Parameter | Default | Deskripsi |
|-----------|---------|-----------|
| `InpGMT_Offset` | 3 | Broker GMT Offset |
| `InpBlockOutsideSession` | false | Block trading di luar session |
| `InpShowSessionFilter` | true | Tampilkan session indicator |

### 📊 Display Options
| Parameter | Default | Deskripsi |
|-----------|---------|-----------|
| `InpShowDailyStats` | true | Tampilkan statistik harian |
| `InpShowChartLines` | true | Tampilkan garis SL/TP di chart |
| `InpShowSpreadWarning` | true | Tampilkan warning spread tinggi |
| `InpEnableSounds` | true | Enable sound alerts |
| `InpConfirmTrades` | false | Konfirmasi sebelum trading |

---

## 📖 Cara Penggunaan

### Basic Trading

1. **Set Lot Size** - Gunakan tombol **+/-** atau klik **AUTO** untuk hitung lot berdasarkan risk%

2. **Set Stop Loss** - Gunakan tombol **+/-** untuk atur SL dalam points

3. **Klik BUY atau SELL** - Eksekusi order langsung

### Pending Orders

1. Atur **Distance** menggunakan tombol +/-
2. Klik salah satu:
   - **BUY LIMIT** - Order beli di bawah harga
   - **BUY STOP** - Order beli di atas harga
   - **SELL LIMIT** - Order jual di atas harga
   - **SELL STOP** - Order jual di bawah harga

### Menggunakan Grid/Martingale

1. Klik **MARTIN** atau **GRID** untuk aktifkan
2. Buka posisi pertama (BUY/SELL)
3. Grid: EA akan otomatis buka posisi baru setiap GridStep points
4. Martingale: Lot akan dikali setiap posisi baru

### Flip Position

1. Pastikan ada posisi terbuka
2. Klik **🔄 FLIP** atau tekan **F**
3. Semua posisi akan ditutup dan posisi berlawanan dibuka

### Partial Close

- Klik **25%**, **50%**, atau **75%** untuk tutup sebagian dari semua posisi

---

## 🔧 Troubleshooting

### EA Tidak Bisa Trading

1. ✅ Pastikan **Algo Trading** enabled (tombol hijau di toolbar)
2. ✅ Cek tab **Experts** di terminal untuk error message
3. ✅ Pastikan symbol bisa ditrade (market buka)
4. ✅ Cek spread tidak melebihi `InpMaxSpread`

### Pending Order Gagal

1. ✅ Pastikan jarak dari harga memenuhi **minimum stop level** broker
2. ✅ Increase `InpPendingDistance` jika perlu

### Panel Tidak Muncul

1. ✅ Cek apakah EA sudah ter-compile (tidak ada error)
2. ✅ Restart MT5
3. ✅ Re-attach EA ke chart

### Partial Close Tidak Bekerja

1. ✅ Pastikan lot yang akan di-close >= minimum lot broker
2. ✅ Cek apakah posisi masih terbuka

---

## 📝 Changelog

### v3.02 (Current) - Major Bugfix
- ✅ Fix `ExecutePendingOrder` - Perbaikan signature OrderOpen()
- ✅ Fix `ProcessGrid` - Tambah margin check sebelum open
- ✅ Fix `OnFlipClick` - Tambah delay & anti-double flip
- ✅ Fix `CheckTPLevels` - Race condition pada partial close
- ✅ Fix `RebuildTPTracker` - Skip entry price 0
- ✅ Fix `GetMartingaleLot` - Proteksi overflow
- ✅ Tambah `CleanupOrphanedLines()` untuk bersihkan chart
- ✅ Tambah `SyncTPTracker()` untuk sinkronisasi

### v3.01 - Bugfix
- Fix harga stale setelah FLIP
- Fix g_lastGridPrice dari posisi terbaru
- Fix SL/TP gunakan harga fresh
- Tambah cooldown anti-spam auto close

### v3.00 - Major Update
- ✨ Pending Order (Limit & Stop)
- ✨ Martingale Mode
- ✨ Grid Mode
- ✨ Auto Close Profit/Loss
- ✨ Flip/Reverse Position
- ✨ Hotkeys (F, G, P)

### v2.00
- ✨ Multi-TP Partial Close
- ✨ Auto Trailing Stop
- ✨ Auto Break Even
- ✨ Daily Statistics

### v1.00
- 🎉 Initial Release
- One-Click Trading
- Basic Panel

---

## ⚠️ Disclaimer

```
PERINGATAN RISIKO TRADING

Trading forex dan CFD melibatkan risiko tinggi dan mungkin tidak cocok untuk 
semua investor. Tingkat leverage yang tinggi dapat bekerja melawan Anda 
maupun untuk Anda.

EA ini disediakan "SEBAGAIMANA ADANYA" tanpa jaminan apapun. Penulis TIDAK 
bertanggung jawab atas kerugian finansial yang diakibatkan oleh penggunaan EA ini.

- Selalu gunakan di akun DEMO terlebih dahulu
- Pahami sepenuhnya cara kerja setiap fitur sebelum live trading
- Gunakan money management yang proper
- Jangan pernah trade dengan uang yang tidak sanggup Anda rugikan

Dengan menggunakan EA ini, Anda menyetujui bahwa Anda memahami risiko yang 
terlibat dan menanggung tanggung jawab penuh atas keputusan trading Anda.
```

---

## 📄 License

```
MIT License

Copyright (c) 2024 M4DI~UciH4 (RizkyEvory)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🤝 Contributing

Kontribusi sangat diterima! Silakan:

1. **Fork** repository ini
2. **Create** branch fitur baru (`git checkout -b feature/AmazingFeature`)
3. **Commit** perubahan (`git commit -m 'Add some AmazingFeature'`)
4. **Push** ke branch (`git push origin feature/AmazingFeature`)
5. **Open** Pull Request

---

## 💖 Support

Jika EA ini membantu trading Anda, pertimbangkan untuk:

- ⭐ **Star** repository ini
- 🐛 **Report** bugs yang ditemukan
- 💡 **Suggest** fitur baru
- 📢 **Share** ke trader lain

---

## 📬 Contact

**M4DI~UciH4** - [@RizkyEvory](https://github.com/RizkyEvory)

Project Link: [https://github.com/RizkyEvory/M4DI-UciH4-Panel](https://github.com/RizkyEvory/M4DI-UciH4-Panel)

---

<div align="center">

### Made with ❤️ by M4DI~UciH4

**Happy Trading! 📈💰**

</div>