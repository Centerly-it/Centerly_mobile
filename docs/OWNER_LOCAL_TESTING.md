Current update, 23 October: owner-requested synthetic development reset completed; all business tables empty and accounts retained. Earlier fixture/installed-APK statements below are historical. Group-pricing backend is local review only, not deployed; see [current acceptance](OWNER_RESET_AND_PRICING_ACCEPTANCE.md) and [one pricing review](GROUP_PRICING_REVIEW_AR.md). Hosted baseline remains 28.

Current owner-requested Arabic workflow: use the new OWNER28-AR-20261023 synthetic examples and SIMPLE_DAILY_WORK_AR.md. They were prepared under the later explicit ready-to-test request. The older OWNER28-20261023 proposal below was not executed; SEC27 remains retained and read-only. Teacher QR is removed and the refreshed app is installed on Redmi.

# Local owner testing — development Supabase only

Production hosting, paid services, distribution signing, launch privacy decisions and real-customer onboarding are deferred. They do not block this milestone. Use synthetic data only.

Secretary: http://127.0.0.1:5173 on this Windows computer. It runs connected to centerly-dev, extension=true, SQL fixture transport=false. Restart from the Secretary folder with `node scripts/start-owner-dev.mjs` only if stopped. The server is bound to loopback; it is not a public site or a phone-accessible LAN URL. Leave this process running while testing.

Teacher: install the configured development APK linked in the final handoff. It connects directly to development Supabase; no need for the phone to reach the local web server. Internet access is required. Preview is explicitly disabled. Debug signing is appropriate for this local test and does not imply distribution readiness.

Secure account access: on this trusted computer, open `D:\ahmedtamer\Centerly_mobile\.env.development-accounts.json` locally in Notepad. Match the account `name` field: `teacher-a` for Teacher and `secretary-a` for Secretary; these share synthetic tenant A. `teacher-b`/`secretary-b` belong to the separate negative-test tenant. Enter the corresponding email/password privately. Do not paste the file or credentials into chat, terminal commands, screenshots, source files or dart-defines. Do not reset passwords/create accounts. Close the file after use and clear any credential clipboard. No credentials are included in these instructions or compiled into the APK.

Current read-only exercise uses retained `SEC27-ACCEPT-20261022` records. They are archived and must not be edited or cleaned up again. In Teacher Students, enable **Archived students — history only**, open A1, then inspect attendance/academics/finance/notes. Select October 2026 for dated history. Archived notes have no Save action and are selectable/read-only. Secretary can inspect the archived rows and original invoice/receipt/reversal history. The retained void invoice has original 100.10, ledger net 0.00 and payable 0.00. Existing notifications may be inspected; marking unread records read is a write and is not part of the current read-only authorization.

Short cross-app checklist:

1. Student/group: compare retained identities and membership history in both apps. New create/edit/enroll steps require the proposed fresh scope below.
2. Attendance: compare October retained statuses, manual finalization/correction history and cancelled sessions; do not interpret unmarked as absent.
3. Academics: compare missing versus zero exam marks and assignment status for the same period.
4. Invoice/payment: compare original amount, signed receipt/reversal ledger and payable balance; the retained void invoice must remain 100.10 / 0.00 / 0.00.
5. Teacher refresh: use explicit refresh/reopen after selecting the matching student/date; check receipt actors and historical rows. Fresh cross-app writes need approval below.
6. Notifications: verify recipient/event/receipt context through existing rows; do not fabricate events or repeat SEC27 actions. New payment-event and mark-read steps belong only to the fresh scope.

Phone installation: enable Developer options and USB debugging, connect a data-capable USB cable, unlock the phone and accept this computer's RSA prompt. ADB must list it as `device`, not `unauthorized`. Then install the configured APK with `adb install -r PATH` and launch `com.example.centrally` (current local application ID). Do not uninstall an existing app or clear app data to resolve a signature mismatch; report the mismatch first. Redmi Note 9S is now connected; the final configured APK installed as an update and launched. Physical/manual testing is not claimed as passed.

Connect your phone, open the Teacher app and Secretary website, and test them together.
