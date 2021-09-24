defmodule BackendWeb.SchemaTest do
  use BackendWeb.ConnCase

  alias Backend.Tasks.Task

  describe "groups" do
    @groups """
    query Groups {
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
    query Group($id: ID!) {
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

    @create_group """
    mutation CreateGroup {
      createGroup(group: {name: "new group"}) {
        id
        name
      }
    }
    """
    test "mutation: createGroup", %{conn: conn} do
      conn = post(conn, "/graphiql", %{"query" => @create_group})

      assert %{
               "data" => %{
                 "createGroup" => %{
                   "id" => group_id,
                   "name" => "new group"
                 }
               }
             } = json_response(conn, 200)

      assert group_id
    end

    test "mutation: updateGroup", %{conn: conn} do
      group = group_fixture()
      existing_group_task = task_fixture(group_id: group.id)
      ungrouped_task = task_fixture()
      group_id = "#{group.id}"
      existing_group_task_id = "#{existing_group_task.id}"
      ungrouped_task_id = "#{ungrouped_task.id}"

      update_group = """
      mutation UpdateGroup {
        updateGroup(
            id: #{group_id},
            group: {
              name: "updated group",
              task_ids: [#{existing_group_task_id}, #{ungrouped_task_id}],
            }
          ) {
          id
          name
          tasks {
            id
          }
        }
      }
      """

      conn = post(conn, "/graphiql", %{"query" => update_group})

      assert %{
               "data" => %{
                 "updateGroup" => %{
                   "id" => ^group_id,
                   "name" => "updated group",
                   "tasks" => tasks
                 }
               }
             } = json_response(conn, 200)

      assert MapSet.equal?(
               tasks |> Enum.map(& &1["id"]) |> MapSet.new(),
               MapSet.new([existing_group_task_id, ungrouped_task_id])
             )
    end

    test "mutation: deleteGroup", %{conn: conn} do
      group = group_fixture()
      existing_group_task = task_fixture(group_id: group.id)
      group_id = "#{group.id}"

      delete_group = """
      mutation DeleteGroup {
        deleteGroup(id: #{group_id}) {
          id
        }
      }
      """

      conn = post(conn, "/graphiql", %{"query" => delete_group})

      assert %{
               "data" => %{
                 "deleteGroup" => %{
                   "id" => ^group_id
                 }
               }
             } = json_response(conn, 200)

      assert_raise(Ecto.NoResultsError, fn -> Backend.Tasks.get_task!(existing_group_task.id) end)
    end
  end

  describe "tasks" do
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
      parent_id = "#{parent_task.id}"
      name = parent_task.name
      task_id = "#{task.id}"
      conn = post(conn, "/graphiql", %{"query" => @task, "variables" => %{id: parent_id}})

      assert %{
               "data" => %{
                 "task" => %{
                   "id" => ^parent_id,
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

    test "mutation: createTask", %{conn: conn} do
      group = group_fixture()
      parent_task = task_fixture()
      group_id = "#{group.id}"
      parent_id = "#{parent_task.id}"

      create_task = """
      mutation CreateTask {
        createTask(task: {name: "new task", group_id: #{group_id}, parent_id: #{parent_id}}) {
          id
          name
          group_id
          parent_id
        }
      }
      """

      conn = post(conn, "/graphiql", %{"query" => create_task})

      assert %{
               "data" => %{
                 "createTask" => %{
                   "id" => task_id,
                   "name" => "new task",
                   "group_id" => ^group_id,
                   "parent_id" => ^parent_id
                 }
               }
             } = json_response(conn, 200)

      assert task_id
    end

    test "mutation: updateTask", %{conn: conn} do
      group = group_fixture()
      parent_task = task_fixture()
      task = task_fixture(group_id: group.id, parent_id: parent_task.id)
      new_group = group_fixture()
      new_group_id = "#{new_group.id}"
      task_id = "#{task.id}"

      update_task = """
      mutation UpdateTask {
        updateTask(
            id: #{task_id},
            task: {
              name: "updated task",
              group_id: #{new_group_id},
              parent_id: null,
              completed_at: "2021-09-20T12:00:00.000000Z"
            }
          ) {
          id
          name
          group_id
          parent_id
          completed_at
        }
      }
      """

      conn = post(conn, "/graphiql", %{"query" => update_task})

      assert %{
               "data" => %{
                 "updateTask" => %{
                   "id" => ^task_id,
                   "name" => "updated task",
                   "group_id" => ^new_group_id,
                   "parent_id" => nil,
                   "completed_at" => completion_date
                 }
               }
             } = json_response(conn, 200)

      assert completion_date == "2021-09-20 12:00:00Z"
    end

    test "mutation: deleteTask", %{conn: conn} do
      task = task_fixture()
      task_id = "#{task.id}"

      delete_task = """
      mutation DeleteTask {
        deleteTask(id: #{task_id}) {
          id
        }
      }
      """

      conn = post(conn, "/graphiql", %{"query" => delete_task})

      assert %{
               "data" => %{
                 "deleteTask" => %{
                   "id" => ^task_id
                 }
               }
             } = json_response(conn, 200)
    end
  end
end
