-module (notes_wf_test).

-include_lib ("eunit/include/eunit.hrl").

-include ("data.hrl").

% macros

-define (EXPECT,
	Em = em:new (),
	em:nothing (Em, notes_random),
	em:nothing (Em, wf)).

-define (REPLAY,
	em:replay (Em)).

-define (VERIFY,
	em:verify (Em)).

-define (TARGET,
	notes_data_workspace_server).

% fixtures

session_id_undefined_test () ->

	?EXPECT,

		em:strict (Em, wf, session,
			[ session_id ],
			{ return, undefined }),

		em:strict (Em, notes_random, random_id,
			[],
			{ return, "session_id" }),

		em:strict (Em, wf, session,
			[ session_id, "session_id" ]),

	?REPLAY,

		?assertEqual (
			"session_id",
			notes_wf:session_id ()),

	?VERIFY.

session_id_already_defined_test () ->

	?EXPECT,

		em:strict (Em, wf, session,
			[ session_id ],
			{ return, "session_id" }),

	?REPLAY,

		?assertEqual (
			"session_id",
			notes_wf:session_id ()),

	?VERIFY.
