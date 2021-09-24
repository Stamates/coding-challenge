import React, { useState } from 'react'
import Groups from './components/groups'
import Tasks from './components/tasks'
import './App.css';

export default function App() {
  const [group, setGroup] = useState(null)
  const component = group ? <TaskList group={group} setGroup={setGroup} /> : <GroupList setGroup={setGroup} />

  return (
    <div className='App-container'>
      {component}
    </div>
  )
}

const GroupList = ({ setGroup }) => {
  return (
    <React.Fragment>
      <div className='App-header'>
        <p className='App-header App-header-text'>Things To Do</p>
      </div>
      <Groups setGroup={setGroup} />
    </React.Fragment>
  )
}

const TaskList = ({ group, setGroup }) => {
  return (
    <React.Fragment>
      <div className='App-header'>
        <p className='App-header App-header-text'>{group.name}</p>
        <span className='App-header-link' onClick={() => { setGroup(null) }}>ALL GROUPS</span>
      </div>
      <Tasks group={group} />
    </React.Fragment>
  )
}
