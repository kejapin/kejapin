# Kejapin Subscription Plans & Pricing Strategy

## 💰 **Subscription Tiers**

### **FREE (Mpangaji)** - KES 0/month
*Perfect for casual property hunters*

#### ✅ **Included Features:**
**Marketplace & Search:**
- Browse unlimited properties
- Basic search & filters (property type, location)
- View property details & photos
- Save up to **10 properties**
- View property owner contact

**Life Pins:**
- Create up to **3 Life Pins** (work, school, etc.)
- Basic map view (no routing)

**Messaging:**
- Unlimited text messages
- Share properties in chat
- Send images: **5 per day**
- Basic repair requests
- Basic appointment scheduling (no calendar sync)

**Profile & Account:**
- Full profile management
- Account security settings
- Community support (email)

**Landlord (if applicable):**
- List up to **3 properties**
- Basic listing management
- View listing status

**Reviews:**
- Read unlimited reviews
- Write **1 review per month**

---

### **PREMIUM (Mwenyeji)** - KES 499/month or KES 4,990/year
*For serious renters & active landlords*

#### ⭐ **Everything in Free, PLUS:**

**Enhanced Property Discovery:**
- **Advanced filters** (amenities, furnishing, availability, sqft range)
- **Saved searches** (get alerts for new matches)
- **Unlimited saved properties**
- **Map clusters & heatmaps**
- **Nearby search** (find properties near 
any location)
- **Priority listing appearance** (your saved properties get highlighted)

**Life Pins & Commute Intelligence:**
- **Unlimited Life Pins**
- **Real-time commute calculation** (walk, drive, cycle, public transport)
- **Route visualization** on map
- **Commute comparison** across multiple properties
- **Infrastructure stats** (schools, hospitals, transport within 5km)
- **Efficiency scoring** (rate properties by commute time)
- **Commute alerts** (get notified if commute changes)

**Advanced Messaging:**
- **Unlimited image uploads**
- **Location sharing** with live map preview
- **Payment requests** (rent, utilities, deposits)
- **Document sharing** (PDFs, DOCs)
- **Schedule appointments** with calendar sync
- **Priority message delivery**

**Notifications:**
- **Push notifications** for new messages, property alerts
- **Custom notification preferences**
- **Email summaries** (daily/weekly)

**Landlord Premium:**
- **Unlimited property listings**
- **Property analytics dashboard** (views, saves, inquiries)
- **Rent collection tracking**
- **Vacancy alerts**
- **Featured listings** (appear at top of search)
- **Bulk import** listings via CSV

**Tenant Premium:**
- **Unlimited reviews**
- **Commute-based recommendations**
- **Price drop alerts**
- **Move-in checklist templates**

**Profile & Support:**
- **Multiple payment methods**
- **Priority customer support** (24-48hr response)
- **Support ticket tracking**
- **Transaction history**

**Exclusive:**
- **Download property reports** (PDF with all details + commute analysis)
- **Ad-free experience**
- **Early access to new features**

---

### **PROFESSIONAL (Msimamizi)** - KES 2,499/month or KES 24,990/year
*For property managers & agents*

#### 💼 **Everything in Premium, PLUS:**

**Multi-Property Management:**
- **Unlimited listings** across multiple owners
- **Team collaboration** (add assistant managers)
- **Bulk operations** (update multiple listings at once)
- **Advanced analytics** (occupancy rates, revenue tracking)

**Tenant Management:**
- **Tenant database** with payment history
- **Lease tracking** (expiry alerts)
- **Maintenance request management**
- **Automated reminders** (rent due, lease renewal)

**Marketing Tools:**
- **Featured listings** (3x visibility boost)
- **Social media sharing** (auto-post to Facebook, Instagram)
- **QR codes** for open houses
- **Virtual tour support** (embed 360° photos)

**Financial Tools:**
- **Invoice generation**
- **Payment tracking** (sync with M-Pesa statements)
- **Financial reports** (monthly, quarterly, annual)
- **Tax-ready reports**

**API Access:**
- **REST API access** (integrate with property management software)
- **Webhook notifications**
- **Custom integrations**

