defmodule DatabaseFinal.Repo.Migrations.CreateUsersInfo do
  use Ecto.Migration

  def change do
    create table(:users_info) do
      add :name, :string
      add :bio, :string
      add :email, :string
      add :avatar, :string

      timestamps(type: :utc_datetime)
    end
  end
end
