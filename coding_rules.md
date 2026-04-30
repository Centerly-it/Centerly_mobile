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