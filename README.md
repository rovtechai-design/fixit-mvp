# FixIt

**FixIt** is a polished Flutter UI template/demo for a household-services marketplace. Snap a photo of the problem, pick a service, and get matched with the right tradesperson. There are two roles, and the whole thing runs with **local-only storage** — no backend, no API keys, no accounts.

> Tagline: *"Snap the problem. We send the right person."*

## The two roles

- **Customer ("I need help")** — photograph a household problem, choose a service category (Plumbing, Electrical, AC Service, Home Cleaning, Terrace/Outdoor Cleaning, Gardening, Tailoring/Alterations, or "Not sure"), submit a request, and track it through a 4-step tracker: **Submitted → Provider assigned → On the way → Completed**.
- **Provider ("I'm a service provider")** — pick a trade (Plumber, Electrician, AC Technician, Cleaner, Gardener, Tailor), see available jobs that match that trade (plus "Not sure" jobs, visible to everyone), accept a job, then move it through **On the way → Mark completed**.

Because this is a local-only demo (v0.1), both roles read and write the **same on-device data** — that's intentional. The idea is you demo it on a single phone by submitting a request as a customer, then using the profile menu to **switch role** and accept/complete it as a provider.

## Demo walkthrough (~60 seconds)

1. Open the app → **"I need help"** → fill in a quick demo profile (name, 10-digit phone, flat/building/area).
2. On the home grid, tap **Plumbing** (or any category) → add an optional photo, describe the problem, confirm the address and a preferred day/slot → **Submit request**.
3. You'll get a confirmation screen with a request code like `FX-1042` → tap **Track request** to see the live 4-step tracker.
4. Tap the profile icon (top right) → **Switch role** → **"I'm a service provider"** → sign in as, say, a Plumber.
5. On **Available jobs**, find the request you just submitted → open it → **Accept job**.
6. Go to **My jobs** → **On the way** → **Mark completed**.
7. Switch role back to the customer profile (**Continue as ...** on the welcome screen) and watch the tracker now show **Completed**, with the provider's name and phone visible.

The app seeds some realistic starter data on first launch (a couple of customers, four providers across different trades, and a handful of jobs in various statuses) so the app isn't empty on a first look.

## Local-only data (v0.1)

Everything — profiles, requests, job statuses — is stored on-device via `shared_preferences`, as plain JSON. There is no server, no sync between devices, and no real notifications. The **profile menu** has a **"Reset demo data"** option that wipes everything and reloads the starter seed data, useful for repeat demos.

Photos: on Android, `image_picker` lets you take or choose a photo, stored as a local file path. On **web**, photo capture is disabled and a placeholder is shown instead (persisting camera photos reliably in a browser is out of scope for this demo).

## Tech

- Flutter (Android + Web), Material 3, single accent color theme
- State: a single `ChangeNotifier`-based repository (`AppRepository`), no backend
- Persistence: `shared_preferences` (JSON-encoded)
- Tests: service-category → trade routing, job status transitions (including the "only one provider can accept a job" race), and form validation

## Get it

- **Android APK**: see the [Releases](../../releases) page (`fixit-v0.1.0.apk`)
- **Web demo**: [GitHub Pages link in the repo "About" section]

## Running locally

```bash
flutter pub get
flutter run            # pick a device, or
flutter run -d chrome  # run in the browser
```
