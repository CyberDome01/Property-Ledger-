#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# PropertyLedger — GitHub setup script
#
# Usage:
#   chmod +x push-to-github.sh
#   ./push-to-github.sh
#
# Prerequisites:
#   - GitHub CLI installed: https://cli.github.com/
#   - Logged in: gh auth login
# ─────────────────────────────────────────────────────────────────────────────
set -e

REPO_NAME="property-ledger"
DESCRIPTION="Rental property accounting — Schedule E reports, depreciation, lease tracking"

echo ""
echo "PropertyLedger — pushing to GitHub"
echo "─────────────────────────────────────"

# Check for gh CLI
if ! command -v gh &> /dev/null; then
  echo "ERROR: GitHub CLI not found."
  echo "Install it from https://cli.github.com/ then run: gh auth login"
  exit 1
fi

# Init git if needed
if [ ! -d ".git" ]; then
  echo "Initialising git repository..."
  git init
  git branch -M main
fi

# Stage and commit
echo "Staging all files..."
git add -A
git commit -m "feat: initial PropertyLedger application

- Next.js 14 App Router with Supabase auth + RLS
- Properties, transactions, leases, Schedule E, reports
- Stripe billing — Starter / Pro / Portfolio plans
- Depreciation calculator (IRS 27.5yr/39yr straight-line)
- CSV export for transactions and Schedule E
- Occupancy tracking and lease expiry alerts
- Supabase schema under isolated 'pl' namespace
- GitHub Actions CI/CD for Vercel" 2>/dev/null || echo "Nothing new to commit."

# Create GitHub repo
echo "Creating GitHub repository: $REPO_NAME..."
gh repo create "$REPO_NAME" \
  --private \
  --description "$DESCRIPTION" \
  --source=. \
  --remote=origin \
  --push 2>/dev/null || {
    # Repo may already exist — just push
    echo "Repository may already exist. Pushing..."
    git remote add origin "https://github.com/$(gh api user --jq .login)/$REPO_NAME.git" 2>/dev/null || true
    git push -u origin main --force
  }

GITHUB_USER=$(gh api user --jq .login)

echo ""
echo "Done! Your repository is live:"
echo "  https://github.com/$GITHUB_USER/$REPO_NAME"
echo ""
echo "Next steps — deploy on Netlify:"
echo "  1. Go to https://app.netlify.com and click 'Add new site' → 'Import an existing project'"
echo "  2. Connect GitHub and select: $REPO_NAME"
echo "  3. Build settings are auto-detected from netlify.toml (no changes needed)"
echo "  4. Under 'Environment variables', add everything from .env.example"
echo "  5. Click 'Deploy site'"
echo ""
echo "  After deploy, set NEXT_PUBLIC_APP_URL to your Netlify domain (e.g. https://your-app.netlify.app)"
echo "  Then set up Stripe webhook pointing to: https://your-app.netlify.app/api/stripe/webhook"
echo ""
echo "For GitHub Actions CI/CD, add these two secrets in your GitHub repo settings:"
echo "  NETLIFY_AUTH_TOKEN  — from https://app.netlify.com/user/applications"
echo "  NETLIFY_SITE_ID     — from Netlify site settings → General → Site ID"
echo "  (plus all env vars from .env.example as GitHub secrets)"
