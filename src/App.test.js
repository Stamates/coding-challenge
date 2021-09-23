import { render, screen, fireEvent } from '@testing-library/react'
import { act } from 'react-dom/test-utils'
import { MockedProvider } from '@apollo/client/testing'
import App from './App'
import { GET_ALL_GROUPS } from './queries'

const mocks = [
  {
    request: {
      query: GET_ALL_GROUPS
    },
    result: {
      data: {
        groups: [{
          id: '1', name: 'new group', tasks: [{ id: '1' }]
        }]
      }
    }
  }
]

test('renders group list', async () => {
  render(
    <MockedProvider mocks={mocks} addTypename={false} >
      <App />
    </MockedProvider>
  )

  const groupsHeader = screen.getByText(/Things To Do/i)
  expect(groupsHeader).toBeInTheDocument()

  await act(async () => {
    await new Promise((resolve) => setTimeout(resolve, 0));
  })

  const groupName = screen.getByText(/new group/i)
  expect(groupName).toBeInTheDocument()
})

test('can navigate to group tasks and back', async () => {
  render(
    <MockedProvider mocks={mocks} addTypename={false} >
      <App />
    </MockedProvider>
  )

  await act(async () => {
    await new Promise((resolve) => setTimeout(resolve, 0));
  })

  const groupsHeader = screen.getByText(/Things To Do/i)
  const groupName = screen.getByText(/new group/i)
  fireEvent.click(groupName)

  const groupsLink = screen.getByText(/all groups/i)
  expect(groupsLink).toBeInTheDocument()
  expect(groupsHeader).not.toBeInTheDocument()

  fireEvent.click(groupsLink)

  expect(screen.getByText(/Things To Do/i)).toBeInTheDocument()
})
