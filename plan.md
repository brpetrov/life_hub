# Life Hub Standalone App Plan

## Goal

Create a completely separate Flutter app called **Life Hub** for the existing Life Hub reminder feature.

The new app should:

- Run as a cross-platform Flutter app.
- Use Firebase Authentication and Cloud Firestore.
- Preserve the useful behavior from the current hub screen.
- Improve the architecture before the feature becomes its own product.
- Keep the current finance app unchanged until the new app is working and data migration is confirmed.

## Non-negotiable Technical Requirements

- The app name is **Life Hub**.
- The app is a new Flutter project, separate from the current finance app.
- Firebase Authentication is used for user accounts.
- Cloud Firestore is used for storing Life Hub reminders and user settings.
- Every hub item belongs to a signed-in Firebase user.
- Users must not be able to read or write another user's hub data.
- The current finance app keeps the existing Life Hub feature until the standalone app is accepted.

## Acceptance Criteria

The standalone Life Hub app is accepted when all of the following are true:

1. A new Flutter app named `life_hub` exists and runs independently from the finance app.
2. Firebase initializes successfully using `DefaultFirebaseOptions.currentPlatform`.
3. Firebase Authentication supports sign up, sign in, sign out, and protected routes.
4. A signed-out user cannot access hub data screens.
5. Cloud Firestore stores reminders under the signed-in user's document.
6. Firestore security rules prevent users from reading or writing another user's reminders.
7. A user can add preset reminders from onboarding.
8. A user can add a custom reminder.
9. A user can view reminders sorted by status, overdue, due soon, upcoming, ok, and unknown.
10. A user can filter reminders by category.
11. A user can edit a reminder's name, description, category, and frequency.
12. A user can set or change a reminder due date.
13. A user can mark a reminder as done and the next due date updates from the frequency.
14. A user can delete a reminder after confirming the action.
15. Reminder updates sync through Firestore without needing a full app restart.
16. The app has working empty, loading, error, and populated states.
17. The app passes `flutter analyze`.
18. Core domain logic has unit tests for status, frequency labels, due date rolling, and category parsing.
19. The app is manually checked on at least one mobile target and one web or desktop target.
20. Existing Life Hub data can be migrated or imported without deleting the old finance app data first.
21. The Life Hub feature is removed from the finance app only after the standalone app is working with real data.

## Execution Style

Build the app phase by phase. Each phase should leave the app in a working state before moving on.

The first target is not the perfect final product. The first target is the smallest complete standalone version that proves auth, Firestore, setup, reminders, and editing work end to end.

## Current Hub Review

The current feature is contained mostly in:

- `lib/screens/hub_screen/hub_screen.dart`
- `lib/screens/hub_screen/hub_setup_screen.dart`
- `lib/screens/hub_screen/hub_item.dart`
- `lib/services/firestore_service.dart`, maintenance methods only
- `lib/screens/home_screen/home_screen.dart`, tab embedding, app bar actions, floating action button
- `lib/main.dart`, `/hub` and `/hub/setup` routes

### Current user flow

1. User opens the Life Hub tab inside the finance app.
2. The screen loads reminder items from Firestore.
3. Items are sorted by status, overdue first, then due soon, upcoming, ok, and unknown.
4. User can filter by category.
5. User can open a reminder detail bottom sheet.
6. User can edit the reminder, change the due date, mark it done, or delete it.
7. User can open setup to add preset reminders or custom reminders.
8. Presets are grouped into Car, Home, Health, Tech, Pets, Documents, Seasonal, and Custom.

### Current Firestore shape

Current path:

```text
users/{uid}/maintenance/{itemId}
```

Current fields:

```text
name: string
category: string
description: string
frequencyMonths: number
lastDoneDate: string or null
nextDueDate: string or null
createdAt: timestamp
```

The existing app stores due dates as ISO strings in most writes, but also normalizes Firestore `Timestamp` values when reading.

### What is already good

- The feature is already fairly self-contained.
- The preset list is centralized in one file.
- The core feature set is clear and useful.
- CRUD operations are small and easy to map into a standalone repository.
- The list layout already responds to wider screens by using two columns.
- The setup screen has a good first version of onboarding.

### Issues to fix during extraction

1. **UI and Firebase are tightly coupled.**
   The widgets call `FirestoreService` directly. In the new app, use a repository or controller layer so UI, state, and persistence are easier to test.

2. **Date storage should be standardized.**
   Use Firestore `Timestamp` for `nextDueDate`, `lastDoneDate`, `createdAt`, and `updatedAt`. Convert to `DateTime` only inside the model layer.

