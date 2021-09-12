defmodule Backend.Tasks.Task do
  @moduledoc """
  Ecto Schema and functions for working with Tasks
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "tasks" do
    field(:completed_at, :utc_datetime)
    field(:name, :string)
    field(:locked, :boolean, default: false)
    belongs_to(:group, Backend.Tasks.Group)
    belongs_to(:parent, __MODULE__)
    has_many(:dependencies, __MODULE__, foreign_key: :parent_id)

    timestamps()
  end

  @doc """
  Creates a changeset for a Task.
  """
  @spec changeset(%__MODULE__{}, term()) :: Ecto.Changeset.t()
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:completed_at, :group_id, :locked, :name, :parent_id])
    |> validate_required([:name])
    |> enforce_lock()
  end

  @doc """
  Creates a query retrieving tasks for a given group_id.
  """
  @spec by_group(pos_integer(), Ecto.Query.t() | __MODULE__) :: Ecto.Query.t()
  def by_group(group_id, query \\ __MODULE__) do
    from q in query,
      where: q.group_id == ^group_id
  end

  defp enforce_lock(
         %Ecto.Changeset{changes: %{completed_at: completed}, data: %{locked: true}} = changeset
       )
       when not is_nil(completed) do
    add_error(
      changeset,
      :completed_at,
      "Can't complted task until all dependent tasks are complete."
    )
  end

  defp enforce_lock(changeset), do: changeset
end
