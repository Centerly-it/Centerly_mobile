# SEC27 hosted acceptance complete — 22 October 2026

The owner-approved bounded SEC27 package and consolidated note/removal addendum completed on centerly-dev. Actual Supabase SDK/REST, Secretary Chromium and Windows Teacher UI acceptance passed. Thirteen audit events (limit 23), five attendance changes (limit 6), seven notifications (limit 8), exactly two note saves and one pending removal request are retained. Atomic guarded void cleanup ran once; both tenants’ complete financial totals and unrelated record digests match their pre-run baselines. Secretary-a remains active. No account/password/Auth configuration, migration, production deployment, push or publication occurred.

Current results and retained records: [SEC27 acceptance](docs/SEC27_ACCEPTANCE_2026-10-22.md), [detailed evidence](docs/SEC27_ACCEPTANCE_2026-10-22.json), [shared checklist](docs/SHARED_COMPLETION_CHECKLIST.md), [matrix](docs/CROSS_APP_ACCEPTANCE.md). Remaining gates: separate production/signing/privacy/support, provider recovery/monitoring, physical Android/iOS and remote CI/access. Archived-student RPC boundaries are documented; invoice/session histories remain retained/readable. Completed-run guards prohibit reseeding or repeated cleanup. Older unapproved-fixture/credential-absent statements below are historical.

# Current shared pilot checkpoint — 22 October 2026

Teacher remains canonical migration owner. All 27 deployed versions through `202610220002` are now present and hash-pinned here; fresh hosted history/full catalog match. No hosted schema/config/business changes ran. The previously missing original four-account credential file is available on this Windows machine and was read only in memory. Real SDK/Secretary Chrome and native Windows Teacher Auth/read-route checks passed. The configured Android debug APK built; physical-device/cross-app business acceptance remains gated.

The authoritative shared checklist is [SHARED_COMPLETION_CHECKLIST.md](docs/SHARED_COMPLETION_CHECKLIST.md); the [acceptance matrix](docs/CROSS_APP_ACCEPTANCE.md), [evidence](docs/PILOT_EVIDENCE.json) and [operations/runbook](docs/PILOT_OPERATIONS.md) separate passed checks from release gates. Secretary exists at `D:\ahmedtamer\Centerly_secretary`. Both initial worktrees were clean; this checkpoint preserves designs and existing immutable migration bodies. The migration-27 source is imported unchanged from the approved Secretary review, not newly deployed. Historical 26-version/credential-missing/future-Secretary statements below are superseded.

# Current handoff — approved Finance migration26,22 October2026

Teacher implementation is complete for the agreed owner-testing scope. Only the
approved202610220001 receipt-filter read was deployed to centerly-dev, exact SHA256;
all26 migration bodies and full catalog verified. Receipt filters are enabled in
source/connected launch. No account, financial or fixture mutations; no build or
restart during this deployment follow-up. Original development credentials remain
unavailable, so authenticated owner acceptance is pending. Exact expected path,
route checklist and final preview=false/receipt-filters=true build command:
[TEACHER_OWNER_TESTING.md](docs/TEACHER_OWNER_TESTING.md). Deployment evidence:
[FINANCE_MOVEMENTS_DEPLOYMENT_2026-10-22.md](docs/FINANCE_MOVEMENTS_DEPLOYMENT_2026-10-22.md).
Secretary inherits the identical26-version schema/history without replay. No pending
backend approval blocks Teacher testing; attendance free-text search is unavailable,
group notes excluded and QR deferred. Pilot/recovery/React acceptance are separate.
All previous checkpoint text below is historical and superseded where inconsistent.

# Latest checkpoint — 22 October 2026

