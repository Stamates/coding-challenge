defmodule BackendWeb.Schema do
  @moduledoc """
  GraphQL Schema for defining types, queries, and resolvers
  """
  use Absinthe.Schema

  alias Backend.Tasks

  object :group do
    field(:id, non_null(:id))
    field(:name, non_null(:string))
    field(:tasks, list_of(non_null(:task)))
    field(:completed_at, :string)
  end

  input_object :create_group_params do
    field(:name, non_null(:string))
  end

  input_object :update_group_params do
    field(:name, non_null(:string))
    field(:task_ids, list_of(:id))
  end

  object :task do
    field(:id, non_null(:id))
    field(:group_id, non_null(:id))
    field(:name, non_null(:string))
    field(:parent_id, :id)
    field(:dependencies, list_of(non_null(:task)))
    field(:completed_at, :string)
    field(:locked, non_null(:boolean))
  end

  input_object :create_task_params do
    field(:group_id, non_null(:id))
    field(:name, non_null(:string))
    field(:parent_id, :id)
  end

  input_object :update_task_params do
    field(:group_id, non_null(:id))
    field(:name, non_null(:string))
    field(:parent_id, :id)
    field(:completed_at, :string)
  end

  query do
    @desc "Get all groups"
    field :groups, list_of(:group) do
      resolve(fn _, _ -> {:ok, Tasks.list_groups() |> Tasks.preload_tasks()} end)
    end

    @desc "Get group by id"
    field :group, non_null(:group) do
      arg(:id, non_null(:id))
      resolve(&fetch_group/2)
    end

    @desc "Get all tasks for group"
    field :tasks, list_of(non_null(:task)) do
      arg(:group_id, non_null(:id))
      resolve(&all_tasks_for_group/2)
    end

    @desc "Get group by id"
    field :task, non_null(:task) do
      arg(:id, non_null(:id))
      resolve(&fetch_task/2)
    end
  end

  mutation do
    @desc "Create a group"
    field :create_group, type: :group do
      arg(:group, :create_group_params)
      resolve(&create_group/2)
    end

    @desc "Update a group"
    field :update_group, type: :group do
      arg(:id, non_null(:id))
      arg(:group, :update_group_params)
      resolve(&update_group/2)
    end

    @desc "Delete a group"
    field :delete_group, type: :group do
      arg(:id, non_null(:id))
      resolve(fn %{id: id}, _ -> Tasks.delete_group(id) end)
    end

    @desc "Create a task"
    field :create_task, type: :task do
      arg(:task, :create_task_params)
      resolve(&create_task/2)
    end

    @desc "Update a task"
    field :update_task, type: :task do
      arg(:id, non_null(:id))
      arg(:task, :update_task_params)
      resolve(&update_task/2)
    end

    @desc "Delete a task"
    field :delete_task, type: :task do
      arg(:id, non_null(:id))
      resolve(fn %{id: id}, _ -> Tasks.delete_task(id) end)
    end
  end

  defp all_tasks_for_group(%{group_id: group_id} = _args, _info) do
    {:ok, group_id |> Tasks.list_group_tasks() |> Tasks.preload_dependencies()}
  end

  defp fetch_group(%{id: id} = _args, _info) do
    {:ok, id |> Tasks.get_group!() |> Tasks.preload_tasks()}
  end

  defp fetch_task(%{id: id} = _args, _info) do
    {:ok, id |> Tasks.get_task!() |> Tasks.preload_dependencies()}
  end

  defp create_group(%{group: params}, _info) do
    Tasks.create_group(params)
  end

  defp update_group(%{id: group_id, group: params}, _info) do
    group_id
    |> Tasks.get_group!()
    |> Tasks.update_group(params)
    |> case do
      {:ok, group} -> {:ok, Tasks.preload_tasks(group)}
      error -> error
    end
  end

  defp create_task(%{task: params}, _info) do
    Tasks.create_task(params)
  end

  defp update_task(%{id: task_id, task: params}, _info) do
    task_id
    |> Tasks.get_task!()
    |> Tasks.update_task(maybe_convert_datetime(params))
    |> case do
      {:ok, task} -> {:ok, Tasks.preload_dependencies(task)}
      error -> error
    end
  end

  defp maybe_convert_datetime(%{completed_at: nil} = params), do: params

  defp maybe_convert_datetime(%{completed_at: completed_at} = params) do
    case DateTime.from_iso8601(completed_at) do
      {:ok, datetime, _} -> Map.put(params, :completed_at, datetime)
      error -> error
    end
  end
end
