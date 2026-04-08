import { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [members, setMembers] = useState([])
  const [events, setEvents] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchData()
  }, [])

  const fetchData = async () => {
    setLoading(true)
    setError(null)
    try {
      const [membersRes, eventsRes] = await Promise.all([
        fetch('/api/members'),
        fetch('/api/get-togethers'),
      ])
      setMembers(await membersRes.json())
      setEvents(await eventsRes.json())
    } catch (err) {
      setError('Could not connect to the backend. Make sure it is running on port 8000.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="app">
      <header className="header">
        <div className="header-inner">
          <div className="logo">
            <span className="logo-icon">🚀</span>
            <span className="logo-text">DevOps Porto</span>
          </div>
          <h1 className="header-title">Get-Together</h1>
          <p className="header-subtitle">Community events for the DevOps Porto community</p>
        </div>
      </header>

      <main className="main">
        {loading && (
          <div className="status-card">
            <p className="status-text">Loading...</p>
          </div>
        )}

        {error && (
          <div className="status-card error-card">
            <p className="status-text">⚠️ {error}</p>
          </div>
        )}

        {!loading && !error && (
          <div className="grid">
            <section className="card">
              <div className="card-header">
                <h2 className="card-title">Members</h2>
                <span className="badge">{members.data?.length ?? 0}</span>
              </div>
              <p className="card-description">Community members registered in the platform.</p>
            </section>

            <section className="card">
              <div className="card-header">
                <h2 className="card-title">Get-Togethers</h2>
                <span className="badge">{events.data?.length ?? 0}</span>
              </div>
              <p className="card-description">Upcoming and past community get-together events.</p>
            </section>
          </div>
        )}
      </main>

      <footer className="footer">
        <p>DevOps Porto Get-Together · v0.0.1</p>
      </footer>
    </div>
  )
}

export default App
