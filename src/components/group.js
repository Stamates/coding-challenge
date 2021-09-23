import React from 'react'

function taskCompletion(group) {
  let completed = group.tasks.reduce(function (task, acc) {
    return task.completedAt ? acc + 1 : acc
  }, 0)
  return completed + ' of ' + group.tasks.length
}

const Group = ({ group }) => {
  return (
    <div className='App-list-item' >
      <strong>{group.name}</strong>
      <br />
      <span className='App-completion-status'>{taskCompletion(group) + ' complete'}</span>
    </div >
  )
}

export default Group