Read [TEACHER_OWNER_TESTING.md](docs/TEACHER_OWNER_TESTING.md) and the latest entry
in IMPLEMENTATION_PROGRESS.md first. The October20 snapshot below is retained as
historical context. Finance/Groups/Students/Profile/Calendar/Session designs are
now connected to actual scoped repositories. Original development credentials are
unavailable; authenticated owner acceptance is still open. Group-note editing is
excluded by explicit owner decision. One default-off, undeployed receipt-filter
read proposal is prepared in TEACHER_OWNER_BACKEND_REVIEW.md. All25 existing
migration bodies and the live catalog were freshly verified; none was redeployed.
Current route checklist, test evidence and one final configured build command are
in TEACHER_OWNER_TESTING.md. Pilot/recovery and React acceptance are separate gates.

# تسليم مشروع Centerly — الحالة الموثقة بتاريخ 20 أكتوبر 2026

هذا هو ملف البداية عند الانتقال لجهاز آخر. يصف الكود الموجود فعلًا، ويفصل
التصميم التجريبي عن الربط الحقيقي. لا تعتبر أي واجهة أو اختبار mock دليلًا على
اكتمال المنتج. التفاصيل التاريخية في IMPLEMENTATION_PROGRESS.md؛ الأحدث هنا
وفي سجل نشر 2026-10-20 يتقدّم على العبارات الأقدم مثل LOCAL ONLY.

## 1. المستودع والحالة الحالية

- المستودع: https://github.com/Centerly-it/Centerly_mobile — الفرع main.
- نقطة بداية المراجعة الأخيرة: 0577486. هذا التقرير ضمن commit تسليم التغييرات
  اللاحقة؛ اعرف رقمه بـ git log -1 --oneline بدل الاعتماد على نسخة ملف قديمة.
- تمت مقارنة origin/main قبل تجهيز هذا التسليم؛ كان مطابقًا لنقطة البداية.
- لا تعمل reset أو تستبدل pubspec.lock أو تعيد تطبيق migrations عند تغيير الجهاز.
- لم يُبنَ APK جديد في جولة المراجعة والنشر هذه، ولم يُنفذ Hot Restart تلقائي.
  ملفات APK القديمة على الجهاز السابق لا تثبت حالة هذا الـcommit.

## 2. قواعد يجب قراءتها قبل استكمال العمل

1. agent_rules.md — البنية، إعادة الاستخدام، الترجمة، تقسيم ملفات الكود الكبيرة.
2. CENTERLY_TEACHER_IMPLEMENTATION_PLAN.md — نطاق التطبيق ومعايير قبول المهام.
3. IMPLEMENTATION_PROGRESS.md — أحدث النتائج والعوائق ثم السجل التاريخي.
4. docs/SHARED_BACKEND_CONTRACT.md وsupabase/schema-manifest.json — العقد المنشور.
5. docs/HARDENING_DEPLOYMENT_VERIFICATION_2026-10-20.md — دليل آخر نشر فعلي.
6. docs/MAIN_LOGIC_PERFORMANCE_AUDIT.md — النتائج والقياسات وحدودها.
7. docs/SECRETARY_HANDOFF.md — انتقال ملكية الباك واختبارات التطبيقين.

تفضيلات صاحب المشروع: الحفاظ على التصميم الحالي، ترجمة AR/EN، كود قابل
لإعادة الاستخدام، وعدم إضافة صلاحيات مدرس لإضافة الطلاب أو تسجيل المدفوعات
أو تعديل الحضور. لا تبنِ APK أو تعمل Restart بعد كل تعديل UI؛ صاحب المشروع
يختبر ويعمل إعادة التشغيل بنفسه. النشر اللاحق يحتاج مراجعة وموافقة جديدة.

## 3. ما تم في الواجهات وتجربة الاستخدام

التغييرات التالية موجودة في الكود، لكن عددًا مهمًا من التصاميم الحديثة يختار
مسار debug preview، وليس مسار البيانات الحقيقي. لا تعطّل هذا الفصل بالتخمين.

