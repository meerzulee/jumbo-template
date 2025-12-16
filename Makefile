.PHONY: build dev deploy clean

build:
	rm -rf dist
	mkdir -p dist
	cp -r public/* dist/
	cp src/template.rb dist/t
	cp -r src/template dist/

dev: build
	bunx wrangler dev

deploy: build
	bunx wrangler deploy

clean:
	rm -rf dist
