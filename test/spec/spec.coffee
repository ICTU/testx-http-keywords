runner = require '@ictu/testx'
dummyHttpServer = require '../dummyHttpServer.js'

describe 'HTTP keywords', ->
  it 'should send get, post, delete, patch and head requests', ->
    runner.run 'test/scripts/test.testx'
