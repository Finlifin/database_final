defmodule DatabaseFinal.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :user_id, :integer
      add :room_name, :string

      timestamps(type: :utc_datetime)
    end
  end
end
