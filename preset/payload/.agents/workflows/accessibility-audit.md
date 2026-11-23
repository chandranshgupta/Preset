---
description: Accessibility (a11y) audit for any user interface stack, WCAG 2.1 AA baseline
---

# Accessibility audit

Applies when the profile has a user interface (`has_ui`). Open-source depth:
`sh .agents/bin/slice.sh -f oss get WI-ACCESSIBILITY`.

## Guardrails
- Detect the stack first; different frameworks have different linting and scanning tools.
- Don't assume specialised tools (axe, Lighthouse) unless detected.
- Semantic HTML before ARIA.
- WCAG 2.1 AA as the baseline unless the user names another target (Section 508, etc.).
- Don't break existing styles or patterns.

## Steps

### 1. Understand context
Which page, component or URL · specific concerns (keyboard, screen reader, contrast) · compliance
target.

### 2. Analyse the project
Framework (React, Vue, Svelte, static HTML, native) · a11y tooling (`eslint-plugin-jsx-a11y`,
`axe-core`, `jest-axe`) · component and styling patterns (Tailwind, CSS Modules, design tokens).

### 3. Audit
- **Automated scan** when tools are present (`npm run lint`, axe).
- **Semantics**: landmarks (`header`, `main`, `nav`), heading order, labelled inputs, alt text.
- **Interaction**: keyboard reachability, visible focus, focus management in dialogs, ARIA roles
  that match behaviour.
- **States**: empty, loading, error, narrow width, reduced motion, contrast.
- Findings by severity: Critical, Major, Minor.

### 4. Verify
Complete the primary flow with the keyboard only; observe each state once; fixes follow the
project's style; ARIA roles match intended behaviour.

## Principles
Semantic first · progressive enhancement · consistency with the project's patterns and tokens.

## Reference
`package.json` lint rules · existing components' focus and label handling · `rg` for ARIA roles
and landmarks · WCAG 2.1 quick reference (w3.org/WAI/WCAG21/quickref).