**Premium Support:**
- **Dedicated account manager**
- **Priority support** (4-12hr response)
- **Phone support**
- **Monthly strategy calls**

---

## 💳 **Paystack Integration Plan**

### **Paystack Products to Use:**

1. **Subscriptions API** - Recurring billing
2. **Payment Pages** - Hosted checkout for subscriptions
3. **M-Pesa Integration** - Local payment method
4. **Card Payments** - Visa, Mastercard
5. **Bank Transfer** - Direct bank payments
6. **Transaction API** - One-time payments (rent, deposits)

### **Payment Methods Offered:**

| Method | Availability | Processing Fee |
|--------|--------------|----------------|
| M-Pesa | ✅ All plans | 1.5% + KES 25 |
| Visa/Mastercard | ✅ All plans | 2.9% + KES 30 |
| Bank Transfer | ✅ All plans | KES 50 flat |
| Airtel Money | ✅ All plans | 1.5% + KES 25 |

---

## 📊 **Pricing Strategy Breakdown**

### **Monthly vs Annual Savings:**

| Plan | Monthly | Annual | Annual Savings | % Discount |
|------|---------|--------|----------------|------------|
| **Premium** | KES 499 | KES 4,990 | KES 998 | **17% OFF** (2 months free) |
| **Professional** | KES 2,499 | KES 24,990 | KES 4,998 | **17% OFF** (2 months free) |

### **Target Audience:**

- **Free:** 70% of users (casual browsers, occasional renters)
- **Premium:** 25% of users (active renters, small landlords)
- **Professional:** 5% of users (property managers, agents, large landlords)

### **Revenue Projections (Year 1):**

Assuming 10,000 total users:
- **Free:** 7,000 users × KES 0 = **KES 0**
- **Premium Monthly:** 1,750 users × KES 499 = **KES 872,750/month**
- **Premium Annual:** 750 users × KES 4,990/year ÷ 12 = **KES 311,875/month**
- **Professional Monthly:** 400 users × KES 2,499 = **KES 999,600/month**
- **Professional Annual:** 100 users × KES 24,990/year ÷ 12 = **KES 208,250/month**

**Total Monthly Revenue:** KES 2,392,475  
**Total Annual Revenue:** KES 28,709,700

---

## 🎁 **Promotions & Discounts**

### **Launch Offers:**
1. **Early Bird:** First 1,000 Premium subscribers get **50% off for 3 months**
2. **Referral Program:** Refer a friend, both get **1 month free Premium**
3. **Student Discount:** **30% off Premium** with valid student ID
4. **Landlord Loyalty:** List 5+ properties, get **Premium free for 6 months**

### **Seasonal Campaigns:**
1. **January (New Year):** "New Home, New You" - **25% off annual plans**
2. **June-July (Mid-year):** "Halfway Home" - **Free upgrade to Premium for 1 month**
3. **December:** "Gift Premium" - Buy annual subscription, gift 3 months to a friend

---

## 🚀 **Implementation Roadmap**

### **Phase 1: Foundation (Month 1-2)**
- [ ] Integrate Paystack SDK for Flutter
- [ ] Create subscription management backend (Go)
- [ ] Database schema updates (`subscriptions`, `transactions` tables)
- [ ] Implement subscription middleware (check tier before features)
- [ ] Payment methods screen UI
- [ ] Subscription selection screen

### **Phase 2: Payment Flow (Month 2-3)**
- [ ] Paystack subscription creation
- [ ] M-Pesa payment flow
- [ ] Card payment flow
- [ ] Bank transfer instructions
- [ ] Payment confirmation handling
- [ ] Receipt generation & email
- [ ] Subscription status tracking

### **Phase 3: Feature Gating (Month 3-4)**
- [ ] Life Pins limit enforcement (3 for free)
- [ ] Saved properties limit (10 for free)
- [ ] Image upload daily limit (5 for free)
- [ ] Premium features unlock upon subscription
- [ ] "Upgrade to Premium" prompts throughout app
- [ ] Trial period (7 days free Premium)

