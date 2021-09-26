import React, { useState, useEffect } from 'react'
import { useQuery } from '@apollo/client'
import { GET_ALL_GROUPS } from '../queries'
import Group from './group'
import AddGroup from './addgroup'

export default function Groups({ setGroup }) {
  const { loading, error, data } = useQuery(GET_ALL_GROUPS)
  const [groups, setGroups] = useState()

  useEffect(() => {
    if (!loading && data) {
      setGroups(data.groups);
    }
  }, [loading, data])

  if (loading) return <p>Loading...</p>
  if (error) return <p>Sheeeit something's broke</p>

  return (
    <React.Fragment >
      {
        (groups && groups.length === 0) ?
          <div className='App-list-item'>No Groups Exist</div> :
          <GroupList groups={groups} setGroup={setGroup} setGroups={setGroups} />
      }
      <AddGroup setGroups={setGroups} />
    </React.Fragment>
  )
}

function GroupList({ groups, setGroup }) {
  if (groups) {
    const sortedGroups = [...groups]
    sortedGroups
      .sort((group1, group2) => { return group1.name < group2.name ? -1 : 1 })
    return (
      sortedGroups.map((group) => (
        <div key={group.id}>
          <Group group={group} setGroup={setGroup} key={group.id} />
        </div>
      ))
    )
  }
  return ''
}