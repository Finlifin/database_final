defmodule DatabaseFinal.UserInfo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users_info" do
    field :name, :string
    field :bio, :string
    field :email, :string
    field :avatar, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_info, attrs) do
    user_info
    |> cast(attrs, [:name, :bio, :email, :avatar])
    |> validate_required([:name, :bio, :email, :avatar])
  end
end
