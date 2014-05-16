fake api server
===============

a simple, easy mock REST API server

  * quick start
  * introduction
  * dependencies
  * api reference
  * more information

quick start
-----------

```javascript
// server.js
var fake = require('fake-api-server');

var books = new fake.Resource("Book")
  .add({
    name: "Lords of Finance",
    author: "Liaquat Ahamed",
    year: 2009 })
  .add({
    name: "Public Enemies",
    author: "Bryan Burrough",
    year: 2004
  });

var server = new fake.Server()
  .register(books)
  .listen(3000);
```

```bash
> npm install fake-api-server
npm http GET https://registry.npmjs.org/fake-api-server/0.1.0
npm http 200 https://registry.npmjs.org/fake-api-server/0.1.0
...
fake-api-server@0.1.0 node_modules/fake-api-server

> node server.js &
[1] 1337
server listening on localhost:3000

> curl localhost:3000/api/books
[{"id":1,"name":"Lords of Finance","author":"Liaquat Ahamed
","year":2009},{"id":2,"name":"Public Enemies","author":"Br
yan Burrough","year":2004}]

> curl localhost:3000/api/books -X POST \
  -d {"name":"Low Life","author":"Luc Sante","year":1992} \
  -H "Content-Type: application/json"
OK

> curl localhost:3000/api/books/3
{"id":3,"name":"Low Life","author":"Luc Sante","year":1992}

> curl localhost:3000/api/books/3 -X PUT -d {"year":1991} \
  -H "Content-Type: application/json"
OK

> curl localhost:3000/api/books/3
{"id":3,"name":"Low Life","author":"Luc Sante","year":1991}

> curl localhost:3000/api/books/3 -X DELETE
OK

> curl localhost:3000/api/books/1 -X DELETE
OK

> curl localhost:3000/api/books
[{"id":2,"name":"Public Enemies","author":"Bryan Burrough",
"year":2004}]
```

introduction
------------

***loading***

dependencies
------------

  * node
  * express

api reference
-------------

***please wait***

more information
----------------

***nothing yet***
