import React, { useState } from 'react'
import { useMutation } from '@apollo/client'
import { ADD_TASK, GET_GROUP_TASKS } from '../queries'

export default function AddTask({ group, setTasks }) {
  const [name, setName] = useState("")
  const [addTask] = useMutation(
    ADD_TASK, {
    refetchQueries: [{
      query: GET_GROUP_TASKS,
      variables: { group_id: group.id }
    }]
  }
  )

  return (
    <div className='App-add-item'>
      <input
        placeholder='task name'
        className='App-text-input'
        onChange={e => setName(e.target.value)}
        value={name}
      />
      <button
        onClick={() => {
          setName("")
          const { data } = addTask({
            variables: {
              name: name,
              group_id: group.id
            }
          })
          setTasks(data)
        }}
      >
        Add Task
      </button>
    </div>
  )
}