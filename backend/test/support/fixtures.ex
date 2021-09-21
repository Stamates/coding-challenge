defmodule Backend.Fixtures do
  alias Backend.Tasks

  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(valid_attrs())
      |> Tasks.create_task()

    task
  end

  def group_fixture(attrs \\ %{}) do
    {:ok, group} =
      attrs
      |> Enum.into(valid_group_attrs())
      |> Tasks.create_group()

    group
  end

  # Private
  defp valid_attrs, do: %{name: "some task #{:rand.uniform(1_000)}"}
  defp valid_group_attrs, do: %{name: "some group #{:rand.uniform(1_000)}"}
end
