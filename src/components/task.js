import React, { useState } from 'react'
import { useMutation } from '@apollo/client'
import { DELETE_TASK, GET_GROUP_TASKS, COMPLETE_TASK } from '../queries'

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
      <Completion task={task} />
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

function Completion({ task }) {
  const [completeTask] = useMutation(COMPLETE_TASK)
  const [completed, setCompletion] = useState(!!task.completed_at)

  if (completed) {
    return (
      <img
        className='Task-completion'
        src='/completed.svg'
        alt='Completed'
        onClick={() => {
          completeTask({ variables: { id: task.id, completed_at: null } })
          setCompletion(false)
        }}
      />
    )
  } else if (task.locked) {
    return <img className='Task-completion' src='/locked.svg' alt='Locked' />
  }
  return (
    <input
      className='Task-completion'
      type='checkbox'
      onClick={() => {
        completeTask({ variables: { id: task.id, completed_at: Math.floor((new Date()).getTime() / 1000) } })
        setCompletion(true)
      }}
    />
  )
}