3. **Auth assumptions need guard rails.**
   The current service relies on `AuthService.currentUser!`. In a standalone app, all hub data routes should sit behind an auth gate.

4. **Manual refresh should become realtime sync.**
   The current screen fetches with `get()`. A separate app benefits from a Firestore stream so phone, desktop, and web stay in sync.

5. **Preset identity should not depend on display names.**
   The setup screen keys selected presets by `preset.name`. Add stable preset IDs so future copy changes do not break selection or migration.

6. **Frequency labels are duplicated.**
   Move frequency display logic into a shared helper or value object.

7. **Some cards may be tight on small screens.**
   The current grid uses fixed card height. The standalone app should keep dense scanning, but allow long names and descriptions to fit more gracefully.

8. **Copy and symbols need a cleanup pass.**
   Review punctuation, currency symbols, and special characters while moving the presets. Some text appears with encoding artifacts in terminal output.

9. **No reminder notifications yet.**
   The current feature tracks dates, but does not notify users. The new app should launch without notifications first, then add notifications as a separate phase.

## Best Architecture For The New App

Use a small, clean Flutter app rather than copying the finance app structure wholesale.

Recommended structure:

```text
lib/
  main.dart
  firebase_options.dart
  app/
    life_hub_app.dart
    app_router.dart
    app_theme.dart
  features/
    auth/
      auth_gate.dart
      login_screen.dart
      auth_service.dart
    hub/
      data/
        hub_item_repository.dart
        firestore_hub_item_repository.dart
      domain/
        hub_category.dart
        hub_item.dart
        hub_preset.dart
        hub_status.dart
        frequency.dart
      presentation/
        hub_screen.dart
        hub_setup_screen.dart
        hub_item_card.dart
        hub_item_details_sheet.dart
        hub_item_form_dialog.dart
    settings/
      settings_screen.dart
  shared/
    widgets/
    utils/
```

Why this is the best option:

- It is still simple enough for a first standalone app.
- It avoids the current all-in-one screen growing harder to maintain.
- It makes Firebase replaceable for tests and future desktop decisions.
- It gives you clear places for UI, data, and business rules.

## Firebase And Platform Notes

I checked the current official docs on May 2, 2026.

- Flutter supports Android, iOS, Windows, macOS, Linux, and web as deployment targets.
- The Firebase Flutter setup docs focus on iOS, Android, and web configuration through `flutterfire configure`.
- The Firebase plugin table includes Apple platforms, Android, web, and Windows support status for some plugins.
- Firebase currently cautions that Firebase on Windows is not intended for production use cases, only local development workflows.

Practical recommendation:

1. Build the app with Flutter targets for Android, iOS, web, macOS, Windows, and Linux.
2. Treat Android, iOS, web, and macOS as the first production Firebase targets.
3. For Windows and Linux, make an explicit decision before release:
   - Option A, use Firebase Flutter plugins where supported and accept desktop as personal or beta quality.
   - Option B, add a REST or Cloud Functions backed data service for desktop production support.

Best option: start with Option A for the smallest working app, but keep the repository layer clean so Option B is possible without rewriting the UI.

References:

- Firebase Flutter setup: https://firebase.google.com/docs/flutter/setup
- Flutter supported platforms: https://docs.flutter.dev/reference/supported-platforms

## Target Firestore Schema

Use a new Firebase project for Life Hub.

Recommended paths:

```text
users/{uid}
users/{uid}/hubItems/{itemId}
users/{uid}/settings/app
```

Recommended `hubItems` document:

```text
name: string
category: string
description: string
frequencyMonths: number
lastDoneDate: timestamp or null
nextDueDate: timestamp or null
source: "preset" | "custom"
presetId: string or null
archived: boolean
createdAt: timestamp
updatedAt: timestamp
```

Recommended user settings:

```text
onboardingComplete: boolean
themeMode: "system" | "light" | "dark"
notificationsEnabled: boolean
createdAt: timestamp
updatedAt: timestamp
```

## Step By Step Implementation Plan

### Phase 1, Create the smallest working Life Hub app

1. Create a new Flutter project named `life_hub`.
2. Enable all Flutter platforms needed by the project.
3. Add the minimum dependencies:
   - `firebase_core`
   - `firebase_auth`
   - `cloud_firestore`
   - `google_fonts`, optional
   - `flutter_lints`
