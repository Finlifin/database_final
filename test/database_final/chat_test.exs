defmodule DatabaseFinal.ChatTest do
  use DatabaseFinal.DataCase

  alias DatabaseFinal.Chat

  describe "events" do
    alias DatabaseFinal.Chat.Event

    import DatabaseFinal.ChatFixtures

    @invalid_attrs %{type: nil, sender: nil, content: nil}

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Chat.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Chat.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      valid_attrs = %{type: "some type", sender: "some sender", content: "some content"}

      assert {:ok, %Event{} = event} = Chat.create_event(valid_attrs)
      assert event.type == "some type"
      assert event.sender == "some sender"
      assert event.content == "some content"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      update_attrs = %{type: "some updated type", sender: "some updated sender", content: "some updated content"}

      assert {:ok, %Event{} = event} = Chat.update_event(event, update_attrs)
      assert event.type == "some updated type"
      assert event.sender == "some updated sender"
      assert event.content == "some updated content"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.update_event(event, @invalid_attrs)
      assert event == Chat.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Chat.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Chat.change_event(event)
    end
  end

  describe "events" do
    alias DatabaseFinal.Chat.Event

    import DatabaseFinal.ChatFixtures

    @invalid_attrs %{type: nil, payload: nil, sender: nil, room: nil}

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Chat.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Chat.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      valid_attrs = %{type: :msg, payload: "some payload", sender: "some sender", room: "some room"}

      assert {:ok, %Event{} = event} = Chat.create_event(valid_attrs)
      assert event.type == :msg
      assert event.payload == "some payload"
      assert event.sender == "some sender"
      assert event.room == "some room"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      update_attrs = %{type: :img, payload: "some updated payload", sender: "some updated sender", room: "some updated room"}

      assert {:ok, %Event{} = event} = Chat.update_event(event, update_attrs)
      assert event.type == :img
      assert event.payload == "some updated payload"
      assert event.sender == "some updated sender"
      assert event.room == "some updated room"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.update_event(event, @invalid_attrs)
      assert event == Chat.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Chat.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Chat.change_event(event)
    end
  end
end
