# Kejapin - Complete Feature Analysis

## 🏠 **Core Platform:**
**Kejapin** is a location-intelligent property rental and sales marketplace for Kenya, featuring real-time commute analysis, property management, and rich messaging capabilities.

---

## 📱 **All Features Categorized**

### **1. AUTHENTICATION & ONBOARDING**
| Feature | Description | Screen/Component |
|---------|-------------|------------------|
| Splash Screen | App initialization with branding | `splash_screen.dart` |
| Onboarding | Interactive introduction to app features | `onboarding_screen.dart` |
| Email/Password Login | Standard authentication | `login_screen.dart` |
| Email/Password Registration | User account creation | `register_screen.dart` |
| Email Verification | Verify email after registration | `verify_email_pending_screen.dart` |
| Forgot Password | Password recovery flow | `forgot_password_screen.dart` |
| Reset Password | Set new password | `reset_password_screen.dart` |
| Role Selection | TENANT, LANDLORD, ADMIN, AGENT | During registration |
| Multi-language Support | English, Swahili Sanifu, Swahili Kenyan | Throughout app |

---

### **2. PROPERTY MARKETPLACE (CORE)**
| Feature | Description | Premium Eligible? |
|---------|-------------|-------------------|
| Property Browsing | View all available properties | ✅ Free |
| Property Search | Search by title/location | ✅ Free |
| Property Filters | Filter by type, price, amenities, status | ✅ Free (Basic) / 💎 Premium (Advanced) |
| Property Types | Bedsitter, 1BHK, 2BHK, SQ, Bungalow | ✅ Free |
| Listing Types | Rent or Sale | ✅ Free |
| Property Details View | Full property information | ✅ Free |
| Image Gallery | Multiple photos per property | ✅ Free |
| Save/Favorite Properties | Pin properties to your list | ✅ Free (Limited) / 💎 Premium (Unlimited) |
| Saved Listings Screen | View all saved properties | ✅ Free |
| Property Owner Info | Contact landlord/agent | ✅ Free |
| Property Status | Available, Occupied, Sold | ✅ Free |

---

###

 **3. LIFE PINS & COMMUTE ANALYSIS** ⭐
| Feature | Description | Premium Eligible? |
|---------|-------------|-------------------|
| Life Pins Creation | Pin important locations (work, school, gym) | ✅ Free (Max 3) / 💎 Premium (Unlimited) |
| Life Pins Management | Add, edit, delete life pins | ✅ Free |
| Transport Modes | Walk, Drive, Cycle, Public Transport | ✅ Free |
| Real-time Commute Calculation | Live travel time & distance to life pins | 💎 Premium |
| Route Visualization | See routes on map | 💎 Premium |
| Commute Comparison | Compare commutes from multiple properties | 💎 Premium |
| OpenStreetMap Integration | Accurate routing data | ✅ Free (Basic Maps) / 💎 Premium (Routing) |
| Infrastructure Stats | Schools, hospitals, transport nearby | 💎 Premium |
| Efficiency Scoring | Rate properties by commute efficiency | 💎 Premium |

---

### **4. MESSAGING & CHAT** ⭐
| Feature | Description | Premium Eligible? |
|---------|-------------|-------------------|
| **Basic Messaging** |
| Text Messages | Send/receive text messages | ✅ Free |
| Message List | View all conversations | ✅ Free |
| Unread Message Count | See unread badges | ✅ Free |
| Real-time Updates | Live message streaming | ✅ Free |
| Read Receipts | Mark messages as read | ✅ Free |
| **Rich Attachments** |
| Property Sharing | Share property listings in chat | ✅ Free |
| Image Sharing (Gallery) | Send images from gallery | ✅ Free (5/day) / 💎 Premium (Unlimited) |
| Image Sharing (Camera) | Take & send photos | ✅ Free (5/day) / 💎 Premium (Unlimited) |
| Location Sharing | Share GPS location with map | 💎 Premium |
| Payment Requests | Request rent/utility/deposits | 💎 Premium |
| Schedule Appointments | Book viewings/meetings | ✅ Free (Basic) / 💎 Premium (Calendar sync) |
| Document Sharing | Send PDF/DOC/DOCX files | 💎 Premium |
| Repair Requests | Submit maintenance requests | ✅ Free |
| **Chat UX** |
| Mobile Background | Beautiful landscape background | ✅ Free |
| Full-screen Chat | No bottom nav in chat | ✅ Free |
| Inline Upload Progress | See upload status | ✅ Free |

---

### **5. NOTIFICATIONS**
| Feature | Description | Premium Eligible? |
|---------|-------------|-------------------|
| In-app Notifications | See all notifications | ✅ Free |
| Push Notifications | Real-time alerts | 💎 Premium |
| Notification Types | Messages, Favorites, Appointments, Payments | ✅ Free (Limited) / 💎 Premium (All) |
| Notification Settings | Customize preferences | ✅ Free |

---

### **6. USER PROFILE & SETTINGS**
| Feature | Description | Premium Eligible? |
|---------|-------------|-------------------|
| Profile View | View own profile | ✅ Free |
| Edit Profile | Update name, photo, bio, username | ✅ Free |
| Profile Completion | Track profile progress | ✅ Free |
| Account Security | Manage password, 2FA | ✅ Free |
| Payment Methods | Manage payment options | ✅ Free (View) / 💎 Premium (Multiple methods) |
| Settings Dashboard | Access all settings | ✅ Free |
| Help & Support | Submit support tickets | ✅ Free (Limited) / 💎 Premium (Priority) |
| Support Tickets | Track support requests | 💎 Premium |

---

