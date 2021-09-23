import React from 'react'

function taskCompletion(group) {
  let completed = group.tasks.reduce(function (task, acc) {
    return task.completedAt ? acc + 1 : acc
  }, 0)
  return completed + ' of ' + group.tasks.length
}

const Group = ({ group, setGroup }) => {
  return (
    <div className='App-list-item'>
      <span className='App-group-link' onClick={() => { setGroup(group) }}>
        <strong>{group.name}</strong>
        <br />
        <span className='App-completion-status'>{taskCompletion(group) + ' complete'}</span>
      </span>
    </div >
  )
}

export default Group