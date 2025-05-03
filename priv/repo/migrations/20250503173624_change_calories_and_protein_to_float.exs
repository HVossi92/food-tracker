defmodule FoodTracker.Repo.Migrations.ChangeCaloriesAndProteinToFloat do
  use Ecto.Migration

  def up do
    # In SQLite, we need to recreate the table to change column types
    # First, let's drop any existing indexes on the table
    # The DROP INDEX IF EXISTS statement will silently do nothing if the index doesn't exist
    execute("DROP INDEX IF EXISTS food_tracks_user_id_index")

    # Rename the current table to a backup
    execute("ALTER TABLE food_tracks RENAME TO food_tracks_old")

    # Create a new table with the desired schema
    create_table = """
    CREATE TABLE food_tracks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      date TEXT,
      time TEXT,
      inserted_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      user_id INTEGER NOT NULL CONSTRAINT food_tracks_user_id_fkey REFERENCES users(id) ON DELETE CASCADE,
      calories REAL DEFAULT -1.0,
      protein REAL DEFAULT -1.0
    )
    """

    execute(create_table)

    # Copy data from old table to new table, converting string to float
    copy_data = """
    INSERT INTO food_tracks(id, name, date, time, inserted_at, updated_at, user_id, calories, protein)
    SELECT id, name, date, time, inserted_at, updated_at, user_id,
           CASE WHEN calories = '' THEN -1.0 ELSE CAST(calories AS REAL) END,
           CASE WHEN protein = '' THEN -1.0 ELSE CAST(protein AS REAL) END
    FROM food_tracks_old
    """

    execute(copy_data)

    # Recreate the index on the new table
    execute("CREATE INDEX food_tracks_user_id_index ON food_tracks (user_id)")

    # Drop the backup table
    execute("DROP TABLE food_tracks_old")
  end

  def down do
    # Drop any existing indexes on the table
    execute("DROP INDEX IF EXISTS food_tracks_user_id_index")

    # Rename the current table to a backup
    execute("ALTER TABLE food_tracks RENAME TO food_tracks_old")

    # Create a new table with the original schema
    create_table = """
    CREATE TABLE food_tracks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      date TEXT,
      time TEXT,
      inserted_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      user_id INTEGER NOT NULL CONSTRAINT food_tracks_user_id_fkey REFERENCES users(id) ON DELETE CASCADE,
      calories TEXT,
      protein TEXT
    )
    """

    execute(create_table)

    # Copy data from current table to new table, converting float to string
    copy_data = """
    INSERT INTO food_tracks(id, name, date, time, inserted_at, updated_at, user_id, calories, protein)
    SELECT id, name, date, time, inserted_at, updated_at, user_id,
           CASE WHEN calories < 0 THEN '' ELSE CAST(calories AS TEXT) END,
           CASE WHEN protein < 0 THEN '' ELSE CAST(protein AS TEXT) END
    FROM food_tracks_old
    """

    execute(copy_data)

    # Recreate the index on the new table
    execute("CREATE INDEX food_tracks_user_id_index ON food_tracks (user_id)")

    # Drop the backup table
    execute("DROP TABLE food_tracks_old")
  end
end
