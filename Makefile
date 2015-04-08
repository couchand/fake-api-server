all: compile tests

compile: node_modules
	node_modules/coffee-script/bin/coffee -c -o lib src/*.coffee

tests: node_modules
	node_modules/mocha/bin/mocha

node_modules:
	npm i
