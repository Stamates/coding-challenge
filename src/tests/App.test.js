import { renderApollo, screen } from './testUtils'
import userEvent from '@testing-library/user-event'
import { act } from 'react-dom/test-utils'
import App from '../App'
import { ADD_GROUP, DELETE_GROUP, GET_ALL_GROUPS } from '../queries'

const mocks = [
  {
    request: {
      query: GET_ALL_GROUPS
    },
    result: {
      data: {
        groups: [
          { id: '1', name: 'new group', tasks: [{ id: '1' }] }
        ]
      }
    }
  },
  {
    request: {
      query: ADD_GROUP,
      variables: { name: 'newly added group' }
    },
    result: { data: { id: '2', name: 'newly added group' } }
  },
  {
    request: {
      query: GET_ALL_GROUPS
    },
    result: {
      data: {
        groups: [
          { id: '1', name: 'new group', tasks: [{ id: '1' }] },
          { id: '2', name: 'newly added group', tasks: [] }
        ]
      }
    }
  }
]

test('renders group list', async () => {
  renderApollo(<App />, { mocks })

  const groupsHeader = screen.getByText(/things to do/i)
  expect(groupsHeader).toBeInTheDocument()

  await act(async () => {
    await new Promise((resolve) => setTimeout(resolve, 0));
  })

  expect(screen.getByText(/new group/i)).toBeInTheDocument()
})

test('can navigate to group tasks and back', async () => {
  renderApollo(<App />, { mocks })

  await act(async () => {
    await new Promise((resolve) => setTimeout(resolve, 0));
  })

  const groupsHeader = screen.getByText(/things to do/i)
  userEvent.click(screen.getByText(/new group/i))

  const groupsLink = screen.getByText(/all groups/i)
  expect(groupsLink).toBeInTheDocument()
  expect(groupsHeader).not.toBeInTheDocument()

  userEvent.click(groupsLink)

  expect(screen.getByText(/things to do/i)).toBeInTheDocument()
})

test('can add a group', async () => {
  renderApollo(<App />, { mocks })

  await act(async () => {
    await new Promise((resolve) => setTimeout(resolve, 0));
  })

  const addGroup = screen.getByText(/add group/i)

  userEvent.type(screen.getByPlaceholderText(/group name/i), 'newly added group')
  userEvent.click(addGroup)

  await act(async () => {
    await new Promise((resolve) => setTimeout(resolve, 0));
  })

  expect(screen.getByText(/newly added group/i)).toBeInTheDocument()
})

const deleteMocks = [
  {
    request: {
      query: GET_ALL_GROUPS
    },
    result: {
      data: {
        groups: [
          { id: '1', name: 'new group', tasks: [{ id: '1' }] }
        ]
      }
    }
  },
  {
    request: {
      query: GET_ALL_GROUPS
    },
    result: { data: { groups: [] } }
  },
  {
    request: {
      query: DELETE_GROUP,
      variables: { id: '1' }
    },
    result: { data: { id: '1' } }
  }
]

test('can delete a group', async () => {
  renderApollo(<App />, { mocks: deleteMocks })

  await act(async () => {
    await new Promise((resolve) => setTimeout(resolve, 0));
  })

  const deleteGroup = screen.getByText(/delete/i)

  userEvent.click(deleteGroup)

  await act(async () => {
    await new Promise((resolve) => setTimeout(resolve, 0));
  })

  expect(screen.queryByText(/new group/i)).toBeNull()
  expect(screen.queryByText(/no groups exist/i)).toBeInTheDocument()
})