### **Phase 4: Landlord & Analytics (Month 4-5)**
- [ ] Listing limit enforcement (3 for free)
- [ ] Property analytics dashboard (Premium)
- [ ] Featured listings algorithm
- [ ] Bulk operations for Professional
- [ ] Team management for Professional

### **Phase 5: Polish & Launch (Month 5-6)**
- [ ] Subscription management screen (view, cancel, upgrade)
- [ ] Invoice & receipt downloads
- [ ] Refund handling
- [ ] Subscription renewal reminders
- [ ] Churn reduction campaigns
- [ ] Analytics dashboard for admin

---

## 📐 **Database Schema Changes**

### **New Tables:**

```sql
-- Subscriptions table
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) NOT NULL,
  plan_name TEXT NOT NULL CHECK (plan_name IN ('FREE', 'PREMIUM', 'PROFESSIONAL')),
  billing_cycle TEXT NOT NULL CHECK (billing_cycle IN ('MONTHLY', 'ANNUAL')),
  status TEXT NOT NULL CHECK (status IN ('ACTIVE', 'CANCELED', 'EXPIRED', 'TRIAL')),
  paystack_subscription_code TEXT,
  current_period_start TIMESTAMP WITH TIME ZONE,
  current_period_end TIMESTAMP WITH TIME ZONE,
  trial_ends_at TIMESTAMP WITH TIME ZONE,
  canceled_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Transactions table
CREATE TABLE IF NOT EXISTS public.transactions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) NOT NULL,
  subscription_id UUID REFERENCES public.subscriptions(id),
  paystack_reference TEXT UNIQUE,
  amount DECIMAL(12, 2) NOT NULL,
  currency TEXT DEFAULT 'KES',
  payment_method TEXT,
  status TEXT NOT NULL CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED')),
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Update users table
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS subscription_tier TEXT DEFAULT 'FREE' CHECK (subscription_tier IN ('FREE', 'PREMIUM', 'PROFESSIONAL'));
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS subscription_status TEXT DEFAULT 'NONE' CHECK (subscription_status IN ('NONE', 'ACTIVE', 'TRIAL', 'EXPIRED', 'CANCELED'));
```

---

## 🎨 **UI/UX Components Needed**

1. **SubscriptionPlansScreen** - Compare plans side-by-side
2. **PaymentMethodsScreen** - Select M-Pesa, Card, Bank
3. **CheckoutScreen** - Paystack hosted page integration
4. **SubscriptionManagementScreen** - View current plan, cancel, upgrade
5. **UpgradePromptDialog** - Show when hitting free tier limits
6. **FeatureLockedWidget** - Blur/lock premium features with upgrade CTA
7. **TrialBanner** - Show days remaining in trial
8. **ReceiptScreen** - View payment receipts

---

## 📱 **Marketing Strategy**

### **Value Proposition by Tier:**

**Free (Mpangaji):**
> "Find your perfect home in Kenya, completely free. Browse thousands of properties and connect directly with landlords."

**Premium (Mwenyeji):**
> "Find a home that fits your life. See exact commute times to work, save unlimited properties, and message landlords with rich attachments. Only KES 499/month."

**Professional (Msimamizi):**
> "Manage your entire property portfolio in one place. Track rent, manage tenants, and grow your business. KES 2,499/month."

---

## 🔒 **Fair Usage Policy**

Even free users get core value, but with sensible limits:
- **10 saved properties** - Enough for serious comparison
- **3 Life Pins** - Work, home, school/gym
- **5 images/day** - Share property photos without spam
- **1 review/month** - Prevent fake review farms

Premium unlocks **productivity** (unlimited saves, images, reviews) and **intelligence** (commute analysis, price alerts).

---

**Next Steps:**
1. Review and approve pricing strategy
2. Begin Paystack integration (Flutter SDK + Go backend)
3. Create UI screens for subscription management
4. Implement feature gating logic
5. Launch with aggressive Early Bird promotion

**Paystack Integration Cost:**
- Transaction fees only (no monthly fee)
- 1.5-2.9% per transaction
- Estimated monthly fees (at 10,000 users): ~KES 70,000/month
- **Net Revenue:** KES 2,322,475/month