| القسم | ما نُفّذ | الحالة وحدود القبول |
|---|---|---|
| الدخول والدعم T-011 | Supabase Auth، استعادة الجلسة، خروج، تحقق الدور/المدرس/الاشتراك، أخطاء مترجمة؛ تبسيط نصوص ولوجو الدخول؛ تواصل مع الدعم عبر WhatsApp قابل للتهيئة | الربط واختبار SDK حقيقيان؛ لا يُحفظ الباسورد نصيًا. جلسة SDK هي المحفوظة |
| الهيكل T-012 | AppBar مشترك، ترحيب صباح/مساء حسب القاهرة، تاريخ، جرس إشعارات، صورة محلية من المعرض مع تعديل/حذف عند الضغط، tabs وألوان تحديد بدون خلفية | حافظ على نفس المكوّن؛ الاسم الحقيقي للمدرس ما زال عامًا في العقد الحالي؛ الصورة محلية وليست مزامنة سحابية |
| الرئيسية T-020 | اليوم افتراضيًا، تاريخ مختار، كروت مختصرة وأوقات12h وحالات الحصص، مبالغ مجمّعة ورمز جـ، تقدم التحصيل، طلاب لم يسددوا قبل الحضور | الأرقام التجريبية للعرض فقط؛ live overview موجود، وبيانات الحضور الجاري منشورة ومتحقق منها |
| الحصص T-022 | تصميم اليوم/الأسبوع/الشهر وتفاصيل الحصة؛ تصحيح التقويم وتحديد اليوم ونقاط الحالة ومنها الملغاة، وترتيب الوقت AR | التصميم الحديث معاينة؛ توجد قراءات calendar/session حقيقية منفصلة؛ اختبار جهاز وSecretary مشترك لم يكتمل |
| كشف الحضور T-023 | حالات منفصلة، البحث والحالة الفارغة، غياب/حضور/اعتذار/غير مسجل، قيد التسجيل دون توقيت القاهرة المكرر | المدرس يقرأ فقط؛ لا تحويل تلقائي لغير المسجل إلى غائب؛ تصحيح ما بعد الاعتماد عبر Secretary مع سبب |
| إلغاء الحصة T-024 | سبب وتأكيد وRPC وحالات تعارض، مع إشعار الجهات الموجودة | سباقات الإلغاء وعزل المستأجرين مختبرة محليًا وعلى fixtures حقيقية؛ ليس دليل قبول التطبيقين |
| المجموعات T-021 | قائمة/فلاتر/تفاصيل/طلاب بتصميم Figma مع الـAppBar المشترك | الربط القديم للقراءة موجود؛ التصاميم الجديدة تحتاج نقلًا من preview؛ ملاحظات المجموعة تجريبية في الذاكرة فقط |
| الطلاب T-030 | directory/profile والبحث والفلاتر وتفاصيل الطالب، إلغاء زر إضافة طالب، توحيد صورة البحث الفارغ | المدرس لا يضيف؛ التصاميم الستة معاينة؛ البيانات/QR/contact تحتاج قبولًا وربطًا فعليًا |
| الأكاديميات T-031 | عقود وقراءات واجهات درجات وواجبات وتمييز null عن صفر | قراءات فعلية واختبارات hosted؛ تكامل التصاميم الحديثة واختبارات الجهاز مشتركة ما زالت مطلوبة |
| تاريخ الحضور T-032 | قراءة سجل الطالب وحالاته وفلاتره دون افتراض الغياب | العقود متاحة واختبرت؛ لا يُستنتج الحضور من توقيت الحصة أو شكل الواجهة |
| المالية T-033 | تصميم overview/مستحقات/حركات، فاتورة وتاريخ إيصالات وعكس، مسؤول التحصيل وطريقة الدفع، فلاتر وحاسبات مساعدة | التصميم الشامل debug preview؛ live finance القديم موجود؛ عقود المالية الجديدة منشورة لكن adapter التصميم الجديد لم يُنفذ بعد |
| الملاحظات T-034 | ملاحظة المدرس للطالب مع تعارض التحديث والحفاظ على المسودة | عقود حقيقية واختبارات hosted؛ لا تخلطها مع ملاحظات المجموعات غير الدائمة |
| السكرتيرات والإشعارات | قراءة السكرتيرات وطلب إزالة دون تعطيل الحساب، إشعارات دفع/عكس/إلغاء ومعالجة إزالة، تعليم كمقروء | fixtures مختبرة؛ لا CRUD للحسابات ولا push/email تلقائي؛ بيانات الحسابات إدارية |
| Splash | تقليل الانتظار إلى1000ms وتكبير الهوية مع مراعاة native splash | لا يوجد قياس أداء بدء تشغيل على جهاز حقيقي في هذه الجولة |

