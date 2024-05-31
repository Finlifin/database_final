defmodule DatabaseFinalWeb.EventLive.Index do
  alias DatabaseFinal.Chat.Room
  alias DatabaseFinal.UserInfo
  alias DatabaseFinal.Chat
  alias Phoenix.PubSub
  use DatabaseFinalWeb, :live_view

  alias DatabaseFinal.Chat
  alias DatabaseFinal.Chat.Event

  on_mount {DatabaseFinalWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(params, _session, %{assigns: %{current_user: current_user}} = socket)
      when not is_nil(current_user) do
    if connected?(socket), do: PubSub.subscribe(DatabaseFinal.PubSub, "event-channel")
    changeset = Chat.change_event(%Event{}, %{}) |> to_form()
    join_room_changeset = Chat.change_room(%Room{}, %{}) |> to_form()
    join_user_changeset = Chat.change_room(%Room{}, %{}) |> to_form()
    rooms = Chat.list_rooms(current_user.id)
    current_user_info = Chat.userinfo_from_email(current_user.email)

    room =
      case params do
        %{id: id} -> id
        _ -> "default"
      end

    socket =
      socket
      |> assign(msg_input: changeset)
      |> assign(join_room_input: join_room_changeset)
      |> assign(join_user_input: join_user_changeset)
      |> assign(current_room: room)
      |> assign(current_user_info: current_user_info)
      |> stream(:rooms, rooms)
      |> assign(page_title: "Room: #{room}")
      |> stream(:events, Chat.list_last_events(10) |> Enum.filter(&(&1.room == room)))
      |> push_event("scroll-down", %{})

    {:ok, socket}
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> redirect(to: "/users/log_in")
     |> put_flash(:info, "Please login first")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Event")
    |> assign(:event, Chat.get_event!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Event")
    |> assign(:event, %Event{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Room: #{socket.assigns.current_room}")
    |> assign(:event, nil)
  end

  @impl true
  def handle_info({DatabaseFinal.EventLive.FormComponent, {:saved, event}}, socket) do
    {:noreply, stream_insert(socket, :events, event)}
  end

  def handle_info({:new_event, event}, socket) do
    if event.room == socket.assigns.current_room do
      {:noreply,
       socket
       |> stream_insert(:events, event)
       |> push_event("scroll-down", %{})}
    else
      {:noreply,
       socket
       |> push_event("scroll-down", %{})}
    end
  end

  def handle_info({:saved, event}, socket) do
    {:noreply, stream_insert(socket, :events, event)}
  end

  def handle_info({:join_room, info}, socket) do
    socket =
      if socket.assigns.current_room == info.room_name do
        user = Chat.userinfo_from_id(info.user_id)
        put_flash(socket, :info, "#{user.name} join this room!")
      else
        if(Chat.user_in_room?(socket.assigns.current_user.id, info.room_name)) do
          stream_insert(socket, :rooms, %{id: info.room_name, name: info.room_name})
        else
          socket
        end
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = Chat.get_event!(id)
    {:ok, _} = Chat.delete_event(event)

    {:noreply, stream_delete(socket, :events, event)}
  end

  @impl true
  def handle_event("send", %{"content" => content}, socket) do
    %{assigns: %{current_user_info: current_user_info, current_room: current_room}} = socket

    case Chat.create_event(%{
           sender: current_user_info.name,
           payload: content,
           type: :msg,
           room: current_room
         }) do
      {:ok, event} ->
        {:noreply,
         socket
         |> assign_form(Chat.change_event(%Event{}, %{content: ""}))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl true
  def handle_event(
        "send-join-room",
        %{"join-room-input" => room_name},
        %{assigns: %{current_user: current_user}} = socket
      ) do
    Chat.join_room(current_user.id, room_name)
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "send-join-user",
        %{"join-user-input" => user_email},
        %{assigns: %{current_user: current_user}} = socket
      ) do
    socket =
      if is_nil(Chat.connect_to_user(current_user, user_email)) do
        put_flash(socket, :info, "User doesn't exit!")
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "switch-room",
        %{"target" => target_room},
        %{assigns: %{current_user: current_user}} = socket
      ) do
    socket =
      socket
      |> assign(current_room: target_room)
      |> stream(:rooms, Chat.list_rooms(current_user.id))
      |> stream(
        :events,
        Chat.list_last_events(20) |> Enum.filter(&(&1.room == target_room)),
        reset: true
      )
      |> assign(page_title: "Room: #{target_room}")

    {:noreply, socket}
  end

  defp assign_form(socket, changeset) do
    assign(socket, msg_input: to_form(changeset))
  end
end
