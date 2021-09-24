import React, { useState } from 'react'
import { useMutation, useQuery } from '@apollo/client'
import { DELETE_TASK, GET_TASK, GET_GROUP_TASKS, COMPLETE_TASK } from '../queries'

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
      <TaskDescription task={task} />
      <span className='App-header-link' onClick={() => {
        deleteTask({ variables: { id: task.id } })
      }}
      >
        Delete
      </span>
    </div >
  )
}

function TaskDescription({ task }) {
  const { loading, error, data } = useQuery(GET_TASK, { variables: { id: task.parent_id } })
  if (!task.parent_id) return task.name
  if (loading) return task.name
  if (error) return task.name

  return <span>{task.name} <span style={{ color: 'gray', fontStyle: 'italic' }}>- parent[{data.task.name}]</span></span>
}

function Completion({ task }) {
  const [completeTask] = useMutation(COMPLETE_TASK,
    {
      refetchQueries: [{
        query: GET_GROUP_TASKS,
        variables: { group_id: task.group_id }
      }]
    })
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
    return <img className='Task-completion' style={{ transform: 'scale(1.5)', marginLeft: '5px' }} src='/locked.svg' alt='Locked' />
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