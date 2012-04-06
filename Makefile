
default: compile

get-deps: rebar
	./rebar get-deps

compile: rebar get-deps
	./rebar compile
	rsync --recursive --delete deps/nitrogen_core/www/ static/nitrogen/

run: compile
	test -f notes.config || cp notes.config.template notes.config
	erl \
		-pa ebin deps/*/ebin deps/*/include \
		-name notes@127.0.0.1 \
		-config notes.config \
		-eval "application:start (notes)."

erl: compile
	erl \
		-pa ebin deps/*/ebin deps/*/include \
		-name notes@127.0.0.1

clean: rebar
	./rebar clean

cleaner: clean
	rm -rf .bundle bundle deps rebar

rebar:
	wget https://github.com/downloads/basho/rebar/rebar
	chmod +x rebar

tests: eunit cucumber

eunit:
	./rebar eunit skip_deps=true

cucumber: bundle
	bundle exec cucumber

bundle:
	bundle install --path bundle
