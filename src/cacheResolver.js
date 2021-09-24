import { InMemoryCache } from '@apollo/client'

export const cacheResolver = new InMemoryCache({
  typePolicies: {
    Groups: {
      fields: {
        groups: {
          merge: false,
        }
      },
    },
    Group: {
      fields: {
        tasks: {
          merge: false,
        }
      },
    },
    Tasks: {
      fields: {
        tasks: {
          merge: true,
        }
      },
    },
    Task: {
      fields: {
        tasks: {
          merge: true,
        }
      },
    },
  },
})