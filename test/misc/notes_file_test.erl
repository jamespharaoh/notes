-module (notes_file_test).

-include ("notes_test.hrl").

-include_lib ("kernel/include/file.hrl").

% macros

-define (MOCK_MODULES, [
	file ]).

-define (TARGET,
	notes_file).

delete_dir_not_exist_test () ->

	?EXPECT,

		?expect (file, read_link_info,
			[ notes_test:match_str ("path") ],
			{ return, { error, enoent } }),

	?REPLAY,

		?assertEqual (
			ok,
			?TARGET:delete_dir ("path")),

	?VERIFY.

delete_dir_normal_test () ->

	DirInfo =
		#file_info {
			type = directory },

	FileInfo =
		#file_info {
			type = regular },

	Filenames = [
		"file 1",
		"file 2" ],

	?EXPECT,

		?expect (file, read_link_info,
			[ notes_test:match_str ("path") ],
			{ return, { ok, DirInfo } }),

		?expect (file, list_dir,
			[ notes_test:match_str ("path") ],
			{ return, { ok, Filenames } }),

		?expect (file, read_link_info,
			[ notes_test:match_str ("path/file 1") ],
			{ return, { ok, FileInfo } }),

		?expect (file, delete,
			[ notes_test:match_str ("path/file 1") ],
			{ return, ok }),

		?expect (file, read_link_info,
			[ notes_test:match_str ("path/file 2") ],
			{ return, { ok, FileInfo } }),

		?expect (file, delete,
			[ notes_test:match_str ("path/file 2") ],
			{ return, ok }),

		?expect (file, del_dir,
			[ notes_test:match_str ("path") ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (
			ok,
			?TARGET:delete_dir ("path")),

	?VERIFY.
