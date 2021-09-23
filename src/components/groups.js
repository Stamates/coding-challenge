import React from 'react'
import { useQuery } from '@apollo/client'
import { GET_ALL_GROUPS } from '../queries'
import Group from './group'

export default function Groups({ setGroup }) {
  const { loading, error, data } = useQuery(GET_ALL_GROUPS)
  if (loading) return <p>Loading...</p>
  if (error) return <p>Sheeeit something's broke</p>
  if (data.groups.length === 0) return <div>No Groups Exist</div>

  return (
    data.groups.map((group) => (
      <div key={group.id}>
        <Group group={group} setGroup={setGroup} />
      </div>
    ))
  )
}