4. Create a new Firebase project named Life Hub.
5. Run `flutterfire configure` for the first supported targets.
6. Add `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` in `main.dart`.
7. Build a minimal `LifeHubApp` with Material 3 theme.
8. Add an `AuthGate`.
9. Add email and password sign in, sign up, sign out.
10. Confirm a signed-in user can reach an empty hub screen.

Definition of done:

- The app starts.
- Firebase initializes.
- A user can sign up, sign in, sign out.
- The protected hub screen is only visible when signed in.

### Phase 2, Port the hub domain model

1. Move `HubCategory` into `features/hub/domain/hub_category.dart`.
2. Move `HubStatus` into `features/hub/domain/hub_status.dart`.
3. Create a typed `HubItem` model with `fromFirestore` and `toFirestore`.
4. Create a `Frequency` helper for labels and next due date calculation.
5. Move presets into `hub_preset.dart`.
6. Add stable IDs to every preset.
7. Clean preset copy while moving it.
8. Add unit tests for:
   - status calculation
   - frequency labels
   - next due date calculation
   - category parsing

Definition of done:

- Hub business rules are independent of widgets and Firebase.
- Tests prove the model behavior before UI is ported.

### Phase 3, Build the Firestore repository

1. Create `HubItemRepository` as an abstract interface.
2. Create `FirestoreHubItemRepository`.
3. Implement:
   - `Stream<List<HubItem>> watchItems()`
   - `Future<void> createItem(HubItem item)`
   - `Future<void> createItems(List<HubItem> items)`
   - `Future<void> updateItem(HubItem item)`
   - `Future<void> markDone(HubItem item)`
   - `Future<void> deleteItem(String id)`
4. Query only non-archived items by default.
5. Sort in Dart first for simplicity, then add Firestore indexes only if needed.
6. Add `createdAt` and `updatedAt` consistently on writes.

Definition of done:

- The app can create, read, update, mark done, and delete hub items through one repository.
- The UI does not call Firestore directly.

### Phase 4, Port the main hub screen

1. Recreate the current list screen as the first production screen.
2. Use a Firestore stream instead of manual load state.
3. Keep the current status ordering.
4. Keep category filters.
5. Keep the empty state with a setup call to action.
6. Split large widgets out:
   - `HubItemCard`
   - `HubStatusBar`
   - `HubCategoryFilterBar`
   - `HubItemDetailsSheet`
7. Keep the first version visually close to the current feature.
8. Improve spacing and text wrapping after behavior is working.

Definition of done:

- Existing reminders appear in realtime.
- Filtering works.
- Empty state works.
- Detail sheet opens.
- The screen works on phone, tablet, desktop width, and web width.

### Phase 5, Port setup and onboarding

1. Recreate `LifeHubSetupScreen` as the onboarding and add-more screen.
2. Keep category groups.
3. Keep select all and deselect all.
4. Keep custom reminder creation.
5. Use preset IDs for selected items.
6. Allow due dates to be optional.
7. Save all selected presets and custom reminders through the repository.
8. Store `onboardingComplete` after the first successful save.
9. Route first-time users to setup, returning users to the dashboard.

Definition of done:

- A new user can pick presets and land on a populated dashboard.
- An existing user can add more reminders later.

### Phase 6, Port edit, due date, done, and delete flows

1. Recreate edit reminder dialog or screen.
2. Recreate due date picker.
3. Recreate delete confirmation.
4. Recreate mark done.
5. Mark done should set:
   - `lastDoneDate` to now
   - `nextDueDate` to now plus `frequencyMonths`
   - `updatedAt` to server timestamp
6. Add optimistic UI only after the basic flow is stable.

Definition of done:

- Every action from the current hub screen exists in the new app.
- Data updates sync across two signed-in sessions.

### Phase 7, Add app-level features

1. Add a settings screen.
2. Add theme mode, system, light, dark.
3. Add account delete with re-authentication.
4. Add data export for hub items.
5. Add data import only if needed for migration.
6. Add basic profile display, email, display name if available.

Definition of done:

- The standalone app has the minimum account and settings features users expect.

### Phase 8, Add notifications after the app works

Do not add notifications in the first version. They touch platform-specific behavior and can slow down the migration.

After the core app works:

1. Add notification requirements:
   - due today
   - due soon
   - overdue
   - quiet hours
   - per-item mute
2. Start with local notifications.
3. Add push notifications later only if needed.
4. Store notification preferences in user settings.

Definition of done:

- Users can opt in.
- Notifications are predictable.
- The app still works if notifications are denied.

### Phase 9, Test plan

