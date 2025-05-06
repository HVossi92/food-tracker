# Munch Metrics

A modern, real-time food tracking application built with Phoenix LiveView. Track your meals easily with a responsive interface.

Demo: https://munchmetrics.vossihub.org/

<img src="screenshots/demo.png" alt="Munch Metrics Screenshot" width="600"/>

## Todos

[x] Make sure db is persistent when running new container
[x] Fix Today's Food Log scroll bars / layout
[x] Always default to the current date and time
[x] Implement anonymous user functionality
[x] On refresh/load jump to today in the form date input
[x] On refresh/load jump to current time in the form date input
[x] Improve table layout (date, time)
[ ] Display time in the user's timezone
[ ] Edit calories & protein
[ ] Fix settings layout
[ ] Do not redirect for edit
[ ] Improve ai generated nutritional values

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
