defmodule DatabaseFinal.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :user_id, :integer
    field :room_name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:user_id, :room_name])
    |> validate_required([:user_id, :room_name])
  end
end
