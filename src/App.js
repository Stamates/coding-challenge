import React, { useState } from 'react'
import Groups from './components/groups'
import './App.css';

export default function App() {
  const [group, setGroup] = useState(null)
  const component = group ? <GroupMenu group={group} setGroup={setGroup} /> : <MainMenu setGroup={setGroup} />

  return (
    <div className='App-container'>
      {component}
    </div>
  )
}

function MainMenu({ setGroup }) {
  return (
    <React.Fragment>
      <div className='App-header'>
        <p className='App-header App-header-text'>Things To Do</p>
      </div>
      <Groups setGroup={setGroup} />
    </React.Fragment>
  )
}

const GroupMenu = ({ group, setGroup }) => {
  return (
    <React.Fragment>
      <div className='App-header'>
        <p className='App-header App-header-text'>{group.name}</p>
        <span className='App-header-link' onClick={() => { setGroup(null) }}>ALL GROUPS</span>
      </div>
      Tasks
    </React.Fragment>
  )
}
