# Gates separate from Teacher owner testing

These gates remain open independently of the connected Teacher implementation.
They are not tests that require building the future Secretary React app now.

- Pilot signing/distribution: owner-approved package ID, private keystore custody,
  version policy, privacy/support links, installed signed build, update/rollback
  checks on two devices. Current example app ID and debug signing are not a pilot.
- Recovery: named operator, restricted encrypted offsite backup, retention/export
  policy and an actual restore drill. A free development backend is not evidence
  of recoverability. No backups, provisioning or data repairs were performed here.
- Native/performance: budget physical Android startup/frame/memory/network and
  accessibility/TalkBack testing, resume/expiry/revocation and external contact apps.
  Emulator or widget screenshots do not establish physical-device acceptance.
- Security/configuration: public signup/admin provisioning status freshly verified
  by the operator; no privileged keys or synthetic login credentials in builds.
- Secretary cross-app acceptance (after React exists): two isolated tenants;
  secretary creates groups/students/enrollments and academics, marks/corrects late
  attendance with reason after finalization, collects/reverses with exact actor/
  receipt history and notifications; teacher refreshes, cancels a session and
  requests removal. Record recovery/error/concurrency scenarios and owner signoff.

See SECRETARY_HANDOFF.md for the single canonical backend transfer and operational
contracts. Do not label API-only or fixture tests as React UI acceptance.
