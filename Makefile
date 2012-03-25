
default: compile

get-deps:
	rebar get-deps

compile: get-deps
	rebar compile
	rsync --recursive --delete deps/nitrogen_core/www/ static/nitrogen/
	cp etc/apps/* ebin

run: compile
	erl \
		-pa ebin deps/*/ebin deps/*/include \
		-name nitrogen@127.0.0.1 \
		-eval "application:start (notes)."
clean:
	rebar clean
