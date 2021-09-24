import React, { useState } from 'react'
import { useMutation } from '@apollo/client'
import { ADD_GROUP, GET_ALL_GROUPS } from '../queries'

export default function AddGroup({ setGroups }) {
  const [name, setName] = useState("")
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
        onChange={e => setName(e.target.value)}
        value={name}
      />
      <button
        onClick={() => {
          setName("")
          const { data } = addGroup({
            variables: {
              name: name
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