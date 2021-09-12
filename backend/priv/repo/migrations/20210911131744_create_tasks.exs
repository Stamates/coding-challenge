defmodule Backend.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add(:name, :string)
      add(:completed_at, :utc_datetime)
      add(:locked, :boolean, default: false)
      add(:group_id, references(:groups, on_delete: :nothing))
      add(:parent_id, references(:tasks, on_delete: :nothing))

      timestamps()
    end

    create(index(:tasks, [:group_id]))
    create(index(:tasks, [:parent_id]))
  end
end
