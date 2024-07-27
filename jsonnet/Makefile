.PHONY: lib/meta/raw/environments.json
lib/meta/raw/environments.json:
	tk env list --json environments/ | jsonnet - > lib/meta/raw/environments.json
