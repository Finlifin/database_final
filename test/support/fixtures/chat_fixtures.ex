defmodule DatabaseFinal.ChatFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DatabaseFinal.Chat` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        content: "some content",
        sender: "some sender",
        type: "some type"
      })
      |> DatabaseFinal.Chat.create_event()

    event
  end

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        payload: "some payload",
        room: "some room",
        sender: "some sender",
        type: :msg
      })
      |> DatabaseFinal.Chat.create_event()

    event
  end
end