1. Run `flutter analyze`.
2. Add unit tests for all domain logic.
3. Add widget tests for:
   - empty hub screen
   - item card status display
   - category filters
   - setup selection count
4. Test with Firebase Emulator Suite if possible.
5. Manually test:
   - Android or emulator
   - iOS simulator if available
   - Chrome web
   - macOS, Windows, and Linux targets as available
6. Test auth edge cases:
   - signed out user
   - deleted account
   - expired auth session
7. Test data edge cases:
   - no due date
   - overdue by one day
   - due today
   - very long item name
   - duplicate preset display names

Definition of done:

- The new app has no analyzer issues.
- Core hub behavior is covered by tests.
- At least one mobile target and one web or desktop target have been manually checked.

### Phase 10, Data migration from the finance app

Do this only after the new app is working.

1. Decide whether the new app uses the same Firebase Auth users or a new Firebase project.
2. If using a new Firebase project, users will need new accounts or an account migration plan.
3. Export existing documents from:

```text
users/{uid}/maintenance
```

4. Transform fields:
   - `category` stays as enum string.
   - ISO date strings become Firestore timestamps.
   - missing `source` becomes `custom` unless matched to a preset ID.
   - add `archived: false`.
   - add `updatedAt`.
5. Import into:

```text
users/{uid}/hubItems
```

6. Verify item counts per user.
7. Verify several due dates manually.
8. Keep the old finance app data until users confirm the new app is correct.

Definition of done:

- Every current Life Hub item exists in the new app.
- Dates and categories are correct.
- No current app data has been deleted yet.

### Phase 11, Release plan

1. Pick production targets for version 1.
2. Set app identifiers:
   - Android package ID
   - iOS bundle ID
   - macOS bundle ID
   - Windows app identity if packaging
   - Web hosting domain if using Firebase Hosting
3. Configure Firebase security rules.
4. Configure Firebase indexes if queries require them.
5. Add app icons and launch screens.
6. Build release artifacts.
7. Smoke test release builds.
8. Publish internal builds first.
9. Move to public release only after migration is proven.

Definition of done:

- A user can install or open Life Hub without the finance app.
- Data persists and syncs.
- The old finance app is no longer required for the hub feature.

### Phase 12, Remove Life Hub from the finance app

Only do this after the standalone app is accepted.

1. Remove `LifeHubScreen` from the home tab `IndexedStack`.
2. Remove the Life Hub navigation destination.
3. Remove Life Hub app bar actions.
4. Remove the Life Hub floating action button path.
5. Remove `/hub` and `/hub/setup` routes.
6. Remove imports for hub screens.
7. Remove `lib/screens/hub_screen/` after confirming it is not referenced.
8. Remove maintenance methods from `FirestoreService` if no longer needed.
9. Decide whether old `maintenance` Firestore data should be archived, exported, or deleted.
10. Run `flutter analyze` and the existing tests.

Definition of done:

- The finance app builds without Life Hub.
- No hub routes, tabs, or imports remain.
- Existing finance behavior is unchanged.

## Recommended MVP Scope

For the first working standalone app, build only:

1. Firebase init.
2. Email and password auth.
3. Auth gate.
4. Hub item stream.
5. Empty state.
6. Add presets from setup.
7. Add custom reminder.
8. List with status and category filters.
9. Detail sheet.
10. Edit, set date, mark done, delete.

Leave these for after MVP:

- Notifications.
- Data export and import.
- Advanced settings.
- Admin tools.
- Cloud Functions.
- Desktop production fallback service.

## Suggested Build Order

1. New app skeleton.
2. Firebase auth.
3. Domain model and tests.
4. Firestore repository.
5. Empty hub screen.
6. Setup screen save flow.
7. List screen.
8. Detail and edit flows.
9. Responsive polish.
10. Migration script or import flow.
11. Release packaging.
12. Remove feature from finance app.

## Open Decisions

1. Should Life Hub use a new Firebase project or the current `dun-bun-finance` Firebase project?
2. Should existing users keep the same account, or create Life Hub accounts separately?
3. Which platforms are production targets for version 1?
4. Is Windows and Linux support required for production, or acceptable as beta/internal first?
5. Should reminders eventually send notifications, or is in-app tracking enough for version 1?
6. Should preset content stay UK-specific, or become region configurable later?

## My Recommendation

Start with a new Flutter app and a new Firebase project, but keep the first version small.

Do not begin by redesigning everything. First reproduce the current useful behavior in a cleaner architecture. Once the standalone app works, improve the UI, add notifications, and then migrate data. Remove Life Hub from the finance app only after the new app has been tested with real data.
