import { gql } from '@apollo/client'

export const GET_ALL_GROUPS = gql`
query allGroups{
  groups {
    id
    name
    tasks {
      id
      completed_at
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


export const GET_ALL_TASKS = gql`
query allTasks {
  tasks {
    id
    name
    group_id
  }
}
`

export const GET_GROUP_TASKS = gql`
query tasksForGroup($group_id: ID!) {
  groupTasks(group_id: $group_id) {
    id
    name
    group_id
    parent_id
    dependencies {
      id
    }
    completed_at
    locked
  }
}
`

export const GET_TASK = gql`
query getTask ($id: ID){
  task(id: $id) {
    id
    name
  }
}
`

export const ADD_TASK = gql`
mutation CreateTask($name: String!, $group_id: ID!, $parent_id: ID) {
  createTask(task: {name: $name, group_id: $group_id, parent_id: $parent_id}) {
    id
    name
  }
}
`

export const COMPLETE_TASK = gql`
mutation CompleteTask($id: ID!, $completed_at: Int) {
  updateTask(id: $id, task: {completed_at: $completed_at}) {
    id
    name
    completed_at
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