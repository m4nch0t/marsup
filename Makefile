VERSIONS_FILE := netlify.toml
DEVCONTAINER_FILE := .devcontainer/devcontainer.json
HUGO_YAML_FILE := .github/workflows/hugo.yaml
GO_MOD_FILE := go.mod

.PHONY: update_versions

update: update_versions update_theme
update_versions: update_devcontainer update_hugo_yaml update_go_mod

update_devcontainer:
	@echo "Updating devcontainer.json..."
	@HUGO_VERSION=$$(grep 'HUGO_VERSION' $(VERSIONS_FILE) | cut -d '=' -f 2 | tr -d '"') && \
	jq --arg version "$$HUGO_VERSION" '.features["ghcr.io/devcontainers/features/hugo:1"].version = $$version' $(DEVCONTAINER_FILE) > tmp.$$.json && mv tmp.$$.json $(DEVCONTAINER_FILE)
	@echo "Updated Hugo version in $(DEVCONTAINER_FILE)"

update_hugo_yaml:
	@echo "Updating hugo.yaml..."
	@HUGO_VERSION=$$(grep 'HUGO_VERSION' $(VERSIONS_FILE) | cut -d '=' -f 2 | tr -d '"') && \
	GO_VERSION=$$(grep '^GO_VERSION' $(VERSIONS_FILE) | cut -d '=' -f 2 | tr -d '"') && \
	export HUGO_VERSION GO_VERSION && \
	envsubst < $(HUGO_YAML_FILE) | yq -i '.jobs.build.env.GO_VERSION = env(GO_VERSION) | .jobs.build.env.HUGO_VERSION = env(HUGO_VERSION)' $(HUGO_YAML_FILE)
	@echo "Updated Hugo and Go versions in $(HUGO_YAML_FILE)"

update_go_mod:
	@echo "Updating go.mod..."
	@GO_VERSION=$$(grep '^GO_VERSION' $(VERSIONS_FILE) | cut -d '=' -f 2 | tr -d '"') && \
	echo "Extracted GO_VERSION: $$GO_VERSION" && \
	awk -v go_version="$$GO_VERSION" '{if ($$1 == "go") $$2 = go_version}1' $(GO_MOD_FILE) > tmp.$$.mod && mv tmp.$$.mod $(GO_MOD_FILE)
	@echo "Updated Go version in $(GO_MOD_FILE)"

update_theme:
	@echo "Updating theme..."
	npm update
	@echo "Updated theme"

test_ghactions:
	@echo "Testing..."
	./bin/act --secret SFTP_SERVER --secret SFTP_USERNAME --secret SFTP_PASSWORD

dev_build:
	@echo "Building site locally..."
	hugo server --buildDrafts --buildFuture --buildExpired --disableFastRender --ignoreCache --noHTTPCache

prod_build:
	@echo "Building site for production..."
	hugo server --disableFastRender --ignoreCache --noHTTPCache
