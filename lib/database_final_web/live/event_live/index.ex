defmodule DatabaseFinalWeb.EventLive.Index do
  alias Phoenix.PubSub
  use DatabaseFinalWeb, :live_view

  alias DatabaseFinal.Chat
  alias DatabaseFinal.Chat.Event

  on_mount {DatabaseFinalWeb.UserAuth, :mount_current_user}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: PubSub.subscribe(DatabaseFinal.PubSub, "default_room")
    changeset = Chat.change_event(%Event{}, %{}) |> to_form()
    socket = assign(socket, msg_input: changeset)
    {:ok, stream(socket, :events, Chat.list_events())}
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
    |> assign(:page_title, "Listing Events")
    |> assign(:event, nil)
  end

  @impl true
  def handle_info({DatabaseFinal.EventLive.FormComponent, {:saved, event}}, socket) do
    {:noreply, stream_insert(socket, :events, event)}
  end

  def handle_info({:new_event, event}, socket) do
    {:noreply, stream_insert(socket, :events, event)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = Chat.get_event!(id)
    {:ok, _} = Chat.delete_event(event)

    {:noreply, stream_delete(socket, :events, event)}
  end
end
