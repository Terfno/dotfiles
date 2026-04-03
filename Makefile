up:
	@if command -v volta >/dev/null 2>&1; then \
		echo "volta is already installed"; \
	else \
		echo "installing volta"; \
		curl https://get.volta.sh | bash; \
	fi

	volta install node
	npm i
	npx lefthook install

format:
	make prettier
	make stylua

prettier:
	npm run prettier

stylua:
	npm run stylua
