import React from 'react'
import Groups from './components/groups'
import './App.css';

export default function App() {
  return (
    <div className='App-container'>
      <div className='App-header'>
        <p className='App-header App-header-text'>Things To Do</p>
      </div>
      <Groups />
    </div>
  )
}
