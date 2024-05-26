defmodule DatabaseFinal.Chat.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :type, Ecto.Enum, values: [:msg, :img, :join, :leave]
    field :payload, :string
    field :sender, :string
    field :room, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:sender, :type, :payload, :room])
    |> validate_required([:sender, :type, :payload, :room])
  end
end
