defmodule Backend.Tasks.Group do
  @moduledoc """
  Ecto Schema and functions for working with Groups
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field(:completed_at, :utc_datetime)
    field(:name, :string)
    has_many(:tasks, Backend.Tasks.Task)

    timestamps()
  end

  @doc false
  def create_changeset(group, attrs) do
    group
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end

  def update_changeset(group, attrs) do
    group
    |> cast(attrs, [:completed_at, :name])
    |> validate_required([:name])
    |> unique_constraint(:name)
    |> maybe_add_tasks(attrs)
  end

  defp maybe_add_tasks(changeset, %{tasks: tasks}), do: put_assoc(changeset, :tasks, tasks)
  defp maybe_add_tasks(changeset, %{"tasks" => tasks}), do: put_assoc(changeset, :tasks, tasks)
  defp maybe_add_tasks(changeset, _attrs), do: changeset
end
