defmodule DatabaseFinal.Chat do
  @moduledoc """
  The Chat context.
  """

  import Ecto.Query, warn: false
  alias DatabaseFinal.UserInfo
  alias DatabaseFinal.Chat.Room
  alias DatabaseFinal.Repo
  alias Phoenix.PubSub
  alias DatabaseFinal.Chat.Event

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events do
    Repo.all(Event)
  end

  def list_last_events(x) do
    Repo.all(from(Event, limit: ^x))
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id), do: Repo.get!(Event, id)

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs \\ %{}) do
    result =
      %Event{}
      |> Event.changeset(attrs)
      |> Repo.insert()

    {_, event} = result

    PubSub.broadcast(DatabaseFinal.PubSub, "event-channel", {:new_event, event})
    result
  end

  def send_msg(sender, content, room \\ "default") do
    create_event(%{sender: sender, payload: content, type: "msg", room: room})
  end

  def create_event_at(room, attrs \\ %{}) do
    result =
      %Event{}
      |> Event.changeset(attrs)
      |> Repo.insert()

    {_, event} = result

    PubSub.broadcast(DatabaseFinal.PubSub, room, {:new_event, event})
    result
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{data: %Event{}}

  """
  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

  def join_room(user, room) do
    result =
      %Room{}
      |> Room.changeset(%{user_id: user.id, room_name: room})
      |> Repo.insert()

    {_, room} = result

    PubSub.broadcast(DatabaseFinal.PubSub, "event-channel", {:join_room, room})
    result
  end

  def leave_room(_user, _room) do
  end

  def list_rooms() do
    from(p in Room, group_by: p.room_name, select: [p.room_name])
    |> Repo.all()
    |> Enum.concat()
  end

  def create_user_info(attrs \\ %{}) do
    if check_if_email_not_exit(attrs["email"]) do
      %UserInfo{}
      |> UserInfo.changeset(attrs)
      |> Repo.insert()
    else
      {:error, "This email has been registered"}
    end
  end

  def check_if_email_not_exit(email) do
    Repo.get_by(UserInfo, email: email) |> is_nil()
  end

  def userinfo_from_id(id) do
    Repo.get(UserInfo, id)
  end

  def userinfo_from_email(email) do
    Repo.get_by(UserInfo, email: email)
  end

  def search_msg(user, content, limit \\ 20) do
    Event
    |> where([e], like(e.payload, ^"%#{content}%"))
    |> where([e], e.type == :msg)
    |> where([e], e.sender == ^userinfo_from_email(user.email).name)
    |> limit(^limit)
    |> Repo.all()
  end
end
