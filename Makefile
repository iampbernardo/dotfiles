.PHONY: check install pi

check:
	@bash -n install.sh macos-defaults.sh
	@! git ls-files | grep -E '(^|/)(auth\.json|.*\.pem|.*\.key|sessions|node_modules)($|/)' >/dev/null || (echo "Refusing tracked credentials or runtime state" >&2; exit 1)
	@echo "Dotfiles checks passed."

pi:
	@git submodule update --init --recursive
	@$(MAKE) -C my-pi link

install:
	@./install.sh
