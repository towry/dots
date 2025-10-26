#!/usr/bin/env bun

/**
 * Clear all GitHub notifications
 * 
 * This script fetches all GitHub notifications and deletes them.
 * 
 * Usage: bun run clear-github-ghost-notifier.ts [--dry-run]
 */

interface GitHubNotification {
  id: string;
  subject: {
    title: string;
    url: string;
    latest_comment_url: string;
    type: string;
  };
  repository: {
    id: number;
    name: string;
    full_name: string;
    owner: {
      login: string;
    };
  };
  reason: string;
  unread: boolean;
  updated_at: string;
}

async function fetchNotifications(): Promise<GitHubNotification[]> {
  const result = await Bun.spawn(['gh', 'api', 'notifications'], {
    stdout: 'pipe',
    stderr: 'pipe',
  });

  await result.exited;
  
  const output = await new Response(result.stdout).text();
  const errorOutput = await new Response(result.stderr).text();
  
  if (result.exitCode !== 0) {
    throw new Error(`gh command failed with exit code ${result.exitCode}: ${errorOutput || output}`);
  }

  const trimmed = output.trim();
  if (!trimmed) {
    return [];
  }

  try {
    const parsed = JSON.parse(trimmed);
    if (!Array.isArray(parsed)) {
      throw new Error(`Expected array but got: ${typeof parsed}`);
    }
    return parsed;
  } catch (error) {
    if (error instanceof SyntaxError) {
      throw new Error(`Invalid JSON response: ${error.message}\nOutput: ${trimmed.substring(0, 200)}`);
    }
    throw error;
  }
}

async function deleteNotification(threadId: string, dryRun: boolean): Promise<boolean> {
  if (dryRun) {
    console.log(`[DRY RUN] Would delete notification: ${threadId}`);
    return true;
  }

  const result = await Bun.spawn([
    'gh',
    'api',
    '--method',
    'DELETE',
    `notifications/threads/${threadId}`,
  ], {
    stdout: 'pipe',
    stderr: 'pipe',
  });

  return result.exitCode === 0;
}

async function main() {
  const args = process.argv.slice(2);
  const dryRun = args.includes('--dry-run');

  if (dryRun) {
    console.log('🔍 Running in DRY RUN mode - no notifications will be deleted\n');
  }

  console.log('📥 Fetching GitHub notifications...\n');

  try {
    const notifications = await fetchNotifications();

    if (notifications.length === 0) {
      console.log('✅ No notifications found');
      return;
    }

    console.log(`Found ${notifications.length} notification(s):\n`);

    for (const notif of notifications) {
      console.log(`  📌 ${notif.subject.title}`);
      console.log(`     Repository: ${notif.repository.full_name}`);
      console.log(`     ID: ${notif.id}\n`);
    }

    if (!dryRun) {
      console.log('🗑️  Deleting all notifications...\n');
    }

    let deleted = 0;
    let failed = 0;

    for (const notif of notifications) {
      const success = await deleteNotification(notif.id, dryRun);
      if (success) {
        deleted++;
        if (!dryRun) {
          console.log(`  ✓ Deleted: ${notif.subject.title}`);
        }
      } else {
        failed++;
        console.error(`  ✗ Failed to delete: ${notif.subject.title}`);
      }
    }

    console.log(`\n${dryRun ? '📊' : '✅'} Summary:`);
    console.log(`  ${dryRun ? 'Would delete' : 'Deleted'}: ${deleted}`);
    if (failed > 0) {
      console.log(`  Failed: ${failed}`);
    }

    if (dryRun) {
      console.log('\n💡 Run without --dry-run to actually delete these notifications');
    }

  } catch (error) {
    console.error('❌ Error:', error instanceof Error ? error.message : error);
    process.exit(1);
  }
}

main();
