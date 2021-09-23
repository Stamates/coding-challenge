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
