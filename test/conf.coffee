exports.config =
  directConnect: true
  specs: ['spec/*']

  capabilities:
    browserName: 'chrome'
    shardTestFiles: false
    maxInstances: 5
    chromeOptions:
      args: ["--no-sandbox", "--headless", "--disable-gpu", "--window-size=1024,800"]


  framework: 'jasmine'
  jasmineNodeOpts:
    silent: true
    defaultTimeoutInterval: 300000
    includeStackTrace: false

  baseUrl: 'http://elasticsearch.ivs-graylog.rws.ictu:9200/'
  rootElement: 'html'

  onPrepare: ->
    require '@ictu/testx'
    testx.keywords.add require('../')
    beforeEach -> browser.ignoreSynchronization = true
