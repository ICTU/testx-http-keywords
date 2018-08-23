[![Build Status](https://travis-ci.org/ICTU/testx-http-keywords.svg?branch=master)](https://travis-ci.org/ICTU/testx-http-keywords)

testx-http-keywords
=====

A library that extends testx with keywords for sending basic http requests. @ictu/testx is a fork maintained and used by ICTU (www.ictu.nl). This library is packaged as a npm package

## How does it work
From the directory of the art code install the package as follows:
```sh
npm install @ictu/testx-http-keywords --save
```

After installing the package add the keywords to your protractor config file as follows:

```
testx.keywords.add(require('@ictu/testx-http-keywords'))
```

## Keywords

| Keyword                   | Argument name | Argument value  | Description | Supports repeating arguments |
| ----------------------    | ------------- | --------------- |------------ | ---------------------------- |
| send http [optional request method] request         |               |                 | send a http POST request and check if the response status code is 200 |  |
|                           | url           | relative url to which the request will be sent || No |
|                           | method        | request method  | Optional. Valid values are **get**, **post**, **put**, **delete**, **patch** and **head**. Defaults to **get**. It is also possible to put the method in the keyword, as in **send http post request** or **send http delete request** instead of providing this argument. | No |
|                           | json          | a valid JSON string that contains the body of the request, will make the Content-Type of the request 'application/json' | Optional. Cannot use it together with **body**. | No |
|                           | body          | a string that contains the body of the request | Optional. Cannot use it together with **json**. | No |
|                           | headers       | custom headers | Optional. Semicolon or new line-separated string of '='-separated key-value pairs. For example "User-Agent=testx;Something-Else='value with spaces'"| No |
|                           | expected status code   | expected status code of the response | Optional. The test will fail if the actual status code is different; defaults to 200| No |
|                           | expected response  | expected content of the response | Optional. The test will fail if the actual content (body) of the response is not equal. | No |
|                           | expected response regex | a regex to match against the response | Optional. The keyword will try to match the provided regular expression against the content (body) of the response and will fail if there is no match; currently it is not possible to provide regex matching options. | No |
|                           | expected headers | list of expected response headers | Optional. Same format as the *headers* parameter. The keyword will fail if not all of the expected response headers exist or if they have values different than the expected/specified onesble to provide regex matching options. | No |
|                           | *json path/xpath* | *expected value at this json path or xpath* | Optional. Depending on the **Content-Type** header this argument will be treated as JSON path or an XPath. The argument name should be the actual path, i.e. "$.address.city" or "//address/city". | Yes |
|                           | expected missing json paths | list of expected missing json paths | Optional. The keyword will fail if one of the expected response headers exist | No |
|                           | expected present json paths | list of expected present json paths | Optional. The keyword will fail if one of the expected response headers does not exist | No |
