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