## 4. منطق الحضور والمالية المعتمد

- «الحضور في السنتر الآن» يعني علامات حضور الحصص الجارية فقط، لا إجمالي اليوم
  المختار ولا نظام دخول/خروج فعلي للسنتر.
- السيرفر يحسب starts_at <= statement_timestamp() < ends_at؛ الملغاة والمستقبلية
  والمنتهية لا تدخل. الحصة العابرة لمنتصف الليل لا تُفقد بسبب local_date.
- not_marked يظهر «لم يُسجّل» وليس «مُنتظر» أو غائبًا. إذا الطالب في حصتين
  متداخلتين فالعد حسب سجل الطالب/الحصة، وليس أشخاصًا فعليين فريدين.
- scope='ongoing_sessions' وتوقيت المزامنة يمنعان عرض التجميع القديم كأنه الآن.
  التحديث عند التحميل/اختيار يوم/pull-to-refresh؛ ليس realtime subscription.
- المبالغ الدقيقة BigInt بالقروش في حسابات العميل، ونوع numeric في PostgreSQL.
  أرقام العرض قد تكون صحيحة بدون كسور، لكن القيم الحسابية لا تفقد القروش.
- استحقاق فواتير الشهر وتسوية تلك الفواتير مختلفان عن صافي النقد المحصل في
  نفس الشهر. العكس لإيصال قديم قد يجعل صافي شهر سالبًا بشكل صحيح.
- الإيصالات append-only، والعكس كامل وله مرجع؛ المدرس لا يقبض أو يعكس.
  الحسابات ترفض المراجع المفقودة/التكرار/العكس الجزئي أو المتكرر/الرصيد المستحيل.
- السجل المفهرس الكامل في العميل لا يجوز بناؤه من صفحة جزئية من API؛ ملخصات
  الصفحات والفلاتر يجب أن تأتي من السيرفر على مجموعة البيانات كاملة.

## 5. المراجعة والإصلاحات الأخيرة

- كاش LRU في الذاكرة فقط:64 عنصرًا،2MiB payload مشفر UTF-8 إجمالًا،256KiB
  للعنصر؛ هذه ليست حدود إجمالي heap. مجموعات/طلاب30 ثانية، ملف/أكاديميات15.
- المالية والحضور والداشبورد والصلاحيات الحساسة والملاحظات والإشعارات والسكرتيرات
  بلا TTL مخزن. الطلبات المتطابقة الجارية تتشارك RPC واحدًا وتعود بنسخ مستقلة.
- الكاش معزول حسب project/user/token؛ يبطل عند التغيير والعمليات والخروج، وترفض
  الردود المتأخرة. لا إعادة تلقائية لعمليات الكتابة. Refresh يتخطى الكاش المخزن.
- إصلاح تداخل restore/login/logout وتحديث token أثناء التحقق؛ الواجهات المحمية
  لا تفتح قبل التحقق؛ restore الشبكي بعد أول frame بدل تعطيل ظهور التطبيق.
