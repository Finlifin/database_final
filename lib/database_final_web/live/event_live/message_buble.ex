defmodule DatabaseFinalWeb.EventLive.MessageBuble do
  use DatabaseFinalWeb, :live_component
  use Timex

  def render(assigns) do
    ~H"""
    <div class="py-3 my-2">
      <button class={[
        "phx-submit-loading:opacity-75 rounded-md bg-zinc-900 hover:bg-zinc-700 py-2 px-3",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
        "text-left"
      ]}>
        <div class="text-[1.2em]">@<%= @event.sender %></div>
        <div class="text-[2em]"><%= @event.payload %></div>
      </button>
      <div class="text-[0.8em] pl-3"><%= @event.inserted_at %></div>
    </div>
    """
  end
end
