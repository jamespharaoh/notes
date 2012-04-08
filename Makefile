# Filename: Makefile
#
# Copyright 2012 James Pharaoh <james@phsys.co.uk>
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License

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
	test -f etc/notes.config || cp etc/notes.config.template etc/notes.config
	erl \
		-pa ebin deps/*/ebin deps/*/include \
		-name notes@127.0.0.1 \
		-config etc/notes.config \
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
	test -d deps/less || \
		git clone git://github.com/cloudhead/less.js.git deps/less
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
