# Multi-Role Dashboard & Verification System Implementation Plan

This document outlines the architecture and steps for implementing the Tenant, Landlord, and Admin dashboards, along with the automated verification workflow.

## 1. Database Schema Extensions (Supabase SQL)

### 1.1 `properties` Table (Full Schema for ListingCard & Details)
Based on current UI requirements, the table must include:
- `id`, `title`, `description` (Text/UUID)
- `property_type` (Enum: APARTMENT, HOUSE, STUDIO, etc.)
- `listing_type` (Enum: RENT, SALE)
- `price_amount`, `purchase_price` (Numeric)
- `rent_period` (Enum: MONTHLY, WEEKLY, DAILY)
- `is_for_rent`, `is_for_sale` (Boolean)
- `address_line_1`, `city`, `county` (Text)
- `latitude`, `longitude` (Float8)
- `photos` (Text[] or JSONB)
- `amenities` (Text[] or JSONB - e.g. ["WiFi", "Pool", "Gym"])
- `bedrooms`, `bathrooms`, `sqft` (Integer)
- `owner_id` (Reference to `profiles.id`)
- `rating`, `review_count` (Numeric/Integer - computed or stored)
- `efficiency_stats` (JSONB - for the 10-dimensional neural pulse)
- `status` (Enum: ACTIVE, PAUSED, RENTED, SOLD)
- `is_verified` (Boolean - verified by Admin)

### 1.2 `leases_and_orders` Table
Tracks the relationship between a tenant and a property:
- `id`, `tenant_id`, `property_id`
- `status` (Enum: VIEWING_REQUESTED, APPLICATION_PENDING, ACTIVE_LEASE, COMPLETED)
- `start_date`, `end_date`
- `agreed_price` (Numeric)

### 1.3 `reviews` Table
- `id`, `user_id`, `property_id`
- `rating` (1-5)
- `comment` (Text)
- `created_at`

### 1.4 `profiles` Table Updates
- `role`: Enum ('TENANT', 'LANDLORD', 'ADMIN'). Default 'TENANT'.
- `verification_status`: Enum ('PENDING', 'VERIFIED', 'REJECTED', 'WARNING').
- `is_active`: Boolean. Default `true`.
- `deactivation_reason`: Text.
- `application_attempts`: Integer. Default 0 (Max 3).

### 1.2 `role_applications` Table (Tracking history)
- `id`: UUID.
- `user_id`: Reference to `profiles.id`.
- `role_requested`: Enum.
- `documents`: JSONB (URLs to ID scans, live selfies, certificates).
- `status`: Enum.
- `admin_notes`: Text.

## 2. Multi-Role Navigation System (Flutter)
We will implement a `DynamicShell` or `RoleGuard` to handle the side-navigation logic.

- **Admin Logic**: Hardcoded check for `kejapinmail@gmail.com`. If current user matches, the "Admin Panel" route appears in the Drawer.
- **Drawer Elements**:
    - **Shared**: Marketplace (Home), Profile, Settings, Notifications, Logout.
    - **Tenant specific**: My Activity, Saved Homes, Budget Analysis.
    - **Landlord specific**: My Properties, Leads/Messages, Revenue Analytics, Add Listing.
    - **Admin specific**: Global Verification, Platform Metrics, User Management.

## 3. Role Application Workflow (Verifications)
A multi-step, premium UI for users wanting to become Landlords.

### 3.1 Verification Screen (Frontend)
- **Step 1**: Personal Details confirmation.
- **Step 2**: Document Upload (ID/Passport).
- **Step 3**: Live Selfie (Camera integration with face detection overlay).
- **Step 4**: Submission & Auto-Approval Logic.

### 3.2 Verification Logic (Backend/Flutter)
- Upon submission, a record is created in `role_applications`.
- **Auto-Approval**: The user's profile `role` is immediately updated to `LANDLORD` to allow instant access.
- **Admin Alert**: A `SYSTEM` notification is sent to the Admin (kejapinmail@gmail.com) alerting them of a new application needing review.

## 4. Dashboard Implementation (Premium UI)

### 4.1 UI Design Philosophy
- **Glassmorphism**: Consistent with the current theme.
- **Looping Animations**: Subtle background mesh movements or pulsing status indicators.
- **Adaptive Padding**: Ensuring screens look great on Mobile and Desktop.

### 4.2 Analytics Module (The "Wow" Factor)
- **Library**: `fl_chart` for raw data, wrapped in custom animated containers.
- **Custom Components**:
    - **Spatial Pulse History**: How property efficiency scores have changed.
    - **Revenue/Spending Curves**: Smooth, glowing lines with interactive touch points.
    - **Occupancy Radars**: For landlords to see property performance.

## 5. Advanced Features & Modules

