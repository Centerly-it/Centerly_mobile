## Always
- Follow the existing project architecture, folder structure, and naming conventions.
- Reuse existing widgets, helpers, utilities, managers, and shared components before creating new ones.
- Check `ColorManager`, `StyleManager`, adaptive/responsive utilities, localization, and shared/core components first.
- Keep code clean, simple, maintainable, and consistent with the project.
- Preserve existing behavior unless the task explicitly requires a change.

## Before creating anything new
- Check whether the project already has the same pattern or component.
- If it can be reusable, make it generic and place it in the proper shared/core location.
- If the file becomes large (more than 100 lines), split it into smaller focused files.
- If there is a safe related refactor that improves readability or maintainability, apply it.

## UI rules
- Use project colors, typography, spacing, and styling conventions.
- Avoid hardcoded colors, styles, and strings.
- Use localization for user-facing text.
- Follow responsive/adaptive patterns as much as possible without changing behavior.

## Coding behavior
- Do not blindly implement.
- Review the surrounding code and improve the solution where needed.
- Prefer consistency, simplicity, and maintainability over quick patching.
## Shared reads, loading and performance
- Reuse `PagedReadCubit` for cursor request ordering, stale-response/disposal guards, duplicate/cycle validation and independent initial/refresh/more states. Feature-specific state adapters use `MappedPagedCubit`; keep endpoint ordering, limits, summaries and cursor validation in repositories.
- Use lazy builders for growing production lists. Keep current content during same-query refresh; clear on account/access denial. Retry the failed page type without retrying mutations automatically.
- Use `ContentSkeleton`/`LoadingPage` (Skeletonizer) for initial read geometry, never fake business records. Keep save/login/download progress meaningful; respect reduced motion, route/tab visibility, lifecycle and screen-reader semantics.
- Retain documented cache scope/TTL/size limits and remote freshness rules. Decode images near display resolution. Measure device performance in profile mode before claiming frame-time improvements; widget construction counts are structural tests only.
