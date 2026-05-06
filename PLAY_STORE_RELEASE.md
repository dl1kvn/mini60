# Play Store Release — Handoff Notes

**App:** Mini60 Antenna Analyzer
**Application ID:** `de.dl1kvn.mini60`
**Version:** `1.0.0+1` (versionCode 1, versionName 1.0.0)
**Status as of 2026-05-04:** waiting for Google Play Console developer-account verification. Release artifact built and signed, ready to upload as soon as the account is approved.

---

## What is already done

### Code / project
- App rebranded from `com.example.mini60` → `de.dl1kvn.mini60`
  - `android/app/build.gradle.kts` (`namespace`, `applicationId`)
  - Kotlin source moved to `android/app/src/main/kotlin/de/dl1kvn/mini60/MainActivity.kt`
- App label set to **Mini60 Antenna Analyzer** in `AndroidManifest.xml`
- App icon generated from `assets/images/antenna_icon.png` via `flutter_launcher_icons` for all platforms
- Splash-screen animation removed (`HomePage` is now the direct `home:`)
- ChatGPT/OpenAI integration completely removed (no network calls anywhere)
- Unused `INTERNET` permission removed from manifest
- Bluetooth permissions cleaned up:
  - `BLUETOOTH_SCAN` with `neverForLocation` flag (no location data-safety disclosure needed)
  - `ACCESS_FINE_LOCATION` constrained to `maxSdkVersion="30"` (Android 6–11 only)
- Kotlin Gradle Plugin bumped from `1.8.22` → `2.1.0` in `android/settings.gradle.kts`
- About page (`lib/pages/about_page.dart`) reachable from the home AppBar info icon. Contains author (DL1KVN), no-warranty disclaimer, third-party note, contact email.

### Signing
- Upload keystore created at `android/app/upload-keystore.jks` (alias `upload`)
- `android/key.properties` exists with the credentials
- Both files are gitignored (`.gitignore` updated)
- `android/app/build.gradle.kts` reads `key.properties` and signs `release` with the upload key, falls back to debug keys if the file is missing (so `flutter run` still works on a clean checkout)
- **Backup status:** ⚠️ confirm the `.jks` + passwords are saved offline. Losing them = no more updates ever for this app id.

### Release artifact
- Built with: `flutter build appbundle --release`
- Output: `build/app/outputs/bundle/release/app-release.aab` (57.0 MB)
- Signed entry verified: `META-INF/UPLOAD.RSA` present (signed with upload key, not debug)

### Privacy policy
- `PRIVACY_POLICY.md` in repo root, ready to host
- Contact email: `dvn@almoe.de`
- Declares: no data collected, no data shared, BT permission is hardware access only

---

## What still needs to happen — pick up here when Play Console is approved

### 1. Host the privacy policy (required before submission)
The Play Console asks for a public URL. Easiest option:
1. Push this repo to GitHub
2. Repo Settings → Pages → Source: `main` branch, root folder
3. The URL becomes `https://<your-gh-user>.github.io/<repo-name>/PRIVACY_POLICY`
4. Confirm it loads in an incognito window before pasting into the console

Alternative: any static host (Cloudflare Pages, Netlify, your own webspace).

### 2. Prepare the listing assets
Required by Google Play:
- [ ] **App icon** 512×512 PNG (resized from `assets/images/antenna_icon.png`)
- [ ] **Feature graphic** 1024×500 PNG (banner shown at top of listing)
- [ ] **Phone screenshots** ≥2, max 8, between 320 and 3840 px per side, 16:9 or 9:16
  - Suggested: home screen, scan in progress (chart tab), scan results list, About page
- [ ] **Short description** ≤80 chars, suggestion:
  > Companion app for the Mini60 / SARK-100 HF antenna analyzer over Bluetooth.
- [ ] **Full description** ≤4000 chars, draft below

