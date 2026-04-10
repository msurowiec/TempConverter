# TempConverter

A sleek, compact macOS temperature converter widget.

![macOS](https://img.shields.io/badge/macOS-14%2B-blue) ![Swift](https://img.shields.io/badge/Swift-6-orange)

## Features

- Convert between **Fahrenheit ↔ Celsius** instantly as you type
- **Fetch current local temperature** with one click — no location permission required
- Dark, minimal inline design that stays out of your way
- Compact bar window that sits neatly on your desktop

## Requirements

- macOS 14 or later
- Xcode 16 or later

## Setup

1. Clone the repo
2. Open `TempConverter/TempConverter.xcodeproj` in Xcode
3. In the target's **Build Settings**, set **Code Signing Entitlements** to `TempConverter/TempConverter.entitlements`
4. Set your own **Team** and **Bundle Identifier** under Signing & Capabilities
5. Run with **⌘R**

The app requires outgoing network access to fetch weather data from [Open-Meteo](https://open-meteo.com) and approximate location from [ipwho.is](https://ipwho.is).

## How it works

- Enter a temperature in the left field
- Tap **⇄** to swap conversion direction
- Tap the **location button** to auto-fill with the current temperature at your location (city-level accuracy via IP geolocation, no prompt required)

## Privacy

No data is stored or transmitted beyond what is needed to fetch the current temperature. Coarse location is derived from your IP address solely to retrieve local weather. See `PrivacyInfo.xcprivacy` for full details.

## License

MIT
