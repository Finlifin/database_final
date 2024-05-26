defmodule DatabaseFinal.Repo do
  use Ecto.Repo,
    otp_app: :database_final,
    adapter: Ecto.Adapters.Postgres
end
