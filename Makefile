all: compile test

compile: node_modules
	node_modules/coffee-script/bin/coffee -c -o lib src/*.coffee

test: node_modules
	node_modules/mocha/bin/mocha

node_modules:
	npm i
