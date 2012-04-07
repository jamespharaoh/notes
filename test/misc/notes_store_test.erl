-module (notes_store_test).

-include ("notes_global.hrl").
-include ("notes_test.hrl").

% macros

-define (MOCK_MODULES, [
	notes_delegate_file,
	notes_delegate_filelib,
	notes_delegate_io ]).

-define (TARGET, notes_store).

read_not_found_test () ->

	?EXPECT,

		em:strict (Em, notes_delegate_file, consult,
			[ notes_test:match_str ("test/dir/file") ],
			{ return, { error, enoent } }),

	?REPLAY,

		?assertEqual (
			{ ok, [] },
			?TARGET:read ("dir/file")),

	?VERIFY.

read_normal_test () ->

	Records = [
		{ record, 1 },
		{ record, 2 } ],

	?EXPECT,

		em:strict (Em, notes_delegate_file, consult,
			[ notes_test:match_str ("test/dir/file") ],
			{ return, { ok, Records } }),

	?REPLAY,

		?assertEqual (
			{ ok, Records },
			?TARGET:read ("dir/file")),

	?VERIFY.

write_test () ->

	Record1 = { record, 1 },
	Record2 = { record, 2 },

	Records = [ Record1, Record2 ],

	IoDevice =
		io_device,

	?EXPECT,

		em:strict (Em, notes_delegate_filelib, ensure_dir,
			[ notes_test:match_str ("test/dir/file") ],
			{ return, ok }),

		em:strict (Em, notes_delegate_file, open,
			[ notes_test:match_str ("test/dir/file"), [ write ] ],
			{ return, { ok, IoDevice } }),

		em:strict (Em, notes_delegate_io, fwrite,
			[ IoDevice, "~p.~n", [ Record1 ] ],
			{ return, ok }),

		em:strict (Em, notes_delegate_io, fwrite,
			[ IoDevice, "~p.~n", [ Record2 ] ],
			{ return, ok }),

		em:strict (Em, notes_delegate_file, close,
			[ IoDevice ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (
			ok,
			?TARGET:write ("dir/file", Records)),

	?VERIFY.

delete_all_test () ->

	?EXPECT,

		em:strict (Em, notes_file, delete_dir,
			[ notes_test:match_str ("test") ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (
			ok,
			?TARGET:delete_all ()),

	?VERIFY.
