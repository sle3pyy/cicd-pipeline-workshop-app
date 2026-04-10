import { describe, expect, it } from 'vitest'

import App from './App'

describe('App', () => {
  it('exports the frontend root component', () => {
    expect(App).toBeTypeOf('function')
  })
})
