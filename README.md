# News Event Calendar — MQL4 Script

A MetaTrader 4 script that reads **upcoming economic calendar events** from a semicolon-delimited CSV file via `FileOpen(FILE_CSV | FILE_READ)`, parses each row into event time, impact level, and event description fields, fires proximity alerts when a high-impact event is within `AlertMinutesBefore` minutes of the current server time, and optionally closes all open positions before the event fires via a `CloseAllPositions()` reverse-index `OrderClose()` loop — providing automated pre-news risk management driven by an externally maintained calendar file.

---

## Overview

Economic news events — Non-Farm Payrolls, central bank rate decisions, CPI releases, GDP figures — are among the highest-volatility, highest-risk moments in financial markets. Spreads widen dramatically in the seconds before and after high-impact releases, stop hunts are common, and slippage can be severe. Many institutional and professional traders flatten all positions before major news events and re-enter after the initial volatility spike subsides. This script automates that workflow: it reads a pre-populated event calendar CSV, continuously checks the time distance to each upcoming high-impact event, and when the countdown reaches the configured `AlertMinutesBefore` threshold, fires an alert and optionally closes all open positions. The event file is maintained externally — updated daily or weekly with the upcoming economic calendar — keeping the script's execution logic decoupled from the data source. This makes the script compatible with any calendar feed that can export to CSV format.

---

## Features

- **CSV calendar file parsing** — `FileOpen(FileName, FILE_CSV | FILE_READ, ";")` reads three fields per row: `timeStr` (event time string), `impact` (impact level label), `event` (event description) via sequential `FileReadString()` calls
- **`StringToTime()` time conversion** — `eventTime = StringToTime(timeStr)` converts the calendar's time string to MT4's `datetime` type for direct comparison against `TimeCurrent()`
- **Past-event skip guard** — `if (eventTime <= now) continue` skips any events whose time has already passed, preventing false alerts on historical rows
- **`StringFind(impact, "High") >= 0` impact filter** — only rows containing `"High"` in the impact field are evaluated for proximity alerts when `AlertHighImpact = true`; all events logged to Experts tab regardless
- **`AlertMinutesBefore` proximity gate** — `minutesToEvent = (int)(eventTime − now) / 60`; fires when `minutesToEvent <= AlertMinutesBefore` — configurable default 30 minutes
- **`ClosePositions = true` auto-close** — triggers `CloseAllPositions()` which iterates `OrdersTotal() − 1` to `0` in reverse, calling `OrderClose(OrderTicket(), OrderLots(), closePrice, 3, clrRed)` with Bid/Ask direction awareness; logs success and failure per order
- **File handle cleanup** — `FileClose(handle)` called unconditionally on script completion
- Full event log including time, impact, name, and countdown printed to the MT4 **Experts** tab for every row

---

## How It Works

1. `FileOpen(FileName, FILE_CSV | FILE_READ, ";")` opens the calendar; aborts on `handle < 0`
2. `now = TimeCurrent()` fetched; `while (!FileIsEnding(handle))` iterates each row
3. Each row: parse `timeStr`, `impact`, `event`; convert `timeStr → datetime`; skip if `eventTime <= now`
4. Log upcoming event; if `AlertHighImpact && StringFind(impact, "High") >= 0` and `minutesToEvent <= AlertMinutesBefore`: fire `Alert()` and optionally `CloseAllPositions()`
5. `FileClose(handle)` on completion

---

## Calendar File Format

Semicolon-delimited CSV in the MT4 Files sandbox, one event per row:

```
2026.05.27 13:30;High;US Non-Farm Payrolls
2026.05.27 15:00;Medium;US ISM Manufacturing PMI
2026.05.28 12:00;High;ECB Rate Decision
```

Fields: `DateTime (YYYY.MM.DD HH:MM) ; ImpactLevel ; EventDescription`

> File path: `%APPDATA%\MetaQuotes\Terminal\<TerminalID>\MQL4\Files\news.csv`

---

## Input Parameters

| Parameter             | Type   | Default          | Description                                                          |
|-----------------------|--------|------------------|----------------------------------------------------------------------|
| `FileName`            | string | `news.csv`       | Calendar CSV filename in the MT4 Files sandbox                       |
| `AlertHighImpact`     | bool   | `true`           | Only fire alerts for rows containing `"High"` in the impact field    |
| `ClosePositions`      | bool   | `false`          | Automatically close all open positions when a proximity alert fires  |
| `AlertMinutesBefore`  | int    | `30`             | Minutes before event at which the proximity alert fires              |

---

## ⚠️ Important Notes

- Set `ClosePositions = true` with extreme caution — it will close **all** open positions on the account when a high-impact event is within `AlertMinutesBefore` minutes.
- Always test on a **demo account** with your actual calendar file before deploying on live capital.
- The calendar CSV must be updated regularly with current event data. The script does not fetch events from the internet — it reads only from the local file.

---

## Installation

1. Copy `News_Event_Calender_001.mq4` to `MQL4/Scripts/` in your MT4 data folder
2. Compile in MetaEditor (F7)
3. Place your calendar CSV in the MT4 Files sandbox
4. Drag onto any chart from Navigator → Scripts; configure inputs and click **OK**

---

## Requirements

- MetaTrader 4 (`#property strict` compatible build)
- MQL4 compiler (MetaEditor)
- Calendar CSV file present in MT4 Files sandbox before script execution

---

## License

MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
