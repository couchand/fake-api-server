# an e-store

fake = require '../lib'

books = new fake.Resource "book"
  .add
    name: "Lords of Finance"
    author: "Liaquat Ahamed"
    year: 2009
  .add
    name: "Public Enemies"
    author: "Bryan Burrough"
    year: 2004
  .add
    name: "Low Life"
    author: "Luc Sante"
    year: 1991

music = new fake.Resource "music"
  .pluralName "music"
  .add
    name: "One Life Stand"
    artist: "Hot Chip"
    year: 2010
  .add
    name: "The Only Thing I Ever Wanted"
    artist: "Psapp"
    year: 2006
  .add
    name: "Head Hunters"
    artist: "Herbie Hancock"
    year: 1973

server = new fake.Server()
  .register books
  .register music
  .listen()

console.log "server listening on localhost:3000"
