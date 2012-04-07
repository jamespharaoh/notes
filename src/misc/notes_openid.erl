-module (notes_openid).

-export ([
	prepare/3,
	verify/3 ]).

prepare (SessionId, OpenIdUrl, SomeOption) ->

	gen_server:call (
		openid,
		{ prepare, SessionId, OpenIdUrl, SomeOption }).

verify (SessionId, ReturnTo, Params) ->

	gen_server:call (
		openid,
		{ verify, SessionId, ReturnTo, Params }).
