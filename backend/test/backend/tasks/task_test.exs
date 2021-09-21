defmodule Backend.Tasks.TaskTest do
  use Backend.DataCase

  alias Backend.Tasks.Task

  test "changeset/1 valid changeset if completing an unlocked task" do
    task = task_fixture(locked: false)

    assert %Ecto.Changeset{valid?: true} =
             Task.changeset(task, %{completed_at: "2011-05-18T15:01:01Z"})
  end

  test "changeset/1 invalid changeset if trying to complete a locked task" do
    task = task_fixture(locked: true)

    assert %Ecto.Changeset{valid?: false} =
             Task.changeset(task, %{completed_at: "2011-05-18T15:01:01Z"})
  end
end
