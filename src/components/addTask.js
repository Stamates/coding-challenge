import React, { useState } from 'react'
import { useMutation, useQuery } from '@apollo/client'
import { ADD_TASK, GET_GROUP_TASKS, GET_ALL_TASKS } from '../queries'

export default function AddTask({ group, setTasks }) {
  const [name, setName] = useState("")
  const [parentId, setParentId] = useState(null)
  const [addTask] = useMutation(
    ADD_TASK, {
    refetchQueries: [{
      query: GET_GROUP_TASKS,
      variables: { group_id: group.id }
    }]
  })

  return (
    <div className='App-add-item'>
      <input
        placeholder='task name'
        className='App-text-input'
        onChange={e => setName(e.target.value)}
        value={name}
      />
      <ParentSelector setParentId={setParentId} />
      <button
        onClick={() => {
          setName("")
          const { data } = addTask({
            variables: {
              name: name,
              group_id: group.id,
              parent_id: parentId
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

function ParentSelector({ setParentId }) {
  const { loading, error, data } = useQuery(GET_ALL_TASKS)
  if (loading) return null
  if (error) return null
  if (data?.tasks.length === 0) return null

  return (
    <select
      name='parentTasks'
      id='parents'
      defaultValue=''
      className='Task-parent-selector'
      onChange={e => setParentId(e.target.value)}
    >
      <option value=''>Choose parent task...</option>
      {
        data.tasks.map((parent) => (
          <option value={parent.id} key={parent.id} >{parent.name}</option>
        ))
      }
    </select >
  )
}