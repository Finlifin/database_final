defmodule DatabaseFinal.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :sender, :string
      add :type, :string
      add :payload, :string
      add :room, :string

      timestamps(type: :utc_datetime)
    end
  end
end
