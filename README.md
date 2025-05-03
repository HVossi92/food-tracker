# Munch Metrics

A modern, real-time food tracking application built with Phoenix LiveView. Track your meals easily with a responsive interface.

Demo: https://munchmetrics.vossihub.org/

<img src="screenshots/demo.png" alt="Munch Metrics Screenshot" width="600"/>

## Todos

[x] Make sure db is persistent when running new container
[x] Fix Today's Food Log scroll bars / layout
[x] Always default to the current date and time
[x] Implement anonymous user functionality

## Anonymous User Access Implementation Plan

The goal is to allow users to try out the app without registration, only prompting them to create an account after they start saving food tracks.

### Phase 1: Preparation and Testing (✓ Completed)

1. **Fix Existing Tests**

   - [x] Update food tracking tests to include user_id requirement
   - [x] Ensure all tests pass with current implementation

2. **Design Database Changes**

   - [x] Add `anonymous_uuid` field to users table
   - [x] Add `is_anonymous` boolean field to users table
   - [x] Add `last_active_at` timestamp field to users table
   - [x] Create database migration

3. **Write New Tests**
   - [x] Test anonymous user creation
   - [x] Test anonymous user to registered user conversion
   - [x] Test inactive anonymous user cleanup
   - [x] Test session preservation during conversion

### Phase 2: Core Implementation (✓ Completed)

4. **Update Authentication System**

   - [x] Modify router to allow public access to home and monthly pages
   - [x] Create anonymous user module and plug
   - [x] Implement anonymous user tracking via cookies
   - [x] Update LiveView hooks to handle anonymous users
   - [x] Make sure we have test coverage for the new changes

5. **Track Anonymous Users**

   - [x] Set cookie with UUID for anonymous users
   - [x] Create anonymous user accounts when saving first food track
   - [x] Update last_active_at on each page visit
   - [x] Make sure we have test coverage for the new changes

6. **User Conversion Workflow**
   - [x] Add functionality to convert anonymous users to registered users
   - [x] Preserve existing food tracking data during conversion
   - [x] Update email confirmation process to handle anonymous users
   - [x] Make sure we have test coverage for the new changes

### Phase 3: UI and Cleanup (✓ Completed)

7. **UI Notifications**

   - [x] Add persistent banner for anonymous users
   - [x] Show clear notification about data persistence limitations
   - [x] Provide easy path to registration
   - [x] Make sure we have test coverage for the new changes

8. **Implement Cleanup Job**

   - [x] Create periodic task to clean up inactive anonymous accounts
   - [x] Set up 30-day inactivity threshold matching cookie duration
   - [x] Add logging for account cleanup
   - [x] Make sure we have test coverage for the new changes

9. **Update Privacy and Terms**
   - [x] Update privacy policy to address anonymous user data
   - [x] Document data retention policies for anonymous accounts
   - [x] Make sure we have test coverage for the new changes

### Phase 4: Testing and Launch

10. **Final Testing**

    - [ ] Verify all user flows (anonymous → registered)
    - [ ] Test edge cases for authentication
    - [ ] Test data persistence through conversion

## For Users

### Features

- Simple and intuitive food tracking
- Daily tracking view for detailed meal logging
- Monthly overview to visualize eating patterns
- Dark mode support for comfortable viewing
- Responsive design that works on all devices
- Secure user authentication

### Getting Started

1. Create an account or log in
2. Use the "Tracking" view for daily meal logging
   - Add meals with name, date, and time
3. Switch to "Monthly View" to see your eating patterns
   - Navigate between months easily
   - Today's date is highlighted for quick reference

## For Developers

### Tech Stack

- **Framework**: Phoenix LiveView
- **Language**: Elixir
- **Database**: SQLite3
- **Frontend**: Tailwind CSS
- **Authentication**: Built-in Phoenix authentication

### Prerequisites

- Elixir 1.14 or later
- Erlang/OTP 25 or later
- SQLite3

### Local Development Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   mix setup
   ```
3. Start Phoenix server:
   ```bash
   mix phx.server
   ```
4. Visit [`localhost:4000`](http://localhost:4000) from your browser

### Project Structure

- `lib/food_tracker/food__tracking/` - Core food tracking context and schema
- `lib/food_tracker_web/live/` - LiveView components and templates
- `lib/food_tracker_web/components/` - Reusable UI components
- `priv/repo/migrations/` - Database migrations
