fake api server
===============

a simple, easy mock REST API server

  * quick start
  * introduction
  * dependencies
  * api reference
  * contributing

[![Build Status](https://travis-ci.org/couchand/oracular.svg?branch=master)](https://travis-ci.org/couchand/oracular)

quick start
-----------

```javascript
// server.js
var fake = require('fake-api-server');

var books = new fake.Resource("book")
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
npm http GET https://registry.npmjs.org/fake-api-server/0.4.0
npm http 200 https://registry.npmjs.org/fake-api-server/0.4.0
...
fake-api-server@0.4.0 node_modules/fake-api-server

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
see `example` and `test/integration` for more examples

introduction
------------

you hold in your hands an extremely simple fake API server built in
Node.js and aptly named `fake-api-server`.  this little project came
about after I wrote [a comment][0] on [this HN thread][1] responding
to [an article][2] by Jeremy Morgan about implementing the same thing
on a "self-hosted" .NET server.

since the crux of that article was that you want the fake API to get
out of the way so you can focus on front-end development, it seemed
prudent to rewrite the code in JavaScript to avoid context-switching
between languages.

dependencies
------------

  * node
  * express
  * body-parser

api reference
-------------

the API is made up of two types: `Resource` and `Server`.  you create
a number of resources which you then register with a server.  the
server listens for requests to `/api` routes and handles the various
registered resources RESTfully.

any method that doesn't otherwise return a value returns the object
itself to allow for method chaining.

### Resource ###

new **Resource**(*name*)

  * creates a new resource with the given name, which should be in
    singular form.  the name will be pluralized for the api (see the
    documentation for `pluralName`).

**idAttribute**([*newVal*])

  * gets or sets the id attribute name, which defaults to `id`.

**idFactory**`([newVal])`

  * gets or sets the new record id factory.  this should be a method
    that returns a novel unique id each time it's called.

**name**([*newVal*])

  * gets or sets the name of the resource.

**pluralName**([*newVal*])

  * gets or sets the plural name of the resource, which defaults to
    the name plus "s".

**all**()

  * get all records for this resource.

**add**(*record*)

  * add a record to the resource data store.  the id attribute will
    be automatically set.  the record is not copied, so if you need
    the new id you can get it from the object reference passed in.

**find**(*id*)

  * finds a record by id.
  * this method, `update` and `remove` return `false` if the id is
    not found for this resource.

**update**(*id, updates*)

  * update a record by id, returning the updated record.

**remove**(*id*)

  * remove a record by id, returning a boolean indicating success.

### Server ###

new **Server**()

  * creates a new server.

**listen**([*port*=3000])

  * starts listening for REST requests on the given port.

**register**(*resource*)

  * register a given resource for the API.  the appropriate REST
    verbs will be routed.

**use**(*middleware*)

  * add a middleware to the underlying express server.  for example,
    to serve static content, try  `server.use(express.static(dirname))`.

**static**(*path*)

  * a convenience method for adding the express builtin static middleware,
    as in the above example.  useful if you would not have otherwise
    needed to load express yourself.  serve static html, javascript,
    images and other content along with the fake api.

contributing
------------

Contributions are most welcome!  Please maintain the style of the
existing code and docs, which includes:

  * add tests and documentation for new features
  * limit line length to 70 characters
  * run Grunt to build and test
  * commit the CoffeeScript compilation seperately

Many thanks to the following folks for their contributions!

  * @mindeavor
  * @tornad
  * @temnoregg
  * @evrenkutar
  * @IgorGanapolsky
  * @krcourville

[0]: https://news.ycombinator.com/item?id=7743948
[1]: https://news.ycombinator.com/item?id=7742993
[2]: http://www.jeremymorgan.com/blog/programming/how-to-create-asp-self-hosted-api/

##### ╭╮☲☲☲╭╮ #####
