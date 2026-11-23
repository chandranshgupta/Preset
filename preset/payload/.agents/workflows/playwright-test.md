---
description: Set up Playwright and write robust browser tests for a web application
---

# Playwright browser testing

Applies to web applications (profile archetype WEB_APP). Skill `testing`; workflow `e2e-test`.
Import skill `playwright-skill` from a library if you want more depth.

## Guardrails
- Wait for elements through assertions, never fixed timeouts.
- Semantic selectors (role, label, text) over CSS; `data-testid` for stable hooks.
- Isolated, independent tests.
- Install inside the project (dev dependency), never globally (L11); ask before adding it.

## Steps

### 1. Check or install
```bash
npm init playwright@latest
```
Skip if already installed.

### 2. Configure
Verify `playwright.config.ts` has:
```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```
Adjust `baseURL`, `command` and the port to the project's real values.

### 3. Create a test (`tests/<feature>.spec.ts`)
```typescript
import { test, expect } from '@playwright/test';

test.describe('Feature Name', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('should display the main heading', async ({ page }) => {
    await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
  });

  test('should navigate to about page', async ({ page }) => {
    await page.getByRole('link', { name: 'About' }).click();
    await expect(page).toHaveURL('/about');
  });
});
```

### 4. Selector preference
```typescript
page.getByRole('button', { name: 'Submit' })   // best
page.getByTestId('submit-button')               // good
page.getByLabel('Email address')                // good
page.getByText('Welcome back')                  // acceptable
page.locator('.submit-btn')                     // last resort
```

### 5. Run
```bash
npx playwright test
npx playwright test --ui
```

### 6. Report
```bash
npx playwright show-report
```

## Common patterns
```typescript
await page.goto('/', { waitUntil: 'networkidle' });
await page.getByLabel('Email').fill('test@example.com');
await page.getByLabel('Password').fill(process.env.E2E_PASSWORD ?? '');
await page.getByRole('button', { name: 'Sign In' }).click();
await expect(page.getByRole('alert')).toContainText('Success');
await page.screenshot({ path: 'screenshot.png', fullPage: true });
```
Test credentials come from the environment, never hard-coded in the spec (L05).

## Guidelines
Name tests "should <action> when <condition>" · group with `test.describe` · no
`page.waitForTimeout` · run in CI · `npx playwright codegen` to draft selectors · docs:
playwright.dev/docs/intro.
