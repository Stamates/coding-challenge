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
  const [completed, setCompletion] = useState(!!task.completed_at)

  return (
    <div className='App-list-item'>
      <Completion task={task} completed={completed} setCompletion={setCompletion} />
      <TaskDescription task={task} completed={completed} />
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
  const strikeThrough = task.completed_at ? 'Task-completed' : ''
  const { loading, error, data } = useQuery(GET_TASK, { variables: { id: task.parent_id } })
  if (!task.parent_id || loading || error) return <span className={strikeThrough} >{task.name}</span>

  return <span className={strikeThrough} >{task.name} <span className='Task-parent' >- parent[{data.task.name}]</span></span>
}

function Completion({ task, completed, setCompletion }) {
  const [completeTask] = useMutation(COMPLETE_TASK,
    {
      refetchQueries: [{
        query: GET_GROUP_TASKS,
        variables: { group_id: task.group_id }
      }]
    })

  if (completed) {
    return (
      <img
        className='Task-status'
        src='/completed.svg'
        alt='Completed'
        onClick={() => {
          completeTask({ variables: { id: task.id, completed_at: null } })
          setCompletion(false)
        }}
      />
    )
  } else if (task.locked) {
    return <img className='Task-status' style={{ transform: 'scale(1.5)', marginLeft: '5px' }} src='/locked.svg' alt='Locked' />
  }
  return (
    <img
      src='/incomplete.svg'
      alt='Incomplete'
      className='Task-status'
      onClick={() => {
        completeTask({ variables: { id: task.id, completed_at: Math.floor((new Date()).getTime() / 1000) } })
        setCompletion(true)
      }}
    />
  )
}