.PHONY: lib/meta/raw/environments.json
lib/meta/raw/environments.json:
	tk env list --json environments/ | jrsonnet - > lib/meta/raw/environments.json