### **7. LANDLORD FEATURES** 🏗️
| Feature | Description | Premium Eligible? |
|---------|-------------|-------------------|
| **Property Management** |
| Create Listing | Post new properties | ✅ Free (Max 3) / 💎 Premium (Unlimited) |
| Edit Listing | Update property details | ✅ Free |
| Delete Listing | Remove properties | ✅ Free |
| Manage Listings Dashboard | View all owned properties | ✅ Free |
| Property Analytics | Views, saves, messages count | 💎 Premium |
| **Landlord Tools** |
| Landlord Application | Apply for landlord status | ✅ Free |
| Landlord Dashboard | Overview of all properties & tenants | ✅ Free (Basic) / 💎 Premium (Analytics) |
| Vacancy Management | Mark properties as occupied/available | ✅ Free |
| Rent Collection Tracking | Track payment requests | 💎 Premium |

---

### **8. TENANT FEATURES**
| Feature | Description | Premium Eligible? |
|---------|-------------|-------------------|
| Tenant Dashboard | Overview of saved properties & messages | ✅ Free |
| Property Reviews | Write & view reviews | ✅ Free (View) / 💎 Premium (Write unlimited) |
| Review System | Rate properties | ✅ Free (1/month) / 💎 Premium (Unlimited) |
| Life Pins Integration | See commutes from dashboard | 💎 Premium |

---

### **9. ADMIN FEATURES** 👑
| Feature | Description | Premium Eligible? |
|---------|-------------|-------------------|
| Admin Dashboard | System overview | N/A (Admin only) |
| User Management | Manage users | N/A |
| Verification System | Approve landlord applications | N/A |
| Verification List | View all pending applications | N/A |
| Verification Details | Review application documents | N/A |
| Content Moderation | Flag/remove inappropriate content | N/A |
| Support Ticket Management | Handle user support | N/A |
| Component Gallery | UI testing screen | N/A |

---

### **10. SEARCH & DISCOVERY**
| Feature | Description | Premium Eligible? |
|---------|-------------|-------------------|
| Quick Search | Search from main screen | ✅ Free |
| Advanced Search | Multiple filters | 💎 Premium |
| Search Results | View filtered results | ✅ Free |
| Map View | Browse properties on map | ✅ Free (Basic) / 💎 Premium (Clusters & heatmaps) |
| Nearby Search | Find properties near location | 💎 Premium |
| Saved Searches | Save filter preferences | 💎 Premium |

---

### **11. PAYMENTS & TRANSACTIONS** 💳
| Feature | Description | Premium Eligible? |
|---------|-------------|-------------------|
| Payment Methods Management | Add/remove payment methods | ✅ Free |
| Payment Requests (In-chat) | Request payments via chat | 💎 Premium |
| Paystack Integration | Secure payment processing | ✅ Free (Transactions only) / 💎 (Subscriptions) |
| Transaction History | View past payments | 💎 Premium |

---

### **12. DATA & DATABASE**
| Table | Purpose | Related Features |
|-------|---------|------------------|
| `users` | User accounts & roles | Auth, Profile |
| `properties` | Property listings | Marketplace, Landlord |
| `messages` | Chat messages with rich content | Messaging |
| `notifications` | System notifications | Notifications |
| `life_pins` | User's important locations | Life Pins, Commute |
| `saved_listings` | Favorited properties | Saved Properties |
| `role_applications` | Landlord verification requests | Landlord Application |
| `user_settings` | User preferences | Settings |
| `payment_methods` | Stored payment info | Payments |
| `support_tickets` | Help requests | Support |
| `osm_nodes`, `osm_ways`, `osm_relations` | OpenStreetMap data | Routing, Maps |

---

## 🎯 **Unique Selling Points (USPs)**

1. **Life-Centric Property Search** - Find homes based on YOUR daily commute, not just location
2. **Real-time Commute Analysis** - See exact travel times to work, school, gym before renting
3. **Rich Messaging** - Share properties, request payments, schedule viewings in one chat
4. **Kenyan-First** - Swahili language, KES currency, local payment methods (M-Pesa via Paystack)
5. **OpenStreetMap Integration** - Accurate local routing data for Kenya
6. **Multi-Role System** - Supports tenants, landlords, agents, and admins
7. **Offline-First Architecture** - Works smoothly even with poor connectivity

---

## 📊 **Feature Count Summary**

| Category | Total Features | Free Features | Premium Features |
|----------|----------------|---------------|------------------|
| Authentication | 8 | 8 | 0 |
| Marketplace | 11 | 8 | 3 |
| Life Pins & Commute | 9 | 3 | 6 |
| Messaging | 17 | 9 | 8 |
| Notifications | 4 | 2 | 2 |
| Profile & Settings | 8 | 6 | 2 |
| Landlord Features | 8 | 5 | 3 |
| Tenant Features | 4 | 2 | 2 |
| Search & Discovery | 6 | 3 | 3 |
| Payments | 4 | 1 | 3 |
| **TOTAL** | **79** | **47** | **32** |

---

## 🔮 **Potential Future Features**

1. **Virtual Property Tours** (360° photos/videos)
2. **AI Chatbot** for property recommendations
3. **Lease Management** (digital contracts, e-signatures)
4. **Maintenance Tracking** (for landlords & tenants)
5. **Community Reviews** (neighborhood ratings)
6. **Price Alerts** (notify when prices drop)
7. **Roommate Matching**
8. **Move-in Checklists**
9. **Rent Payment Integration** (auto-deduct via M-Pesa)
10. **Property Insurance Marketplace**

---

**Next Step:** Create subscription tiers and pricing strategy based on this analysis.
