import React from 'react'
import { useMutation } from '@apollo/client'
import { DELETE_GROUP, GET_ALL_GROUPS } from '../queries'

function taskCompletion(group) {
  let completed = group.tasks.reduce(function (task, acc) {
    return task.completedAt ? acc + 1 : acc
  }, 0)
  return completed + ' of ' + group.tasks.length
}

export default function Group({ group, setGroup }) {
  const [deleteGroup] = useMutation(DELETE_GROUP,
    { refetchQueries: [{ query: GET_ALL_GROUPS }] }
  )


  return (
    <div className='App-list-item'>
      <span className='App-group-link' onClick={() => { setGroup(group) }}>
        <strong>{group.name}</strong>
        <br />
        <span className='App-completion-status'>{taskCompletion(group) + ' complete'}</span>
      </span>
      <span className='App-header-link' onClick={() => {
        deleteGroup({ variables: { id: group.id } })
      }}
      >
        Delete
      </span>
    </div >
  )
}
