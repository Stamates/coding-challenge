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
  if (groups && groups.length === 0) return <div>No Groups Exist</div>

  return (
    <React.Fragment >
      <GroupList groups={groups} setGroup={setGroup} setGroups={setGroups} />
      <AddGroup setGroups={setGroups} />
    </React.Fragment>
  )
}

function GroupList({ groups, setGroup }) {
  if (groups) {
    return (
      groups.map((group) => (
        <div key={group.id}>
          <Group group={group} setGroup={setGroup} key={group.id} />
        </div>
      ))
    )
  }
  return ''
}