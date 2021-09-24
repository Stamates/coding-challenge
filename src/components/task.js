import React from 'react'
import { useMutation } from '@apollo/client'
import { DELETE_TASK, GET_GROUP_TASKS } from '../queries'

export default function Task({ task }) {
  const [deleteTask] = useMutation(DELETE_TASK,
    {
      refetchQueries: [{
        query: GET_GROUP_TASKS,
        variables: { group_id: task.group_id }
      }]
    }
  )

  return (
    <div className='App-list-item'>
      {task.name}
      <span className='App-header-link' onClick={() => {
        deleteTask({ variables: { id: task.id } })
      }}
      >
        Delete
      </span>
    </div >
  )
}
