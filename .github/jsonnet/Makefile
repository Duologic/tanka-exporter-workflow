DEFAULT: gen
.PHONY: gen
gen:
	jrsonnet -J vendor -J lib -S -c -m .. main.libsonnet

.PHONY: update_latest_actions
update_latest_actions:
	./lib/pin-github-actions/getActions.sh .. | ./lib/pin-github-actions/getVersions.sh /dev/stdin > lib/common/latest_actions_from_actions.json

.PHONY: get_actions
get_actions:
	./lib/pin-github-actions/getActions.sh .. | jsonnetfmt - > lib/common/used_actions.libsonnet
