defmodule BackendWeb.SchemaTest do
  use BackendWeb.ConnCase

  alias Backend.Tasks.Task

  @groups """
  query groups {
    groups {
      id
      name
      tasks {
        id
      }
      completed_at
    }
  }
  """
  test "query: groups", %{conn: conn} do
    group = group_fixture()
    task = task_fixture(group_id: group.id)
    group_id = "#{group.id}"
    name = group.name
    task_id = "#{task.id}"
    conn = post(conn, "/graphiql", %{"query" => @groups})

    assert %{
             "data" => %{
               "groups" => [
                 %{
                   "id" => ^group_id,
                   "name" => ^name,
                   "completed_at" => nil,
                   "tasks" => [
                     %{"id" => ^task_id}
                   ]
                 }
               ]
             }
           } = json_response(conn, 200)
  end

  @group """
  query group($id: ID!) {
    group(id: $id) {
      id
      name
      tasks {
        id
      }
      completed_at
    }
  }
  """
  test "query: group", %{conn: conn} do
    group = group_fixture()
    task = task_fixture(group_id: group.id)
    group_id = "#{group.id}"
    name = group.name
    task_id = "#{task.id}"
    conn = post(conn, "/graphiql", %{"query" => @group, "variables" => %{id: group_id}})

    assert %{
             "data" => %{
               "group" => %{
                 "id" => ^group_id,
                 "name" => ^name,
                 "completed_at" => nil,
                 "tasks" => [
                   %{"id" => ^task_id}
                 ]
               }
             }
           } = json_response(conn, 200)
  end

  @tasks_for_group """
  query tasksForGroup($group_id: ID!) {
    tasks(group_id: $group_id) {
      id
      name
      group_id
      dependencies {
        id
      }
      completed_at
      locked
    }
  }
  """
  test "query: all_tasks_for_group", %{conn: conn} do
    group = group_fixture()
    %Task{id: id, name: name} = task = task_fixture(group_id: group.id)

    %Task{id: dependent_id, name: dependent_name} =
      task_fixture(group_id: group.id, parent_id: task.id)

    task_id = "#{id}"
    dependent_task_id = "#{dependent_id}"
    _other_group_task = task_fixture()

    conn =
      post(conn, "/graphiql", %{
        "query" => @tasks_for_group,
        "variables" => %{group_id: group.id}
      })

    assert %{
             "data" => %{
               "tasks" => [
                 %{
                   "id" => ^task_id,
                   "name" => ^name,
                   "completed_at" => nil,
                   "locked" => true,
                   "dependencies" => [
                     %{
                       "id" => ^dependent_task_id
                     }
                   ]
                 },
                 %{
                   "id" => ^dependent_task_id,
                   "name" => ^dependent_name,
                   "completed_at" => nil,
                   "locked" => false,
                   "dependencies" => []
                 }
               ]
             }
           } = json_response(conn, 200)
  end

  @task """
  query task($id: ID!) {
    task(id: $id) {
      id
      name
      group_id
      dependencies {
        id
      }
      completed_at
      locked
    }
  }
  """
  test "query: task", %{conn: conn} do
    group = group_fixture()
    parent_task = task_fixture(group_id: group.id)
    task = task_fixture(parent_id: parent_task.id)
    group_id = "#{group.id}"
    parent_task_id = "#{parent_task.id}"
    name = parent_task.name
    task_id = "#{task.id}"
    conn = post(conn, "/graphiql", %{"query" => @task, "variables" => %{id: parent_task_id}})

    assert %{
             "data" => %{
               "task" => %{
                 "id" => ^parent_task_id,
                 "group_id" => ^group_id,
                 "name" => ^name,
                 "completed_at" => nil,
                 "locked" => true,
                 "dependencies" => [
                   %{"id" => ^task_id}
                 ]
               }
             }
           } = json_response(conn, 200)
  end
end
