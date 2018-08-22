http = require './http'
JSONPath = require 'jsonpath-plus'
xpath = require('xpath')
dom = require('xmldom').DOMParser
_ = require 'lodash'
parseHeaders = require 'parse-key-value'

namedParams = [
  'url'
  'method'
  'json'
  'body'
  'headers'
  'expected status code'
  'expected response'
  'expected response regex'
  'expected headers'
  'expected missing json paths'
  'expected present json paths'
]

String::startsWith ?= (s) -> @slice(0, s.length) == s

isContentType = (contentTypeHeader, contentType) ->
  if contentType is 'xml'
    contentTypeHeader.startsWith('application/xml') or contentTypeHeader.startsWith('text/xml')
  else if contentType is 'json'
    contentTypeHeader.startsWith 'application/json'
  else
    contentTypeHeader.startsWith contentType

printable = (obj, delimiter = ', ') ->
    ("#{k}: #{v}" for k, v of obj).join delimiter

assertFailedMsg = (msg, ctx) ->
  "#{msg} at #{printable _.pick(ctx._meta, 'file', 'sheet', 'Row')}"

send = (method) -> (args, ctx) ->
  withParsedBody = (body, cb) ->
    try
      parsedBody = if typeof body is 'object' then body else JSON.parse body
      cb parsedBody
    catch ex
      if ex instanceof SyntaxError
        throw new Error """
            It seems, that you are trying to use JSONPath on a non-json response at #{printable _.pick(ctx._meta, 'file', 'sheet', 'Row')}.
            The response I received was:

            #{body}
          """
      else
        throw ex

  protractor.promise.controlFlow().execute -> #this is needed to execute multiple expects
    (http[method] _.pick args, 'url', 'body', 'json', 'headers').then (response) ->
      pathParams = _.omit args, namedParams
      expectedResponseStatus = parseInt(args['expected status code'])
      if(method is 'delete')
        failMsg = assertFailedMsg "Expected response status code to be 200, 202 or 204, but it was '#{response.statusCode}'", ctx
        expect(response.statusCode in [expectedResponseStatus, 200, 202, 204]).toBeTruthy failMsg
      else
        expected = expectedResponseStatus or 200
        failMsg = assertFailedMsg "Expected response status code to be #{expected}, but it was #{response.statusCode}", ctx
        expect(response.statusCode).toBe expected, failMsg
      if args['expected response']
        expected = if args['expected response']?.trim
          args['expected response'].trim().replace /\r/g, ''
        else args['expected response']
        body = if typeof response.body is 'object' then JSON.stringify(response.body) else response.body
        actual = if body?.trim
          body.trim().replace /\r/g, ''
        else body
        failMsg = assertFailedMsg "Expected response body to equal '#{expected}', but it was '#{actual}'", ctx
        expect(actual).toBe expected, failMsg
      if args['expected response regex']
        expected = args['expected response regex']
        actual = if typeof response.body is 'object' then JSON.stringify(response.body) else response.body
        failMsg = assertFailedMsg "Expected response body to match '#{expected}', but it was '#{actual}'", ctx
        expect(actual).toMatch expected, failMsg
      if args['expected headers']
        expectedHeaders = parseHeaders args['expected headers']
        for expHeaderName, expHeaderValue of expectedHeaders
          failMsg = assertFailedMsg "Expected response header '#{expHeaderName}' to match '#{expHeaderValue}', but it was '#{response.headers[expHeaderName]}'", ctx
          expect(response.headers[expHeaderName]).toMatch expHeaderValue, failMsg
      if missingPaths = args['expected missing json paths']
        withParsedBody response.body, (parsedBody) ->
          for path in missingPaths
            actual = JSONPath
              path: path
              json: parsedBody
              wrap: false
            failMsg = assertFailedMsg "Expected that JSON path '#{path}' does not exist in '#{JSON.stringify parsedBody}'", ctx
            expect(actual).toBeUndefined failMsg
       if presentPaths = args['expected present json paths']
        withParsedBody response.body, (parsedBody) ->
          for path in presentPaths
            actual = JSONPath
              path: path
              json: parsedBody
              wrap: false
            failMsg = assertFailedMsg "Expected that JSON path '#{path}' does exist in '#{JSON.stringify parsedBody}'", ctx
            expect(actual).toBeDefined failMsg
      if Object.keys(pathParams)?.length
        switch
          when isContentType response.headers['content-type'], 'json'
            withParsedBody response.body, (parsedBody) ->
              for path, expected of pathParams
                actual = JSONPath
                  path: path
                  json: parsedBody
                failMsg = assertFailedMsg "Expected the value at JSON path '#{path}' to contain '#{expected}', but it was '#{actual}'", ctx
                expect(actual).toContain expected, failMsg
          when isContentType response.headers['content-type'], 'xml'
            for path, expected of pathParams
              doc = new dom().parseFromString(response.body)
              actual = xpath.select(path, doc)
              failMsg = assertFailedMsg "Expected the value at xpath '#{path}' to equal '#{expected}', but it was '#{actual}'", ctx
              expect(actual?.toString()).toBe expected, failMsg
          else
            throw new Error """
                Error occurred in #{printable _.pick(ctx._meta, 'file', 'sheet', 'Row')}.

                It seems, that you are trying to use JSONPath or XPath on a response
                with a Content-Type header '#{response.headers['content-type']}'.
                I only know how to deal with 'application/json', 'application/xml' or 'text/xml'

                The response I received was:

                #{response.body}
              """

module.exports =
  'send http request': (args, ctx) ->
    method = args.method?.toLowerCase() or 'get'
    (send method) args, ctx
  'send http get request': send 'get'
  'send http post request': send 'post'
  'send http delete request': send 'delete'
  'send http put request': send 'put'
  'send http patch request': send 'patch'
  'send http head request': send 'head'
