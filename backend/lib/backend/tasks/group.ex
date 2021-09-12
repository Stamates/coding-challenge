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
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:completed_at, :name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
