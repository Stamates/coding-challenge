defmodule BackendWeb.Schema do
  @moduledoc """
  GraphQL Schema for defining types, queries, and resolvers
  """
  use Absinthe.Schema

  alias Backend.Tasks

  object :group do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :tasks, list_of(non_null(:task))
    field :completed_at, :string
  end

  object :task do
    field :id, non_null(:id)
    field :group_id, non_null(:id)
    field :name, non_null(:string)
    field :dependencies, list_of(non_null(:task))
    field :completed_at, :string
    field :locked, non_null(:boolean)
  end

  query do
    @desc "Get all groups"
    field :groups, list_of(:group) do
      resolve(fn _, _, _ -> {:ok, Tasks.list_groups() |> Tasks.preload_tasks()} end)
    end

    @desc "Get group by id"
    field :group, non_null(:group) do
      arg(:id, non_null(:id))
      resolve(&fetch_group/3)
    end

    @desc "Get all tasks for group"
    field :tasks, list_of(non_null(:task)) do
      arg(:group_id, non_null(:id))
      resolve(&all_tasks_for_group/3)
    end

    @desc "Get group by id"
    field :task, non_null(:task) do
      arg(:id, non_null(:id))
      resolve(&fetch_task/3)
    end
  end

  # defp all_groups(_root, _args, _info), do: {:ok, Tasks.list_groups()}

  defp all_tasks_for_group(_root, %{group_id: group_id} = _args, _info) do
    {:ok, group_id |> Tasks.list_group_tasks() |> Tasks.preload_dependencies()}
  end

  defp fetch_group(_root, %{id: id} = _args, _info) do
    {:ok, id |> Tasks.get_group!() |> Tasks.preload_tasks()}
  end

  defp fetch_task(_root, %{id: id} = _args, _info) do
    {:ok, id |> Tasks.get_task!() |> Tasks.preload_dependencies()}
  end
end