### 5.1 Listing Creation Wizard (Landlord Power Tool)
This won't be a boring long form. It will be a **Multi-Step Cinematic Wizard**:
- **Step 1: The Basics (What & Where)**: Title, type, price, and exact location (Map-pick with auto-address lookup).
- **Step 2: Amenities & Specs**: Interactive chips for beds, baths, wifi, etc.
- **Step 3: Visual Identity**: Dragon-drop image gallery with re-ordering and "Primary Image" selection.
- **Step 4: The Pulse Preview**: A real-time preview of how the "Efficiency Pulse" looks before the listing goes live. 
- **Management Hook**: Edit, Pause (Delist), and Duplicate features for existing listings.

### 5.2 Company & Entity Profiles (Institutional Presence)
Agents and large landlords often operate as companies.
- **Storefront Screen**: A dedicated public page for companies showing their bio, logo, verified badge, and all active listings.
- **Team Management (Landlord Dashboard)**: Allow a Landlord to invite "Agent" emails to help manage their properties (Shared dashboard access).
- **Branding Suite**: Capability to upload brand colors that subtly theme the Landlord's listing cards.

### 5.3 Booking & Viewing System
- **Schedule Modal**: Landlords set "Available Viewing Slots".
- **Tenant Request**: Tenants click "Book Viewing" and pick a slot. This triggers an in-app message and a notification to the Landlord.
- **Status Tracking**: 'Requested' -> 'Confirmed' -> 'Viewed' -> 'Application Started'.

### 5.4 AI-Assist (Premium Feature)
- **AI Describer**: A button that generates a catchy description based on the amenities and spatial pulse of the location.
- **Price Benchmarking**: Suggesting a price based on the neighborhood's average living efficiency vs. this property's score.

## 6. Admin Panel "God Mode"
- **Global Moderation**: View all reports (Tenants flagging listings for being fake/scams).
- **User Analytics**: New users per day, conversion rates from Tenant to Landlord.
- **Revenue Tracker**: Track hypothetical/real platform commissions or subscription tiers.
- **System Health**: View logs and active Supabase connections.

## 7. The Detailed Screen Map

### 7.1 Tenant Dashboard (The Lifestyle Hub)
- **Home**: Welcome card with "Your Current Pulse" (Avg. efficiency of saved homes) and a search shortcut.
- **Life-Path Journey (Timeline)**: A premium scrolling timeline showing:
    - *Requested Viewings*: (Glass cards with status 'Waiting for Landlord').
    - *Active Stay*: If they have an active lease (Shows "My Home" with quick utilities).
    - *Past Stays*: Properties they've lived in, with a "Rate Now" floating button if not yet reviewed.
- **Compare Pulse Tool**: A screen where they select 2-3 saved properties and see their 10D pulses overlaid in a radar chart or stacked bars to make a final move decision.
- **Budget & Savings**: Simple charts showing rent history and projected savings if they move to a more efficient location.

### 7.2 Landlord/Agent Dashboard (The Business Suite)
- **Inventory Control**: Grid of active listing cards with "Pause" or "Edit" buttons.
- **Lead Pipeline**: Kanban-style board (Requested -> Confirmed -> Viewed -> Rented).
- **Listing Management (Full Modal/Screen)**:
    - Advanced controls: Set viewing hours, toggle "Verified Location" status.
    - Performance stats: "This property was saved 45 times this week".
- **Company Storefront Setup**: Editor for logo, brand banner, and team (agent) management.

### 7.3 Admin Panel (The Command Center)
- **Moderation Queue**: Flagged listings or users with "Strike" system.
- **Verification Desk**: Side-by-side view of User's "Live Photo" vs. "ID Document". 
- **Platform Analytics**: Multi-colored animated charts for total marketplace volume and growth velocity.

## 8. Implementation Stages

### Stage 1: Core Infra (DB & Backend)
- Run SQL migrations for tables and RLS policies.
- Update `AuthRepository` and `ProfileRepository` to handle role-based data.

### Stage 2: Verification Flow
- Build the `ApplyToLandlordScreen`.
- Implement camera integration for "live photo".
- Implement the "Auto-Approve" repository logic.

### Stage 3: The Dashboards (UI)
- Create `TenantDashboardScreen`.
- Create `LandlordDashboardScreen`.
- Create `AdminDashboardScreen` (Route limited to `kejapinmail@gmail.com`).

### Stage 4: Analytics Implementation
- Build the premium charting components with looping animations.
- Integrate real/simulated data pipelines for the dashboards.

### Stage 5: Notifications & Lifecycle
- Implement specific notification triggers for approvals, warnings, and deactivations.
- Test the "3-try limit" logic for applications.

## 7. Approval Requested
Please review the plan above. Once approved, I will start with **Stage 1: SQL Migrations and Profile Updates**.
