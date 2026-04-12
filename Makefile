bootstrap:
	bin/update
	bin/bootstrap-brew
	bin/bootstrap-mitamae

dry-install:
	bin/mitamae local ./recipes/default.rb --dry-run

install:
	bin/mitamae local ./recipes/default.rb

up:
	bin/bootstrap-brew
	brew install jsonnet

	bin/bootstrap-volta
	volta install node

	npm i
	npx lefthook install

format:
	$(MAKE) prettier
	$(MAKE) stylua
	$(MAKE) jsonnetfmt

jsonnetfmt:
	@files="$$(git ls-files '*.jsonnet' '*.libsonnet')"; \
	if [ -z "$$files" ]; then \
		echo "no jsonnet files"; \
	else \
		jsonnetfmt -i $$files; \
	fi

prettier:
	npm run prettier

stylua:
	npm run stylua
