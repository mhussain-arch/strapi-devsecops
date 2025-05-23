import { test, expect } from '@playwright/test';
// eslint-disable-next-line import/extensions
import { resetDatabaseAndImportDataFromPath } from '../../utils/dts-import';
import { login } from '../../utils/login';

test.describe('Log Out', () => {
  test.beforeEach(async ({ page }) => {
    await resetDatabaseAndImportDataFromPath('with-admin.tar');
    await page.goto('/admin');
    await login({ page });
  });

  test('a user should be able to logout', async ({ page }) => {
    await page.getByRole('button', { name: 'test testing' }).click();
    await page.getByRole('menuitem', { name: 'Log out' }).click();

    await expect(page.getByText('Log in to your Strapi account')).toBeVisible();
  });
});