- حذف طباعة رسائل backend الخام من مسارات legacy، دون تغيير منطق الصلاحيات.
- فهرسة مالية O(invoices+movements)، مع مطابقة مرجع حساب مستقل واختبارات حدود.
- جلب calendar والمالية بالتوازي بعد overview، مع نفس حارس الجلسة.
- منع صفحات pagination غير المرتبة/المكررة/غير المتقدمة بدل دوران أو فقد نتائج.
- نقاط التقويم لا تنشئ roster كبيرًا لكل يوم؛ صورة البروفايل تتحقق من أبعادها
  قبل decode، تخزن PNG بحد512 للضلع، وتتخلص من metadata وموارد الرسم.
- قياس JIT محلي:1000 فاتورة/20000 حركة، تحسن الحمل المرجعي نحو5.4x؛ وEXPLAIN
  أثبت استخدام covering index. ليست أرقام سرعة تطبيق/موبايل/سيرفر production.

## 6. الباك المنشور فعلًا

- مشروع development: centerly-dev، المرجع yfeubomyglmhuwizaqoj.
- 25 migration منشورة حتى202610200006؛ لا توجد migration معلقة بعد آخر dry run.
- الأصل19 لم تتغير؛ بعد موافقة صريحة نُشرت الملفات الستة المطابقة لبصمات المراجعة:
  001 finance overview/index،002 invoice detail،003 filtered dues،004 preserve void،
  005 enrollment timeline،006 ongoing attendance/index.
- فحص ما قبل النشر طابق history وبنية الدوال/grants/RLS/policies/indexes/triggers
  والقيود مع قاعدة محلية؛ وجد0 enrollment مخالف. فحص ما بعد النشر طابق25 جسم SQL،
  44 دالة تطبيقية،18 جدولًا و30 policy. manifest في المستودع مصدر البصمات.
- enrollment CHECK يظل NOT VALID كما تمت الموافقة، رغم عدم وجود مخالفات وقت الفحص.
  يجب على Secretary تحديث status وleft_at معًا:active بلا left_at، inactive بتاريخ
  خروج >=joined_at. لا تخمّن تاريخ خروج أو تعمل إصلاح بيانات دون إذن.
- لم تتغير حسابات أو إعدادات Auth في هذا النشر؛ لا backfill ولا customer mutations.
  اختبارات hosted استخدمت الحسابات والبيانات الاصطناعية المصرح بها فقط.
- راجع docs/MAIN_HARDENING_CHANGE_REVIEW.md للبصمات الستة، وسجل النشر للتفاصيل.
- هذا لا يمنح موافقة لأي نشر جديد، ولا production/store release.

## 7. نتائج التحقق الموثقة

| التحقق | النتيجة | التوقيت/الحدود |
|---|---|---|
| Flutter كامل |240 PASS،1 hosted opt-in SKIP | جولة مراجعة الكود السابقة مباشرة للنشر |
| preview navigation/transport |3 PASS | تشغيل صريح بالـdefine؛ لا شبكة حقيقية |
| analyze / format / lockfile / codegen | PASS | lockfile بلا تغيير؛ لا issues؛ generated sources قابلة للإعادة |
| PostgreSQL |373 assertion PASS | foundation90،concurrency11،detail33،profile21،completion98،integrity22،finance68،hardening30؛ آخر regression بعد إضافة managed migrations |
| PostgreSQL Windows launcher |2 PASS | ضمن المراجعة؛ ليس اختبار hosted |
| hosted completion |98 PASS | تشغيل حقيقي بعد النشر على fixtures المعتمدة |
| hosted hardening |37 PASS | finance/tenant/roles/retry/void/notifications/attendance boundaries/rollback |
| Flutter SDK hosted Auth |1 PASS | تم تشغيل opt-in فعليًا؛ ليس الاختبار المتخطى فقط |
| آخر dry run | up to date | تحقق من السيرفر بعد النشر |

