-module (notes_start).

-ifndef (TEST).

-export ([
	run/0 ]).

run () ->

	% start system

	ok = application:start (compiler),
	ok = application:start (syntax_tools),
	ok = application:start (crypto),
	ok = application:start (inets),
	ok = application:start (public_key),
	ok = application:start (ssl),
	ok = application:start (xmerl),

	% start mochiweb

	ok = application:start (mochiweb),

	% start openid

	ok = application:start (ibrowse),
	ok = application:start (openid),

	% start nitrogen

	ok = application:start (nprocreg),
	ok = application:start (sasl),
	ok = application:start (nitrogen_core),

	% start notes

	ok = application:start (notes),

	ok.

-endif.
