import React, { useState, useEffect } from 'react'
import { useQuery } from '@apollo/client'
import { GET_GROUP_TASKS } from '../queries'
import Task from './task'
import AddTask from './addTask'

export default function Tasks({ group }) {
  const { loading, error, data } = useQuery(GET_GROUP_TASKS, { variables: { group_id: group.id } })
  const [tasks, setTasks] = useState()

  useEffect(() => {
    if (!loading && data) {
      setTasks(data.groupTasks);
    }
  }, [loading, data])

  if (loading) return <p>Loading...</p>
  if (error) return <p>Sheeeit something's broke</p>

  return (
    <React.Fragment>
      {
        (tasks && tasks.length === 0) ?
          <div className='App-list-item'>No Tasks Exist</div> :
          <TaskList tasks={tasks} setTasks={setTasks} />
      }
      <AddTask group={group} setTasks={setTasks} />
    </React.Fragment>
  )
}


function TaskList({ tasks }) {
  if (tasks) {
    return (
      tasks.map((task) => (
        <div key={task.id}>
          <Task task={task} />
        </div>
      ))
    )
  }
  return ''
}