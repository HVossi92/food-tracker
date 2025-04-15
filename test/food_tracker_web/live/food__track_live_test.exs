defmodule FoodTrackerWeb.Food_TrackLiveTest do
  use FoodTrackerWeb.ConnCase

  import Phoenix.LiveViewTest
  import FoodTracker.Food_TrackingFixtures

  @create_attrs %{name: "some name", date: "some date", time: "some time"}
  @update_attrs %{name: "some updated name", date: "some updated date", time: "some updated time"}
  @invalid_attrs %{name: nil, date: nil, time: nil}

  defp create_food__track(_) do
    food__track = food__track_fixture()
    %{food__track: food__track}
  end

  describe "Index" do
    setup [:create_food__track]

    test "lists all food_tracks", %{conn: conn, food__track: food__track} do
      {:ok, _index_live, html} = live(conn, ~p"/food_tracks")

      assert html =~ "Listing Food tracks"
      assert html =~ food__track.name
    end

    test "saves new food__track", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/food_tracks")

      assert index_live |> element("a", "New Food  track") |> render_click() =~
               "New Food  track"

      assert_patch(index_live, ~p"/food_tracks/new")

      assert index_live
             |> form("#food__track-form", food__track: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#food__track-form", food__track: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/food_tracks")

      html = render(index_live)
      assert html =~ "Food  track created successfully"
      assert html =~ "some name"
    end

    test "updates food__track in listing", %{conn: conn, food__track: food__track} do
      {:ok, index_live, _html} = live(conn, ~p"/food_tracks")

      assert index_live |> element("#food_tracks-#{food__track.id} a", "Edit") |> render_click() =~
               "Edit Food  track"

      assert_patch(index_live, ~p"/food_tracks/#{food__track}/edit")

      assert index_live
             |> form("#food__track-form", food__track: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#food__track-form", food__track: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/food_tracks")

      html = render(index_live)
      assert html =~ "Food  track updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes food__track in listing", %{conn: conn, food__track: food__track} do
      {:ok, index_live, _html} = live(conn, ~p"/food_tracks")

      assert index_live |> element("#food_tracks-#{food__track.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#food_tracks-#{food__track.id}")
    end
  end

  describe "Show" do
    setup [:create_food__track]

    test "displays food__track", %{conn: conn, food__track: food__track} do
      {:ok, _show_live, html} = live(conn, ~p"/food_tracks/#{food__track}")

      assert html =~ "Show Food  track"
      assert html =~ food__track.name
    end

    test "updates food__track within modal", %{conn: conn, food__track: food__track} do
      {:ok, show_live, _html} = live(conn, ~p"/food_tracks/#{food__track}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Food  track"

      assert_patch(show_live, ~p"/food_tracks/#{food__track}/show/edit")

      assert show_live
             |> form("#food__track-form", food__track: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#food__track-form", food__track: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/food_tracks/#{food__track}")

      html = render(show_live)
      assert html =~ "Food  track updated successfully"
      assert html =~ "some updated name"
    end
  end
end
