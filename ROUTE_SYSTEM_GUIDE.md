# Fixed Route System for Garbage Collectors

## Overview
This system replaces the dynamic shortest-route calculation with a fixed route system where collectors can create, save, and reuse their daily collection routes.

## New Features

### 1. Route List Screen (`route_list_screen.dart`)
- **Location**: Home page → "My Routes" button
- **Features**:
  - View all saved routes
  - Create new routes (Manual or Record)
  - Delete routes
  - Select a route to start collection
  - Shows route details (points count, last used)

### 2. Manual Route Creator (`route_creator_screen.dart`)
- **How it works**: Tap on map to add waypoints
- **Features**:
  - Visual markers numbered sequentially
  - Green marker = Start point
  - Red marker = End point
  - Polyline connecting all points
  - Undo last point button
  - Clear all points button
  - Point counter display
  - Save route with custom name and description
  - Minimum 2 points required

### 3. Route Recorder (`route_recorder_screen.dart`)
- **How it works**: Drive the route while recording GPS tracks
- **Features**:
  - **Live location tracking** with navigation icon
  - **Real-time route drawing** as you drive
  - **Highlighted streets** - route polyline updates in real-time
  - **Recording statistics**:
    - Distance traveled (km)
    - Duration (HH:MM:SS)
    - Points recorded
  - **Visual feedback**:
    - Red "RECORDING" banner
    - Red polyline while recording
    - Pulsing red location marker
    - Green flag at start point
  - Records point every 5 meters
  - Minimum 10 points required to save
  - Auto-follows your location
  - Save with custom name and description

### 4. Map with Active Route (`collector_map_with_route_screen.dart`)
- **Automatically opens** when route is selected
- **Features**:
  - **Highlighted fixed route** (thick green polyline)
  - **Live location tracking** (blue navigation marker)
  - **Garbage pins along route** (red delete icons)
  - Shows garbage within 500m of route
  - Auto-follows your location
  - Stats display:
    - Pending garbage count
    - Route points count
  - Tap garbage pins for details
  - Mark garbage as collected
  - Route markers:
    - Green flag = Start
    - Orange stop = End

## User Flow

### Creating a Route

#### Option A: Manual Creation
1. Home → "My Routes" button
2. Tap "+" (New Route) FAB
3. Select "Manual Route"
4. Tap on map to add waypoints
5. Connect streets by tapping sequentially
6. Tap Save icon (top right)
7. Enter route name and description
8. Route is saved

#### Option B: Record Route
1. Home → "My Routes" button
2. Tap "+" (New Route) FAB
3. Select "Record Route"
4. Tap "START RECORDING" button
5. **Drive your route** - streets highlight as you go
6. **See live progress** with statistics
7. Tap "STOP RECORDING" button
8. Review recorded statistics
9. Enter route name and description
10. Route is saved

### Using a Route
1. Home → "My Routes" button
2. Tap on saved route from list
3. **Automatically navigates to map**
4. Route is highlighted in green
5. All garbage pins along route are shown
6. Your live location is tracked
7. Follow the highlighted route
8. Tap garbage pins to mark as collected

## Technical Details

### Database Structure

#### `collector_routes` collection:
```
{
  routeName: string
  collectorId: string
  routePoints: [
    { latitude: number, longitude: number },
    ...
  ]
  description: string
  createdAt: timestamp
  lastUsed: timestamp
  isActive: boolean
}
```

#### `active_collectors` collection (updated):
```
{
  latitude: number
  longitude: number
  lastUpdate: timestamp
  userId: string
  activeRouteId: string      // NEW
  routeName: string          // NEW
}
```

### Route Service (`route_service.dart`)
- `createRoute()` - Save new route
- `updateRoute()` - Modify existing route
- `deleteRoute()` - Remove route
- `getCollectorRoutes()` - Stream all routes
- `getRoute()` - Get single route
- `markRouteAsUsed()` - Update last used timestamp
- `getGarbageAlongRoute()` - Find garbage within distance of route

### GPS Tracking Features

#### Route Recording:
- **Accuracy**: `LocationAccuracy.bestForNavigation`
- **Distance Filter**: 5 meters (records point every 5m)
- **Real-time Updates**: Continuous position stream
- **Visual Feedback**: Red polyline and location marker
- **Statistics**: Distance, duration, point count

#### Active Route Navigation:
- **Accuracy**: `LocationAccuracy.bestForNavigation`
- **Distance Filter**: 5 meters
- **Auto-follow**: Camera follows your location
- **Manual pan**: Tap "My Location" button to re-center
- **Location updates**: Saved to Firestore for monitoring

## UI Components

### Route List Screen:
- Empty state with "Create first route" message
- Route cards showing:
  - Route name
  - Description
  - Points count
  - Last used date
  - Options menu (delete)
- FAB for creating new routes
- Modal bottom sheet for creation method selection

### Manual Route Creator:
- Interactive map
- Tap to add points
- Visual markers with numbers
- Info banner with instructions
- Undo/Clear buttons
- Point counter badge
- Save dialog with name/description inputs

### Route Recorder:
- Live map with tracking
- Recording stats banner (red)
- Distance/Duration/Points display
- START/STOP recording button
- Auto-following camera
- Save dialog with statistics summary
- Name/description inputs

### Map with Route:
- Route polyline (green, 6px width)
- Current location (blue navigation icon)
- Garbage markers (red delete icons)
- Route start (green flag)
- Route end (orange stop)
- Stats card (pending/points)
- Follow location FAB
- Garbage detail bottom sheet
- Mark collected button

## Benefits

1. **Efficiency**: Collectors use familiar routes daily
2. **Predictability**: Users know when collector passes
3. **Completeness**: All garbage along route is shown
4. **Flexibility**: Create routes manually or by recording
5. **Real-time**: Live location and route progress
6. **UX**: Visual feedback during recording
7. **Reusability**: Save and reuse routes
8. **Tracking**: Monitor which routes are used

## Integration Points

- **Home Screen**: "My Routes" button added
- **Collector Map**: Now supports route-based navigation
- **Firestore**: New collections for routes
- **GPS**: Enhanced tracking with best navigation accuracy
- **UI**: Consistent green theme throughout
