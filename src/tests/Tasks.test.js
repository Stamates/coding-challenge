import { renderApollo, screen } from './testUtils'
import userEvent from '@testing-library/user-event'
import { act } from 'react-dom/test-utils'
import Tasks from '../components/tasks'
import { ADD_TASK, DELETE_TASK, GET_GROUP_TASKS } from '../queries'

const group = { id: '1', name: 'basic group' }

const mocks = [
  {
    request: {
      query: GET_GROUP_TASKS,
      variables: { group_id: '1' }
    },
    result: {
      data: {
        tasks: [
          { id: '1', name: 'new task', group_id: '1', dependencies: [], completed_at: null, locked: false }
        ]
      }
    }
  },
  {
    request: {
      query: ADD_TASK,
      variables: { name: 'another', group_id: '1' }
    },
    result: { data: { id: '2', name: 'another task' } }
  },
  {
    request: {
      query: GET_GROUP_TASKS,
      variables: { group_id: '1' }
    },
    result: {
      data: {
        tasks: [
          { id: '1', name: 'new task', group_id: '1', dependencies: [], completed_at: null, locked: false },
          { id: '2', name: 'another task', group_id: '1', dependencies: [], completed_at: null, locked: false }
        ]
      }
    }
  }
]

test('renders group task list', async () => {
  renderApollo(<Tasks group={group} />, { mocks })

  await act(async () => {
    await new Promise((resolve) => setTimeout(resolve, 0));
  })

  expect(screen.getByText(/new task/i)).toBeInTheDocument()
})

// test('can add a task', async () => {
//   renderApollo(<Tasks group={group} />, { mocks })

//   await act(async () => {
//     await new Promise((resolve) => setTimeout(resolve, 0));
//   })

//   const addTask = screen.getByText(/add task/i)

//   userEvent.type(screen.getByPlaceholderText(/task name/i), 'another task')
//   userEvent.click(addTask)

//   await act(async () => {
//     await new Promise((resolve) => setTimeout(resolve, 0));
//   })

//   expect(screen.getByText(/another task/i)).toBeInTheDocument()
// })

const deleteMocks = [
  {
    request: {
      query: GET_GROUP_TASKS,
      variables: { group_id: '1' }
    },
    result: {
      data: {
        tasks: [
          { id: '1', name: 'new task', group_id: '1', dependencies: [], completed_at: null, locked: false }
        ]
      }
    }
  },
  {
    request: {
      query: DELETE_TASK,
      variables: { id: '1' }
    },
    result: { data: { id: '1' } }
  },
  {
    request: {
      query: GET_GROUP_TASKS,
      variables: { group_id: '1' }
    },
    result: { data: { tasks: [] } }
  }

]

test('can delete a task', async () => {
  renderApollo(<Tasks group={group} />, { mocks: deleteMocks })

  await act(async () => {
    await new Promise((resolve) => setTimeout(resolve, 0));
  })

  const deleteGroup = screen.getByText(/delete/i)

  userEvent.click(deleteGroup)

  await act(async () => {
    await new Promise((resolve) => setTimeout(resolve, 0));
  })

  expect(screen.queryByText(/new task/i)).toBeNull()
  expect(screen.queryByText(/no tasks exist/i)).toBeInTheDocument()
})