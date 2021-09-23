import { render, screen } from '@testing-library/react'
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

  const textElement = screen.getByText(/Things To Do/i)
  expect(textElement).toBeInTheDocument()

  await act(async () => {
    await new Promise((resolve) => setTimeout(resolve, 0));
  })

  const groupName = screen.getByText(/new group/i)
  expect(groupName).toBeInTheDocument()
})
