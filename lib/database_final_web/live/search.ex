defmodule DatabaseFinalWeb.Search do
  alias DatabaseFinal.Chat.Event
  alias DatabaseFinal.Chat
  use DatabaseFinalWeb, :live_view

  on_mount {DatabaseFinalWeb.UserAuth, :mount_current_user}

  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        phx-change="search"
        inner_class="flex justify-center items-center gap-2 min-w-[300px]"
      >
        <.input
          field={@form[:content]}
          placeholder="Search a message..."
          label="content"
          name="content"
        />
      </.simple_form>
      <div>
        <div
          :for={{id, event} <- @streams.events}
          id={id}
          phx-update="replace"
          class="p-2 text-lg bg-[#00001212] m-3 rounded-md"
        >
          <strong class="text-bold"><%= event.sender %></strong>: <%= event.payload %>
          <div class="text-sm opacity-50">
            <%= event.inserted_at %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket)
      when not is_nil(current_user) do
    socket =
      socket
      |> assign(:form, Chat.change_event(%Event{}, %{}) |> to_form())
      |> stream(:events, [])

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
  def handle_event(
        "search",
        %{"content" => content},
        %{assigns: %{current_user: current_user}} = socket
      ) do
    socket =
      socket
      |> stream(:events, Chat.search_msg(current_user, content))

    {:noreply, socket}
  end
end
