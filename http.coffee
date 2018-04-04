request = require 'request'
parseHeaders = require 'parse-key-value'

isFullUrl = (str) ->
  str.match /^https?:\/\//i

send = (method) -> (options) ->
  options.method = method
  options.url = if isFullUrl(options.url)
    options.url
  else if browser?.baseUrl
    browser.baseUrl + options.url
  else options.url

  options.headers = parseHeaders options.headers if options.headers
  options.json = JSON.parse options.json if options.json

  new Promise (resolve, reject) ->
    request options, (error, response, body) ->
      if error
        reject error
      else
        resolve
          statusCode: response.statusCode
          body: body
          headers: response.headers

module.exports =
  get: send "GET"
  post: send "POST"
  put: send "PUT"
  delete: send "DELETE"
  patch: send "PATCH"
  head: send "HEAD"
