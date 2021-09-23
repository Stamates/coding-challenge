import React, { useState } from 'react'
import { useMutation } from '@apollo/client'
// import { useAddGroup } from '../clientresolver'
import { ADD_GROUP, GET_ALL_GROUPS } from '../queries'

export default function AddGroup({ setGroups }) {
  const [task, setTask] = useState("")
  const [addGroup] = useMutation(
    ADD_GROUP,
    {
      refetchQueries: [
        { query: GET_ALL_GROUPS }
      ]
    }
  )

  return (
    <div className='App-add-item'>
      <input
        placeholder="group name"
        onChange={e => setTask(e.target.value)}
        value={task}
      />
      <button
        onClick={() => {
          setTask("")
          const { data } = addGroup({
            variables: {
              name: task
            }
          })
          setGroups(data)
        }}
      >
        Add Group
      </button>
    </div>
  )
}