لا توجد في هذه الجولة شهادة جهاز/إطار/ذاكرة أو قبول Secretary UI. فشل fixture
ترتيب IDs في أول full test أُصلح ليتطابق مع ترتيب UUID من السيرفر، ثم240 نجحت.
لا تبنِ وصف «جاهز للإنتاج» على هذه الأرقام وحدها.

## 8. تشغيل المشروع على جهاز جديد

### الأدوات

Flutter3.44.2 stable / Dart3.12.2، Java17، Android SDK36/build-tools/licenses،
Git، Node22+ وnpm. CI هو المرجع للنسخ؛ لا تُرقِّ dependencies أو تستبدل lockfile
لمجرد اختلاف SDK. راجع flutter doctor -v. اختبارات PostgreSQL تشغل نسخة embedded
محلية مؤقتة على port55439؛ شغّلها بالتتابع، ولا تحتاج reset للسيرفر.

```powershell
git clone https://github.com/Centerly-it/Centerly_mobile.git
cd Centerly_mobile
git switch main
git pull --ff-only
flutter pub get --enforce-lockfile
dart run build_runner build
flutter analyze --no-pub
flutter test --no-pub
npm ci --prefix supabase/tests
node supabase/tests/check_manifest.mjs
node supabase/tests/run.mjs
node supabase/tests/concurrency.mjs
node supabase/tests/finance_business.mjs
node supabase/tests/logic_hardening.mjs
```

### المعاينة مقابل الاتصال الحقيقي

- VS Code: اختَر Centerly (UI preview — offline) لمراجعة التصميم دون backend.
  debug-only، دخول وأرقام وهمية، التعديلات المؤقتة تختفي عند إعادة التشغيل.
- VS Code: Centerly (connected development) يقرأ .env.local.json ويجبر preview=false.
  launch بدون defines سيُظهر إعدادات اتصال غير مهيأة؛ هذا ليس فشل كلمة المرور.
- ملف .env.example توضيحي بصيغة KEY=VALUE؛ ملف التشغيل المطلوب JSON حقيقي:

```json
{
  "APP_ENV": "development",
  "SUPABASE_URL": "https://yfeubomyglmhuwizaqoj.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "REPLACE_LOCALLY",
  "CENTERLY_UI_PREVIEW": false,
  "CENTERLY_SUPPORT_URL": "https://wa.me/201028684980"
}
```

المفتاح publishable من إعدادات المشروع، وليس service_role. لا تضع بيانات دخول
داخل تعريفات بناء التطبيق. تغيير launch-time defines/assets يحتاج تشغيلًا جديدًا
مرة واحدة؛ Hot Restart وحده لا يغيرها. بعد ذلك صاحب المشروع يتحكم في إعادة التشغيل.

```powershell
flutter run --dart-define-from-file=.env.local.json --dart-define=CENTERLY_UI_PREVIEW=false
# معاينة دون أي اتصال:
flutter run --dart-define=CENTERLY_UI_PREVIEW=true
```

### ملفات محلية لا تنتقل مع Git

.env.local.json، .env.development-accounts.json، .env.native-auth.json،
.env.teacher-test-login.txt، supabase/.temp، جلسة CLI، secure-storage للجهاز،
Android SDK paths/local.properties، build/APKs،node_modules،وسجلات build المحلية.
كانت ملفات التهيئة/حسابات التطوير موجودة على الجهاز الأصلي وقت النشر؛ لا تفترض
وجودها على الجهاز الجديد. انقل المطلوب عبر قناة خاصة موثوقة. لا ترفعه إلى Git
ولا تكتب كلمات المرور في هذا التقرير. إذا فُقدت البيانات اطلبها من المالك، ولا
تعمل reset passwords أو provision accounts تلقائيًا.

