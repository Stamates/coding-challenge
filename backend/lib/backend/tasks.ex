defmodule Backend.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias Backend.Repo

  alias Backend.Tasks.{Group, Task}

  # Task CRUD
  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_group_tasks(group)
      [%Task{}, ...]

  """
  @spec list_group_tasks(Group.t() | pos_integer()) :: list(Task.t())
  def list_group_tasks(%Group{} = group) do
    group.id |> Task.by_group() |> Repo.all()
  end

  def list_group_tasks(group_id) do
    group_id |> Task.by_group() |> Repo.all()
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_task!(pos_integer()) :: Task.t()
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_task(term()) :: {:ok, Task.t()} | {:error, Ecto.Changeset.t()}
  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
    |> maybe_lock_parent()
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_task(Task.t(), term()) :: {:ok, Task.t()} | {:error, Ecto.Changeset.t()}
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
    |> maybe_lock_parent()
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_task(Task.t()) :: {:ok, Task.t()} | {:error, Ecto.Changeset.t()}
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  @spec change_task(Task.t(), term()) :: Ecto.Changeset.t()
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  @spec preload_dependencies(Task.t() | [Task.t()]) :: Task.t() | [Task.t()]
  def preload_dependencies(task), do: Repo.preload(task, :dependencies)

  @spec maybe_lock_parent({:ok, Task.t()} | {:error, Ecto.Changeset.t()}) ::
          {:ok, Task.t()} | {:error, Ecto.Changeset.t()}
  def maybe_lock_parent({:error, changeset}), do: {:error, changeset}
  def maybe_lock_parent({:ok, %Task{parent_id: nil} = task}), do: {:ok, task}

  def maybe_lock_parent({:ok, %Task{completed_at: completed} = task}) when not is_nil(completed),
    do: {:ok, task}

  def maybe_lock_parent({:ok, %Task{parent_id: parent_id} = task}) do
    parent_id |> get_task!() |> update_task(%{completed_at: nil, locked: true})
    {:ok, task}
  end

  # Group CRUD
  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  @spec list_groups :: list(Task.t())
  def list_groups do
    Repo.all(Group)
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_group!(pos_integer()) :: Group.t()
  def get_group!(id), do: Repo.get!(Group, id)

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_group(term()) :: {:ok, Group.t()} | {:error, Ecto.Changeset.t()}
  def create_group(attrs \\ %{}) do
    %Group{}
    |> Group.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_group(Group.t(), term()) :: {:ok, Group.t()} | {:error, Ecto.Changeset.t()}
  def update_group(%Group{} = group, attrs) do
    group
    |> preload_tasks()
    |> Group.update_changeset(maybe_load_tasks(attrs))
    |> Repo.update()
  end

  @doc """
  Deletes a group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_group(Group.t() | pos_integer() | String.t()) ::
          {:ok, Group.t()} | {:error, Ecto.Changeset.t()}
  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end

  def delete_group(group_id) do
    group_id |> get_group!() |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{data: %Group{}}

  """
  @spec change_group(Group.t(), term()) :: Ecto.Changeset.t()
  def change_group(%Group{} = group, attrs \\ %{}) do
    Group.update_changeset(group, attrs)
  end

  @spec preload_tasks(Groug.t() | [Group.t()]) :: Group.t() | [Group.t()]
  def preload_tasks(group), do: Repo.preload(group, :tasks)

  @spec get_tasks_by_ids(list()) :: list(Task.t())
  def get_tasks_by_ids(task_ids), do: Repo.all(from(t in Task, where: t.id in ^task_ids))

  # Private
  defp maybe_load_tasks(%{task_ids: task_ids} = attrs) do
    Map.put(attrs, :tasks, get_tasks_by_ids(task_ids))
  end

  defp maybe_load_tasks(%{"task_ids" => task_ids} = attrs) do
    Map.put(attrs, "tasks", get_tasks_by_ids(task_ids))
  end

  defp maybe_load_tasks(attrs), do: attrs
end
