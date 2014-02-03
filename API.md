Fomalhaut v1 API
====
# Overview
- JSON REST API

# Sample
```json
curl -v http://localhost/api/v1/bookmarks
< HTTP/1.1 200 OK
< Date: Thu, 30 Jan 2014 02:10:20 GMT
< Accept-Ranges: bytes
< Content-Type: application/json; charset=utf-8
< Content-Length: 343
* Server Fomalhaut/1.0 is not blacklisted
< Server: Fomalhaut/1.0
< Connection: keep-alive

[{"created":"2014-01-26T10:24:34+0900","name":"Hoge","type":"normal","uuid":"D39585E1-CC9C-405D-B24A-200FABCBB368"},{"created":"2014-01-
30T00:18:59+0900","name":"Smart","type":"smart","uuid":"E19CCE1A-1D6B-45F8-B5FF-DD44F61E8B7C"},{"created":"2014-01-26T23:30:39+0900","nam
e":"asdf","type":"smart","uuid":"DCE75C9B-E39D-48DD-AD0D-DF981AF06359"}]
```

## Errors
### 400 Bad Request

### 404 Not Found

# Bookmarks
## List bookmarks
List all bookmarks:

```
GET /bookmarks
```

### Response
```json
[
  {
    "uuid": "B69E4E25-9802-4B66-BE81-A3BE77BD8CA5",
    "name": "Comics",
    "type": "normal",
    "created": "2014-01-30T20:09:31Z"
  },
  {
    "uuid": "12636DBF-C95E-4E4D-976B-EA8FFAE77DAA",
    "name": "Recently Added",
    "type": "smart",
    "created": "2014-01-30T20:09:31Z"
  }
]
```

## Get a single bookmark
```
GET /bookmarks/:uuid
```

### Parameters
Name | Type | Description
--- | --- | ---
sort | string | Select name, read_count, last_opened and created. Default: name
direction | string | Select asc or desc. Default: asc

### Response
```json
{
  "uuid": "B69E4E25-9802-4B66-BE81-A3BE77BD8CA5",
  "name": "Comics",
  "books": [
    {
      "uuid": "D8A6C905-A483-4A59-95BF-1C3A119ED07F",
      "name": "Book.zip",
      "readCount": 3,
      "isLost": false,
      "memo": "hogehoge",
      "lastOpened": "2014-01-30T20:09:31Z",
      "created": "2014-01-30T20:09:31Z"
    }
  ]
}
```

# Book
## Get all books
```
GET /books/all
```

### Parameters
Name | Type | Description
--- | --- | ---
sort | string | Select name, read_count, last_opened and created. Default: name
direction | string | Select asc or desc. Default: asc

### Response
```json
[
  {
    "uuid": "D8A6C905-A483-4A59-95BF-1C3A119ED07F",
    "name": "Book.zip",
    "readCount": 3,
    "isLost": false,
    "memo": "hogehoge",
    "lastOpened": "2014-01-30T20:09:31Z",
    "created": "2014-01-30T20:09:31Z"
  }
]
```

## Get a single book
Open and get the number of the book:

```
GET /books/:uuid
```

### Response
```json
{
  "uuid": "D8A6C905-A483-4A59-95BF-1C3A119ED07F",
  "name": "Book.zip",
  "readCount": 3,
  "pageCount": 10,
  "isLost": false,
  "memo": "hogehoge",
  "lastOpened": "2014-01-30T20:09:31Z",
  "created": "2014-01-30T20:09:31Z"
}
```

## Get the thumbnail image of a book
```
GET /books/:uuid/thumbnail
```

### Response
```
(data)
```

## Get the page image of a book
```
GET /books/:uuid/image/:index
```

### Parameters
Name | Type | Description
--- | --- | ---
width | number | The number of pixel in horizontal. Default: original width
height | number | The number of pixel in vertical. Default: original height

### Response
```
(data)
```