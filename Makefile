
default: compile

.PHONY: \
	compile \
	run erl \
	clean cleaner \
	tests eunit cucumber \
	deps .deps-force \
	bundle .bundle-force

# compile

compile: rebar .deps-flag
	./rebar compile
	rsync --recursive --delete deps/nitrogen_core/www/ static/nitrogen/

# runtime

run: compile
	test -f notes.config || cp notes.config.template notes.config
	erl \
		-pa ebin deps/*/ebin deps/*/include \
		-name notes@127.0.0.1 \
		-config notes.config \
		-eval "notes_start:run ()."

erl: compile
	erl \
		-pa ebin deps/*/ebin deps/*/include \
		-name notes@127.0.0.1

# clean

clean: rebar
	./rebar clean

cleaner: clean
	rm -rf .bundle bundle deps rebar

# tests

tests: eunit cucumber

eunit: compile
	./rebar eunit skip_deps=true

cucumber: .bundle-flag
	bundle exec cucumber --tags ~@wip

cucumber-wip: .bundle-flag
	bundle exec cucumber --tags @wip

cucumber-dry: .bundle-flag
	bundle exec cucumber --tags ~@wip --dry-run

cucumber-wip-dry: .bundle-flag
	bundle exec cucumber --tags @wip --dry-run

# rebar

rebar:
	wget https://github.com/downloads/basho/rebar/rebar
	chmod +x rebar

# dependencies

deps: .deps-force .deps-flag

.deps-force:
	rm .deps-flag

.deps-flag: rebar rebar.config
	./rebar get-deps
	test -f deps/less || \
		git clone https://github.com/cloudhead/less.js.git deps/less
	touch .deps-flag

# bundle

bundle: .bundle-force .bundle-flag

.bundle-force:
	rm .bundle-flag

.bundle-flag: Gemfile Gemfile.lock
	which bundle >/dev/null || { \
		echo "Please install ruby and bundler" \
		exit 1; }
	bundle install --path bundle
	touch .bundle-flag