#### Suggested full description (paste & edit):
```
Mini60 Antenna Analyzer is a companion app for the Mini60 / SARK-100 family
of HF antenna analyzers. Connect your analyzer over Bluetooth and run
frequency sweeps directly from your Android device.

Features
• Bluetooth Classic connection to Mini60 / SARK-100 hardware
• Configurable frequency sweeps (1–60 MHz)
• SWR / R / X / Z chart for each scan
• Customisable band presets (160 m, 80 m, 40 m, 20 m, …) — drag-and-drop reorder
• Built-in reference of common antenna types
• Adjustable measurement-point density per scan
• 100 % offline — no account, no telemetry, no ads

Privacy
The app collects no personal data and makes no network requests. All settings
and scan results stay on your device.

Bluetooth permission is used only to communicate with the analyzer hardware.
On Android 12 and newer, scanning is declared with neverForLocation, so the
app does not derive your location from Bluetooth.

Made by DL1KVN. This is a third-party app, not affiliated with or endorsed by
the manufacturer of the Mini60 / SARK-100. Use at your own risk.
```

### 3. Play Console — work through every gated item
Order on the left sidebar (each blocks the next until green):

1. **App content**
   - Privacy policy → paste hosted URL
   - App access → "All functionality available without restrictions"
   - Ads → "No, my app does not contain ads"
   - Content rating → fill questionnaire (utility, no objectionable content → expect "Everyone")
   - Target audience → 13+ or 18+
   - News app → No
   - COVID-19 contact tracing → No
   - **Data safety** → declare *No data collected* + *No data shared*. Note: Bluetooth permission is hardware access, NOT data collection.
   - Government app → No
   - Financial features → No
   - Health → No

2. **Main store listing**
   - Title: `Mini60 Antenna Analyzer`
   - Short + full description (above)
   - Upload icon, feature graphic, screenshots
   - Category: **Tools** (alternative: Communication)
   - Tags: amateur radio, HF, antenna, SWR

3. **Production → Create new release**
   - Enable **Google Play App Signing** (recommended — Play stores the actual app-signing key; you only ever manage the upload key, which is exactly the setup `upload-keystore.jks` was made for)
   - Upload `build/app/outputs/bundle/release/app-release.aab`
   - Release name: `1.0.0`
   - Release notes: `Initial release.`
   - Save → Review → **Send for review**

First review: usually a few hours to a few days. After approval the app goes live on the configured rollout (start with 100 % since it's v1).

### 4. Subsequent updates — quick recipe
Whenever you ship an update:

```powershell
# 1. Bump version in pubspec.yaml — both parts must increase
#    e.g. 1.0.0+1  →  1.0.1+2     (versionName+versionCode)

# 2. Build new bundle
flutter build appbundle --release

# 3. In Play Console: Production → Create new release → upload the new .aab
#    Add release notes, send for review.
```

The upload keystore stays the same forever. **Never regenerate it.**

---

## File map for next session

| Path | Purpose |
| --- | --- |
| `pubspec.yaml` line 19 | `version:` — bump on each release |
| `android/app/build.gradle.kts` | applicationId, signing config |
| `android/app/upload-keystore.jks` | upload key (gitignored, BACK UP OFFLINE) |
| `android/key.properties` | keystore passwords (gitignored) |
| `android/key.properties.example` | template for fresh checkouts |
| `android/app/src/main/AndroidManifest.xml` | label, permissions |
| `assets/images/antenna_icon.png` | source for the launcher icon |
| `lib/pages/about_page.dart` | About page shown on Play listing's source-of-truth |
| `PRIVACY_POLICY.md` | privacy policy — must be hosted publicly |
| `build/app/outputs/bundle/release/app-release.aab` | the file uploaded to Play Console |

---

## Open questions to resolve before submission

- [ ] GitHub username / privacy-policy URL decided?
- [ ] Screenshots taken on a real device or emulator (≥2)?
- [ ] Feature graphic designed (1024×500)?
- [ ] Keystore + passwords backed up offline?

When the Play Console account is approved, ping me with the answers above and I'll regenerate the `.aab` if anything in `pubspec.yaml`/manifest needs a final tweak before upload.
