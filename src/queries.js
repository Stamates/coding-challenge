import { gql } from '@apollo/client'

export const GET_ALL_GROUPS = gql`
query {
  groups {
    id
    name
    tasks {
      id
    }
  }
}
`

export const ADD_GROUP = gql`
mutation CreateGroup($name: String!) {
  createGroup(group: {name: $name}) {
    id
    name
  }
}
`

export const DELETE_GROUP = gql`
mutation DeleteGroup($id: ID!) {
  deleteGroup(id: $id) {
    id
  }
}
`

export const GET_GROUP_TASKS = gql`
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
`


export const ADD_TASK = gql`
mutation CreateTask($name: String!, $group_id: ID!) {
  createTask(task: {name: $name, group_id: $group_id}) {
    id
    name
  }
}
`

export const DELETE_TASK = gql`
mutation DeleteTask($id: ID!) {
  deleteTask(id: $id) {
    id
  }
}
`