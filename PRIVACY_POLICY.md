# Privacy Policy — Mini60 Antenna Analyzer

**Last updated:** 2026-05-04
**Developer:** DL1KVN
**Contact:** dvn@almoe.de

This privacy policy describes how the **Mini60 Antenna Analyzer** Android app ("the App") handles information.

## Summary

The App **does not collect, transmit, or share any personal data**. All data stays on your device.

## What the App does

The App is a companion tool for the Mini60 / SARK-100 family of HF antenna analyzers. It connects to the analyzer over Bluetooth, performs frequency sweeps, and displays SWR/impedance results.

## Data the App stores locally

The App stores the following on your device only, using Android's `SharedPreferences` and local app storage:

- Frequency-range presets ("bands") that you create
- Last-used start/end frequencies
- Steps-per-scan setting
- Scan results during a session

This data never leaves your device. There is no backend server, no analytics SDK, and no advertising SDK.

## Permissions the App requests

- **Bluetooth (Scan / Connect)** — required to discover and communicate with the Mini60 / SARK-100 hardware over Bluetooth Classic. The App declares the `neverForLocation` flag, meaning Bluetooth scanning is **not** used to derive your location.
- **Location (Android 6–11 only, API ≤ 30)** — older Android versions require location permission to allow Bluetooth scanning. The App does not read, store, or transmit location data. This permission is not requested on Android 12 or newer.

## Data sharing

None. The App makes no network requests and does not contact any server operated by the developer or any third party.

## Children

The App is not directed at children. It contains no advertising or in-app purchases.

## Changes

If this policy changes, the updated version will be published at the same URL. Material changes will be announced in the App's release notes on Google Play.

## Contact

Questions about this policy can be sent to **dvn@almoe.de**.
