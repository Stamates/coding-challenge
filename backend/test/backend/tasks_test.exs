defmodule Backend.TasksTest do
  use Backend.DataCase

  alias Backend.Tasks
  alias Backend.Tasks.{Group, Task}

  @valid_attrs %{name: "some task"}
  @update_attrs %{completed_at: "2011-05-18T15:01:01Z", name: "some updated task"}
  @invalid_attrs %{name: nil}

  @valid_group_attrs %{name: "some group"}
  @update_group_attrs %{completed_at: "2011-05-18T15:01:01Z", name: "some updated group"}
  @invalid_group_attrs %{name: nil}

  def task_fixture(attrs \\ %{}) do
    {:ok, task} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Tasks.create_task()

    task
  end

  def group_fixture(attrs \\ %{}) do
    {:ok, group} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Tasks.create_group()

    group
  end

  describe "tasks" do
    test "list_group_tasks/1 returns tasks related to a group" do
      group = group_fixture()
      task = task_fixture(group_id: group.id)
      assert Tasks.list_group_tasks(group) == [task]
    end

    test "list_group_tasks/1 returns tasks related to a group based on group_id" do
      group = group_fixture()
      task = task_fixture(group_id: group.id)
      assert Tasks.list_group_tasks(group.id) == [task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Tasks.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      assert {:ok, %Task{} = task} = Tasks.create_task(@valid_attrs)
      assert task.name == "some task"
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(@invalid_attrs)
    end

    test "create_task/1 with a parent task association" do
      parent_task = task_fixture()

      assert {:ok, %Task{} = task} =
               Tasks.create_task(%{name: "child task", parent_id: parent_task.id})

      assert task.name == "child task"
      assert task.parent_id == parent_task.id
      reloaded_parent_task = Tasks.get_task!(parent_task.id)
      assert reloaded_parent_task.locked
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()
      assert {:ok, %Task{} = task} = Tasks.update_task(task, @update_attrs)
      assert task.completed_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert task.name == "some updated task"
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_task(task, @invalid_attrs)
      assert task == Tasks.get_task!(task.id)
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Tasks.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Tasks.change_task(task)
    end

    test "preload_dependencies/1 loads dependent tasks" do
      %Task{id: parent_task_id} = parent_task = task_fixture()
      %Task{id: task_id} = task_fixture(parent_id: parent_task_id)

      assert %Task{id: ^parent_task_id, dependencies: [%Task{id: ^task_id}]} =
               Tasks.preload_dependencies(parent_task)
    end

    test "maybe_lock_parent/1 locks parent task if dependent task is incomplete" do
      parent_task = task_fixture(completed_at: "2011-05-18T15:01:01Z", locked: false)
      assert parent_task.completed_at
      task = task_fixture(parent_id: parent_task.id)
      {:ok, _task} = Tasks.maybe_lock_parent({:ok, task})
      reloaded_parent_task = Tasks.get_task!(parent_task.id)
      refute reloaded_parent_task.completed_at
      assert reloaded_parent_task.locked
    end

    test "maybe_lock_parent/1 does NOT change parent if child is complete" do
      parent_task = task_fixture()
      task = task_fixture(completed_at: "2011-05-18T15:01:01Z", parent_id: parent_task.id)
      assert {:ok, _task} = Tasks.maybe_lock_parent({:ok, task})
      assert parent_task == Tasks.get_task!(parent_task.id)
    end

    test "maybe_lock_parent/1 no_ops if no parent task" do
      task = task_fixture()
      assert {:ok, ^task} = Tasks.maybe_lock_parent({:ok, task})
    end

    test "maybe_lock_parent/1 returns error tuple" do
      task = task_fixture()
      assert {:error, _task} = Tasks.maybe_lock_parent({:error, task})
    end
  end

  describe "groups" do
    test "list_groups/0 returns groups related to a group" do
      group = group_fixture()
      assert Tasks.list_groups() == [group]
    end

    test "get_group!/1 returns the group with given id" do
      group = group_fixture()
      assert Tasks.get_group!(group.id) == group
    end

    test "create_group/1 with valid data creates a group" do
      assert {:ok, %Group{} = group} = Tasks.create_group(@valid_group_attrs)
      assert group.name == "some group"
    end

    test "create_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_group(@invalid_group_attrs)
    end

    test "update_group/2 with valid data updates the group" do
      group = group_fixture()
      assert {:ok, %Group{} = group} = Tasks.update_group(group, @update_group_attrs)
      assert group.completed_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert group.name == "some updated group"
    end

    test "update_group/2 with invalid data returns error changeset" do
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_group(group, @invalid_group_attrs)
      assert group == Tasks.get_group!(group.id)
    end

    test "delete_group/1 deletes the group" do
      group = group_fixture()
      assert {:ok, %Group{}} = Tasks.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_group!(group.id) end
    end

    test "change_group/1 returns a group changeset" do
      group = group_fixture()
      assert %Ecto.Changeset{} = Tasks.change_group(group)
    end

    test "preload_tasks/1 loads related tasks" do
      %Group{id: group_id} = group = group_fixture()
      %Task{id: task_id} = task_fixture(group_id: group_id)

      assert %Group{id: ^group_id, tasks: [%Task{id: ^task_id}]} = Tasks.preload_tasks(group)
    end
  end
end
