
default: compile

get-deps:
	rebar get-deps

compile: get-deps
	rebar compile
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

clean:
	rebar clean
