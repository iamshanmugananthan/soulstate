# F-Droid Submission & Publishing Guide for Soul State

This document explains how **Soul State** (`com.shanmugananthan.soulstate`) is configured for inclusion in **[F-Droid](https://f-droid.org/)**, the free and open-source Android app repository.

---

## 1. Metadata Files Included in this Repository

Soul State includes all required F-Droid / Fastlane metadata:

1. **F-Droid Build Recipe:**
   - [`metadata/com.shanmugananthan.soulstate.yml`](../metadata/com.shanmugananthan.soulstate.yml) — Recipe for F-Droid's official `fdroiddata` repository.
   - [`.fdroid.yml`](../.fdroid.yml) — Local repository configuration.

2. **Fastlane Store Listing Structure:**
   - [`fastlane/metadata/android/en-US/title.txt`](../fastlane/metadata/android/en-US/title.txt) — App title (`Soul State`).
   - [`fastlane/metadata/android/en-US/short_description.txt`](../fastlane/metadata/android/en-US/short_description.txt) — Short summary (<= 80 chars).
   - [`fastlane/metadata/android/en-US/full_description.txt`](../fastlane/metadata/android/en-US/full_description.txt) — Comprehensive markdown description.
   - [`fastlane/metadata/android/en-US/changelogs/1.txt`](../fastlane/metadata/android/en-US/changelogs/1.txt) — Version 1.0.0 release changelog.
   - [`fastlane/metadata/android/en-US/images/icon.png`](../fastlane/metadata/android/en-US/images/icon.png) — 1024x1024 high-resolution icon.
   - [`fastlane/metadata/android/en-US/images/phoneScreenshots/`](../fastlane/metadata/android/en-US/images/phoneScreenshots/) — App preview screenshots.

---

## 2. Steps to Submit to F-Droid

To have Soul State published on F-Droid:

1. **Fork `fdroiddata` on GitLab:**
   - Go to [gitlab.com/fdroid/fdroiddata](https://gitlab.com/fdroid/fdroiddata) and fork the repository.

2. **Add Metadata Recipe:**
   - Copy the recipe [`metadata/com.shanmugananthan.soulstate.yml`](../metadata/com.shanmugananthan.soulstate.yml) into the `metadata/` directory of your `fdroiddata` fork.

3. **Verify Locally with `fdroidserver` (Optional):**
   ```bash
   fdroid checkupdates com.shanmugananthan.soulstate
   fdroid lint com.shanmugananthan.soulstate
   fdroid build -v -l com.shanmugananthan.soulstate
   ```

4. **Submit a Merge Request:**
   - Push your new file to a branch on your GitLab fork.
   - Open a Merge Request against `fdroid/fdroiddata` with the title:
     `New app: com.shanmugananthan.soulstate (Soul State)`
   - The F-Droid automated bots and maintainers will verify reproducible builds and merge the recipe.

---

## 3. Automation and Future Releases

- The recipe uses:
  ```yaml
  AutoUpdateMode: Version
  UpdateCheckMode: Tags
  ```
- Whenever you tag a new release on GitHub (e.g., `v1.1`), F-Droid's update bot will automatically detect the new git tag, bump `versionName` and `versionCode`, and trigger a clean build on F-Droid's build servers.
