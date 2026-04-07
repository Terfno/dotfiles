.PHONY: up format jsonnetfmt prettier stylua

up:
	@if command -v brew >/dev/null 2>&1; then \
		echo "homebrew is ready"; \
	else \
		echo "installing homebrew"; \
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)";
	fi

	brew install jsonnet

	@if command -v volta >/dev/null 2>&1; then \
		echo "volta is ready"; \
	else \
		echo "installing volta"; \
		curl https://get.volta.sh | bash; \
	fi
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