أوامر Supabase الإدارية الحالية موثقة لمسار Windows operator وتستخدم npx offline؛
بعد npm ci --prefix supabase/tests، جهز Supabase CLI منفصلًا، فحزمة tests لا تثبته.
`npx supabase --version` يمكنه تهيئة CLI في npm cache أول مرة. لا تُشغّل النسخة
الإدارية ذات --offline قبل توفرها. للربط عند الحاجة فقط:

```powershell
npx supabase login
npx supabase link --project-ref yfeubomyglmhuwizaqoj
```

الربط لا ينشر. لا تستخدم db reset --linked، ولا تعيد provision أو apply القديم.
اختبارات hosted لها آثار على fixtures وتحتاج إذنًا مناسبًا؛ لا تشغلها كفحص جهاز
جديد عادي. افحص read-only history والهوية قبل أي تغيير. بيانات CLI الإدارية لا
تدخل Flutter إطلاقًا. راجع dry run والبصمات واطلب موافقة لأي SQL جديد.

## 9. المتبقي والترتيب التالي

1. ربط تصميم Finance الجديد بعقود overview/dues/invoice detail المنشورة، مع
   paging/filters وattribution ومطابقة ملخصات السيرفر، دون ledger جزئي أو صلاحيات قبض.
2. نقل تصاميم المجموعات والطلاب والحصص من preview إلى adapters حقيقية تدريجيًا؛
   الحفاظ على الـshared AppBar والترجمة والحدود. لا تزعم أن كل التصاميم live الآن.
3. عقد اسم المدرس الحقيقي، قرار persistence لملاحظات المجموعة، قبول QR/contact
   وتكامل تفاصيل الصفحات قبل الادعاء باكتمال Teacher MVP.
4. اختبار جهاز Android فعلي، إعدادات الاتصال/استعادة الجلسة/الخروج/revocation،
   ضعف الشبكة/استعادة العمليات، الأداء والذاكرة. عند طلب build جديد قدّم APK
   configured جديدًا؛ artifacts CI غير المهيأة لا تكفي لاختبار login.
5. فصل جاهزية Teacher لتجربة المالك عن pilot: توقيع وإصدار وتحديث/استرجاع، أجهزة
   متعددة، بيانات أحجام حقيقية، security/recovery وSecretary cross-app acceptance.
6. بدء Secretary React بعد تسليم milestone المدرس؛ لا تجعل اختبار تطبيق React
   غير الموجود سببًا لادعاء اكتماله أو لتأجيل توثيق بوابات pilot.

## 10. تسليم Secretary وعدم تكرار الباك

هذا المستودع يمتلك canonical backend مؤقتًا بموافقة المالك. عند إنشاء Secretary
انقل نفس25 migration والبصمات والاختبارات والعقد وسجل supabase_migrations كما هو؛
لا تعمل schema fork أو تعيد replay/version rename. حدّد مالك migrations واحدًا
بعد الانتقال. React يستخدم public URL/publishable key وAuth/RLS، وليس admin key.

Secretary يسجل الحضور والمدفوعات والطلاب/المجموعات والأكاديميات، بينما المدرس
يراقب ويكتب ملاحظته ويلغي حصة ويطلب إزالة. تحقق end-to-end من إنشاء طالب/مجموعة،
الحضور المتأخر وتصحيحه، الدفع والعكس والفاعل والإشعار، إلغاء الحصة، طلب الإزالة،
تزامن التحديثات والتعامل مع التعارض، ومستأجرين معزولين. API tests لا تثبت UI React.

## 11. قبل كتابة أي كود في الجلسة القادمة

شغّل git status/log وفحصًا غير هدّام، اقرأ هذا الملف والمراجع، وحدّد preview/live
والـmigration version الفعلي. احتفظ بتغييرات المستخدم، لا تلمس الأسرار، ولا تنشر
أو تعيد كلمات مرور لمجرد أن تقريرًا تاريخيًا ذكر موافقة سابقة. النقطة التالية
المؤهلة حاليًا هي production finance adapter، وليست إعادة نشر migrations.
