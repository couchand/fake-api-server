# example books server

Resource = require '../src/resource'
Server   = require '../src/server'

books = new Resource "book"
  .add id: 1, title: "Microsoft Visual C# 2012", author: "John Sharp"
  .add id: 2, title: "C# 5.0 in a nutshell", author: "Joseph Albahari"
  .add id: 3, title: "C# in Depth, 3rd Edition", author: "Jon Skeet"
  .add id: 4, title: "Pro ASP.NET MVC 5", author: "Adam Freeman"

server = new Server()
  .register books
  .listen 3000
