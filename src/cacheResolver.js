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
    Task: {
      fields: {
        tasks: {
          merge: true,
        }
      },
    },
  },
})