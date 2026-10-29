# Direct APK updates — owner-approved distribution

Current owner trial (2026-10-29): signed1.0.1+2 is published with the original package/signing key; policy latest2/minimum1 offers an optional upgrade from1.0.0+1. See android-update-build2.json for deployment evidence. The owner confirmed the old app runs on their phone; upgrade/preserved-login acceptance is still pending. Do not assert owner-tested or raise the minimum before confirmation.

Approved 2026-10-28: production application ID `com.centerly.teacher`, first teacher distribution, a new fixed signing key, and a separate public binary-only GitHub repository. Production is `Centerly`; development remains a separate `.dev` app. Neither signing material nor development data is copied into the public repository.

## Teacher experience

The Android app checks the public environment-specific policy on cold start and on resume after a 15-minute cooldown. Existing required cached policies block immediately while the fresh check runs. A policy service outage alone does not block an installation without a known mandatory update. A known required policy remains enforced offline; valid withdrawal metadata can remove the gate. App authentication, subscription state and student data are not changed by updates.

An optional update offers Later. A mandatory update blocks the workspace/login and cannot be dismissed through Back or outside taps. Download is explicit, reports progress, resumes partial data when GitHub supports Range, and safely restarts when Range is ignored. Permission settings require a separate user action when Android requests it. Installation always uses Android's confirmation screen; it is not silent. Cancelling installation leaves the required gate and offers retry. Returning from settings does not automatically install anything.

APK files are kept only in a narrow private app-cache directory. Only HTTPS and the approved repository/download hosts are accepted. Size and SHA256 are checked in Dart and again natively. Native validation also requires the exact installed application ID, same current signer set, exact advertised build, a higher installed build number and compatible Android SDK. FileProvider is non-exported and grants only the verified APK URI. Signature rotation is intentionally not supported; preserve the original key.

The manifest is not an authentication/security boundary against modified clients. Existing backend authorization remains mandatory and is unchanged. Maintain API compatibility during staged rollouts. A device cannot learn a new server requirement while fully offline.

## Local signing — never commit or upload these files

- `android/keystore/centerly-release.jks`
- `android/key.properties`
- `build/release-private/centerly-signing-backup.zip`

These local files have owner/SYSTEM-only Windows ACLs and are ignored by Git. The backup ZIP is private, not a public release asset; store a copy securely outside this computer. Do not send it through the app repository, chat or public releases. The ZIP contains the JKS and properties; restore the JKS under `android/keystore/` and properties under `android/` on the other trusted build machine. The public config/android-release-identity.json pins the approved certificate fingerprint. Signing setup refuses to create another key once that pin exists; restore the private backup on another machine. Artifact inspection rejects any different signer. Losing this key prevents ordinary updates to already distributed installations. No password appears in this document or chat.

## Build and publish a future version

1. Increase pubspec version, for example `1.0.1+2`. Preserve the package ID and signing key.
2. Run formatting, analyzer, Flutter tests and Android JVM tests first. Run Flutter tests and native builds sequentially because Flutter rewrites generated plugin registration.
3. Build production with the complete command (do not use `--no-pub` for the release transition):

```powershell
flutter build apk --flavor prod --release --dart-define-from-file=.env.prod.json
node tools/release/inspect_artifact.mjs --inspect
node tools/release/publish_release.mjs --owner-approved --publish --minimum=1
```

The release Gradle guard requires production backend/config, preview=false, approved identity and private signing material. Preview fixture assets are dev-only. The inspector verifies APK identity, version, signer, bytes and a decompressed credential scan before upload. Publishing reconciles an existing identical asset, refuses to replace a published binary, uploads a draft if needed, publishes it, then anonymously downloads and hashes the public APK before preparing policy JSON. It never uploads source or signing keys.

4. Review the prepared `Centerly_secretary/public/updates/android-prod.json`, push validated source changes, then run that repository's `npm run deploy:pages`. Policy publication is last, after the binary is available. The website serves `/updates/*` with `Cache-Control: no-store`.
5. Test an actual upgrade over the previous signed production version on one device: preserve login/data, confirm installer permission/cancel/retry, weak network, insufficient space and final build number. Then confirm owner acceptance before raising the minimum:

```powershell
node tools/release/set_minimum.mjs --minimum=2 --owner-tested
```

Do not pass `--owner-tested` unless the human owner has confirmed the real-device upgrade. Push and deploy the updated website policy. The first published policy is latest=1/minimum=1; it does not force a nonexistent newer build on the first release.

## Recovery

To remove a required threshold, lower it explicitly with `--minimum=1 --emergency-withdrawal`, then push and deploy website metadata. For a problematic release, `--disable --emergency-withdrawal` removes the entire offer once clients receive the fresh policy. Do not delete already published APK URLs or replace binaries under an existing version. To reverse application behavior, build the repaired/previous source with a NEW higher build code; Android downgrades are not part of this flow.

Development policy starts disabled and cannot point at the production package. A signed production APK will not overwrite older prototype packages such as `com.example.centrally`, nor the separate dev app. Owner confirmed no production APK had been sent to teachers before this identity was chosen.

## Acceptance limits

Flutter unit/widget coverage includes required/optional/current policies, corrupted and mismatched metadata, HTTPS/repository restrictions, partial resume/restart, checksum rejection, settings return, cancellation/retry, space/SDK limits, cached offline enforcement and policy withdrawal. Arabic/English mandatory dialogs are checked against Back/outside dismissal. Android JVM tests verify identity/version/signer constraints and SHA256. APK signing and public-byte verification are separate artifact checks. A real device installation/upgrade and preservation of live device-local state are still owner acceptance; no device was installed or reconfigured by this task. No backend migrations, accounts, Auth changes or paid resources are involved.
