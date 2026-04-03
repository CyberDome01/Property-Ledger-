# PropertyLedger

Rental property accounting — track income & expenses, generate Schedule E tax reports in minutes. No banking products. No hidden agenda.

## Stack

- **Next.js 14** (App Router, Server Components)
- **Supabase** — Postgres + auth + row-level security (schema: `pl`)
- **Stripe** — subscriptions with Checkout + Customer Portal
- **Tailwind CSS** — utility-first styling
- **Recharts** — dashboard and report charts
- **Vercel** — recommended deployment target

## Features

- Dashboard with monthly income/expense chart
- Property management with per-property financials
- Transaction tracking — IRS Schedule E category mapping
- Lease & tenant tracking with expiry alerts
- Schedule E report — auto-generated, per property + grand total, printable + CSV export
- Depreciation calculator — IRS 27.5yr/39yr straight-line, mid-month convention
- Occupancy tracking — see vacant/occupied/expiring units
- CSV export for all transactions and Schedule E
- Stripe billing — Starter / Pro / Portfolio plans, monthly + annual

## Setup

### 1. Clone and install

```bash
git clone https://github.com/YOUR_USERNAME/property-ledger.git
cd property-ledger
npm install
```

### 2. Environment variables

Copy `.env.example` to `.env.local` and fill in all values:

```bash
cp .env.example .env.local
```

Required variables:
- `NEXT_PUBLIC_SUPABASE_URL` — from Supabase project settings
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` — from Supabase project settings
- `SUPABASE_SERVICE_ROLE_KEY` — from Supabase project settings (keep secret)
- `STRIPE_SECRET_KEY` — from Stripe dashboard
- `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY` — from Stripe dashboard
- `STRIPE_WEBHOOK_SECRET` — from Stripe webhook config
- `STRIPE_PRICE_*` — create products/prices in Stripe, paste IDs here
- `NEXT_PUBLIC_APP_URL` — your production URL

### 3. Supabase

The schema is already deployed to your project under the `pl` schema.
All tables: `pl.profiles`, `pl.subscriptions`, `pl.properties`, `pl.transactions`, `pl.leases`

To apply storage migrations manually:
```bash
npx supabase db push
```

### 4. Stripe setup

1. Create 3 products in Stripe Dashboard: **Starter**, **Pro**, **Portfolio**
2. For each product, create a monthly price and an annual price
3. Paste the price IDs into `.env.local`
4. Set up a webhook pointing to `https://yourdomain.com/api/stripe/webhook`
5. Enable these webhook events:
   - `checkout.session.completed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_failed`

### 5. Run locally

```bash
npm run dev
```

Visit `http://localhost:3000`

## Deploying to Netlify

### Option A — Netlify dashboard (easiest)

1. Go to [app.netlify.com](https://app.netlify.com) → **Add new site** → **Import an existing project**
2. Connect GitHub and select the `property-ledger` repo
3. Build settings are auto-detected from `netlify.toml` — no changes needed:
   - Build command: `npm run build`
   - Publish directory: `.next`
4. Under **Environment variables**, add everything from `.env.example`
5. Click **Deploy site**
6. Once live, update `NEXT_PUBLIC_APP_URL` to your Netlify domain

### Option B — Netlify CLI

```bash
npm install -g netlify-cli
netlify login
netlify init          # link to your Netlify site
netlify env:import .env.local
netlify deploy --prod
```

### Stripe webhook

Point your Stripe webhook to: `https://your-app.netlify.app/api/stripe/webhook`

Enable these events:
- `checkout.session.completed`
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`
- `invoice.payment_failed`

### GitHub Actions CI/CD (auto-deploy on push)

Add these secrets in your GitHub repo → Settings → Secrets:
- `NETLIFY_AUTH_TOKEN` — from [app.netlify.com/user/applications](https://app.netlify.com/user/applications)
- `NETLIFY_SITE_ID` — from Netlify site settings → General → Site ID
- All env vars from `.env.example`

## Database schema (pl schema)

```
pl.profiles          — user name, email, avatar
pl.subscriptions     — Stripe plan, status, trial dates
pl.properties        — address, type, rent, purchase info
pl.transactions      — income/expenses with Schedule E categories
pl.leases            — tenants, dates, rent, deposits
```

All tables have Row Level Security — users can only access their own data.
Service role bypasses RLS for Stripe webhook subscription sync.

## Tax categories

Income: Rent received, Late fees, Pet fees, Parking, Laundry, Storage, Lease termination, Other

Expenses (IRS Schedule E lines 5–19):
Advertising (5), Auto and travel (6), Cleaning and maintenance (7), Commissions (8),
Insurance (9), Legal and professional fees (10), Management fees (11),
Mortgage interest — banks (12), Other interest (13), Repairs (14), Supplies (15),
Taxes (16), Utilities (17), Depreciation (18), Other expenses (19)

## License

MIT
