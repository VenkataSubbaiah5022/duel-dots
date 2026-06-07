# DuelDots — Play Console Copy-Paste Guide

Use this file while filling Play Console forms. Copy each block exactly.

---

## App identity (already created)

| Field | Value |
|-------|-------|
| App name | DuelDots - Online Board Game |
| Package name | `com.dueldots.duel_dots` |
| Type | Game |
| Price | Free |

---

## Privacy policy URL

**Enable GitHub Pages first** (see bottom), then use:

```
https://venkatasubbaiah5022.github.io/duel-dots/privacy-policy.html
```

---

## Store listing

### Short description (80 chars max)
```
Real-time multiplayer board game. Challenge friends or play vs bot!
```

### Full description
```
DuelDots is a fast, fun 2-player strategy board game on a 5×5 grid.

Claim dots, capture enemy dots, and win matches!

FEATURES
• Play with friends using room codes
• Play alone vs smart bot
• Real-time multiplayer gameplay
• Leaderboard and player stats
• Simple rules, deep strategy

HOW TO PLAY
Take turns placing dots on the grid. When you place a dot, enemy dots directly next to it flip to your color. When the board is full, the player with the most dots wins!

Perfect for quick matches with friends or practicing against the bot. No account needed — jump in and play instantly.

Download DuelDots and start your dot duel today!
```

### Graphics (upload from `store_assets/` folder)
| File | Use for |
|------|---------|
| `app_icon_512x512.png` | App icon (512×512) |
| `feature_graphic_1024x500.png` | Feature graphic |
| Phone screenshots | Take 2–4 from your device (Home, Game, Result) |

### Category
- **Game** → **Board**

### Contact email
```
venkatasubbaiah5022@gmail.com
```

---

## App access

Select: **All functionality is available without special access**

(Anonymous login — no username/password required)

---

## Ads

**No, my app does not contain ads**

---

## Content rating questionnaire

Start → Email: venkatasubbaiah5022@gmail.com → Category: **Game**

Typical answers for DuelDots:
| Question | Answer |
|----------|--------|
| Violence | No |
| Sexuality | No |
| Language | No |
| Controlled substances | No |
| Gambling | No |
| User interaction | Yes (multiplayer with other users) |
| Shares location | No |
| Shares personal info | No |
| Digital purchases | No |

Expected rating: **Everyone** or **PEGI 3**

---

## Target audience

- Target age: **13 and older** (or 18+ if unsure)
- **Not** designed primarily for children

---

## Data safety

### Does your app collect or share user data?
**Yes**

### Data types collected

| Data type | Collected | Shared | Purpose |
|-----------|-----------|--------|---------|
| User IDs | Yes | No | App functionality |
| App activity (gameplay) | Yes | No | App functionality |
| Crash logs | Yes | No | Analytics |

### Practices
- Data encrypted in transit: **Yes**
- Users can request data deletion: **Yes** (venkatasubbaiah5022@gmail.com)
- Data sold to third parties: **No**
- Committed to Play Families Policy: **No** (not a kids app)

### Third-party SDK
**Firebase** (Auth, Firestore, Analytics, Crashlytics)

---

## Upload AAB

**File path:**
```
E:\projects\duel_dots\build\app\outputs\bundle\release\app-release.aab
```

**Release name:** `1.0.0`  
**Release notes:**
```
Initial release — multiplayer rooms, bot mode, leaderboard, profile stats.
```

---

## Testing path (required before Production)

### 1. Internal testing (today)
Testing → Internal testing → Create release → Upload AAB → Roll out

### 2. Closed testing (required)
Testing → Closed testing → Create release → Upload AAB

**Testers:** Create email list → add 12+ people → share opt-in link

**Requirements for Production:**
- 12 testers opted-in
- 14 days of closed testing
- Then apply for Production access

---

## Enable GitHub Pages (privacy policy)

1. Go to https://github.com/VenkataSubbaiah5022/duel-dots/settings/pages
2. **Source:** Deploy from branch
3. **Branch:** `main` → folder **`/docs`**
4. Click **Save**
5. Wait 2–5 minutes
6. Test: https://venkatasubbaiah5022.github.io/duel-dots/privacy-policy.html

---

## Firebase release SHA-1 (if not done)

Add to Firebase Console → Android app:
```
71:22:14:DC:9A:42:03:3C:C3:7E:0C:94:46:4B:60:4A:69:C4:04:58
```

---

## Dashboard checklist order

1. [ ] Finish setting up your game (all policy forms)
2. [ ] Store listing complete
3. [ ] Privacy policy URL working
4. [ ] Upload AAB to Internal testing
5. [ ] Test on your phone
6. [ ] Upload AAB to Closed testing
7. [ ] Invite 12+ testers
8. [ ] Wait 14 days
9. [ ] Apply for Production
10. [ ] Publish to everyone
