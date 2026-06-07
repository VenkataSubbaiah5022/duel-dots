# DuelDots — Play Store Deployment Guide

## Before You Upload

### 1. App name fixed
- Android launcher name: **DuelDots**
- Package ID: `com.dueldots.duel_dots`
- Version: `1.0.0` (build `1`)

### 2. Release keystore (IMPORTANT)
Your upload keystore is at `android/upload-keystore.jks`.
**Back this up securely.** If you lose it, you cannot update the app on Play Store.

Passwords are in `android/key.properties` (not committed to git).

### 3. Add RELEASE SHA-1 to Firebase
After building release, run:
```powershell
cd android
.\gradlew signingReport
```
Copy the **release** SHA-1 fingerprint and add it in:
[Firebase Console → Project Settings → Android app → Add fingerprint](https://console.firebase.google.com/project/dueldots-3f969/settings/general)

### 4. Privacy policy URL (required)
Host `docs/privacy-policy.html` online. Options:
- GitHub Pages (free)
- Google Sites (free)
- Your own website

You need a public URL like: `https://yoursite.com/privacy-policy.html`

---

## Build Release AAB

```powershell
cd E:\projects\duel_dots
flutter clean
flutter pub get
flutter build appbundle --release
```

Output file:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## Play Console Steps

1. Go to [Google Play Console](https://play.google.com/console)
2. **Create app**
   - App name: **DuelDots**
   - Default language: English
   - App or game: **Game**
   - Free or paid: **Free**

3. **Dashboard → Complete all required tasks:**

### Store listing
| Field | Value |
|-------|-------|
| Short description | Real-time multiplayer board game. Challenge friends or play vs bot! |
| Full description | DuelDots is a fast, fun 2-player strategy game. Claim dots on a 5×5 grid, capture enemy dots, and win! Play with friends using room codes, or practice against the bot. Features: multiplayer rooms, bot mode, leaderboard, and player stats. |
| App icon | 512×512 PNG (use `assets/icon/app_icon.png` resized) |
| Feature graphic | 1024×500 PNG (create one for store banner) |
| Screenshots | Min 2 phone screenshots (Home, Game, Result) |

### Privacy policy
- Paste your hosted privacy policy URL

### App content
- **Privacy policy**: URL required
- **Ads**: No, DuelDots does not contain ads
- **Content rating**: Complete questionnaire → likely **Everyone**
- **Target audience**: Not designed for children under 13 (or select appropriate age)
- **Data safety**:
  - Collects: User IDs (anonymous), app activity, crash logs
  - Purpose: App functionality, analytics
  - Encrypted in transit: Yes
  - Users can request deletion: Yes

### Release
1. **Production** → **Create new release**
2. Upload `app-release.aab`
3. Release name: `1.0.0 - Initial release`
4. Release notes: `First release — multiplayer, bot mode, leaderboard`
5. **Review and roll out**

---

## Approval Timeline

| Type | Typical time |
|------|-------------|
| First app (new developer) | **3–7 days** |
| App updates later | **Hours to 3 days** |

---

## Checklist

- [ ] Keystore backed up (`upload-keystore.jks` + passwords)
- [ ] Release SHA-1 added to Firebase
- [ ] Privacy policy hosted with public URL
- [ ] `flutter build appbundle --release` succeeds
- [ ] Screenshots ready (min 2)
- [ ] Feature graphic ready (1024×500)
- [ ] Data safety form completed
- [ ] Content rating completed
- [ ] AAB uploaded to Production
