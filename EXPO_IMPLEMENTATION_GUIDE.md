# Kejapin Expo Implementation Guide: UI & Notifications

This guide provides technical details for implementing the **Kejapin** design system and notification architecture in a React Native Expo application.

---

## 🎨 UI & Design System

The Kejapin aesthetic is defined as **"Premium Real Estate"** with a "Modern-Classic" feel, characterized by rich earth tones, gold accents, and fluid glassmorphism.

### 1. Color Palette

```javascript
/* THEME CONFIGURATION */
export const Colors = {
  primary: '#4B3621',      // Structural Brown (Used for text, icons, and deep backgrounds)
  secondary: '#E6AF2E',    // Muted Gold (Used for buttons, unread indicators, and highlights)
  background: '#F4F1EA',   // Alabaster (Primary app background)
  surface: '#FFFFFF',      // Pure White (Used for cards and sheets)
  text: '#333333',         // Dark Grey (Body text)
  accent: '#6B8E23',       // Sage Green (Available status, success)
  error: '#B22222',        // Brick Red (Critical alerts, errors)
  glass: 'rgba(255, 255, 255, 0.15)', // Base glassmorphism color
};
```

### 2. Typography

Kejapin uses a tiered typography system:
- **Headings**: `Montserrat` (Bold, 400-700)
- **Body**: `Lato` (Regular, 300-500)
- **UI Labels**: `Work Sans` (Medium, 400-600)

**Expo Setup:**
Use `expo-font` and `@expo-google-fonts` to load these.
```bash
npx expo install expo-font @expo-google-fonts/montserrat @expo-google-fonts/lato @expo-google-fonts/work-sans
```

### 3. "Premium" UI Components (The "Wow" Factor)

#### A. Glassmorphism
In Expo, use `expo-blur`.

```tsx
import { BlurView } from 'expo-blur';
import { View, StyleSheet } from 'react-native';

const GlassContainer = ({ children, intensity = 20 }) => (
  <BlurView intensity={intensity} tint="light" style={styles.glass}>
    <View style={styles.content}>
      {children}
    </View>
  </BlurView>
);

const styles = StyleSheet.create({
  glass: {
    borderRadius: 16,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.2)',
  },
  content: {
    padding: 16,
  }
});
```

#### B. Mesh Gradients (Aurora Effect)
The Flutter app uses `AnimatedMeshGradient`. In Expo, the best way to achieve this premium fluid look is via `react-native-skia`.

**Recommendation**: Use a combination of `LinearGradient` from `expo-linear-gradient` for simple screens, or Skia's `Mesh` for the high-end landing page effect.

---

## 🔔 Notification System

The current Kejapin notification architecture is built for real-time engagement and deep-linking.

### 1. Data Structure
Notifications are stored in the database and fetched via API.

```json
{
  "id": "uuid",
  "user_id": "uuid",
  "title": "New Listing Match!",
  "message": "A 2BR Apartment in Kilimani just hit your price range.",
  "type": "MARKETPLACE", // MESSAGE, FINANCIAL, SYSTEM, MARKETPLACE
  "is_read": false,
  "route": "/marketplace/detail", // Deep link path
  "metadata": { "listing_id": "123" },
  "created_at": "timestamp"
}
```

### 2. Expo Implementation Strategy

#### A. Real-Time Updates (Current)
The Flutter app currently uses **Supabase Realtime Streams**. This is the most efficient way to implement this in Expo.

- **Expo Setup**: Use the `@supabase/supabase-js` library.
- **Example Hook**:
```javascript
useEffect(() => {
  const channel = supabase
    .channel('notifications-changes')
    .on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'notifications' },
      (payload) => {
        // Update local state or trigger a refresh
        console.log('Change received!', payload)
      }
    )
    .subscribe()

  return () => {
    supabase.removeChannel(channel)
  }
}, []);
```

#### B. Push Notifications
To implement native push notifications in Expo:
1.  **Service**: Use `expo-notifications`.
2.  **Provider**: Configure Firebase Cloud Messaging (FCM) or Apple Push Notification service (APNs).
3.  **Handling**: Use `Notifications.addNotificationResponseReceivedListener` to handle taps and navigation.

#### C. Deep Linking with Expo Router
Match the Flutter `go_router` logic using `expo-router`:

```javascript
// Inside your notification listener
const response = Notifications.useLastNotificationResponse();

useEffect(() => {
  if (response && response.actionIdentifier === Notifications.DEFAULT_ACTION_IDENTIFIER) {
    const { route, metadata } = response.notification.request.content.data;
    if (route) {
      router.push({
        pathname: route,
        params: metadata
      });
    }
  }
}, [response]);
```

### 3. Notification Categories & Colors
Match the visual cues used in the Flutter app:

| Type | Icon | Color Highlight |
| :--- | :--- | :--- |
| **MESSAGE** | Chat Bubble | `blueAccent` |
| **FINANCIAL** | Wallet | `greenAccent` |
| **SYSTEM** | Alert/Settings | `grey` |
| **FAVORITE** | Heart | `brickRed (#B22222)` |
| **MARKETPLACE** | Home | `mutedGold (#E6AF2E)` |

---

## ✨ Animations & Interactions

To replicate the fluid feel of the Flutter app, focus on these interactive elements:

### 1. Entrance Animations
The Flutter app uses `animate_do` (FadeInUp, FadeInLeft). In Expo, use **Moti** or **Reanimated**.

```tsx
import { MotiView } from 'moti';

// For list items
<MotiView
  from={{ opacity: 0, translateX: -20 }}
  animate={{ opacity: 1, translateX: 0 }}
  transition={{ delay: index * 50 }}
>
  <NotificationCard />
</MotiView>
```

### 2. Micro-interactions
- **Unread Indicator**: A gold dot (`#E6AF2E`) with a border blending into the background.
- **Dismissible Tiles**: Use `react-native-gesture-handler`'s `Swipeable` to allow users to swipe-to-dismiss notifications, matching the Flutter "Dismissible" widget.
- **Pull-to-Refresh**: Implementation of `RefreshControl` is essential for the notification list.

---

## 🚀 Technical Requirements for Implementation

1.  **State Management**: `Zustand` or `Redux Toolkit` (to mirror Flutter's `BLoC` predictability).
2.  **Animations**: `react-native-reanimated` (for the smooth transitions seen in Flutter).
3.  **Icons**: `Lucide-react-native` or `MaterialCommunityIcons`.
4.  **Backend Connectivity**: Standard `fetch` or `Axios` calling the Kejapin Go API.

*Note: Ensure `X-User-ID` (temporary) or JWT is passed in the headers for all messaging and notification requests.*
