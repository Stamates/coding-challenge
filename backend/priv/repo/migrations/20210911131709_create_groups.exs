defmodule Backend.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string
      add :completed_at, :utc_datetime

      timestamps()
    end

    create unique_index(:groups, [:name])
  end
end
