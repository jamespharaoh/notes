% Filename: test/misc/notes_store_test.erl
%
% Copyright 2012 James Pharaoh <james@phsys.co.uk>
%
%    Licensed under the Apache License, Version 2.0 (the "License");
%    you may not use this file except in compliance with the License.
%    You may obtain a copy of the License at
%
%      http://www.apache.org/licenses/LICENSE-2.0
%
%    Unless required by applicable law or agreed to in writing, software
%    distributed under the License is distributed on an "AS IS" BASIS,
%    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%    See the License for the specific language governing permissions and
%    limitations under the License

-module (notes_store_test).

-include ("notes_global.hrl").
-include ("notes_test.hrl").

% macros

-define (MOCK_MODULES, [
	notes_delegate_file,
	notes_delegate_filelib,
	notes_delegate_io,
	notes_file ]).

-define (TARGET, notes_store).

read_not_found_test () ->

	?EXPECT,

		?expect (notes_delegate_file, consult,
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

		?expect (notes_delegate_file, consult,
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

		?expect (notes_delegate_filelib, ensure_dir,
			[ notes_test:match_str ("test/dir/file") ],
			{ return, ok }),

		?expect (notes_delegate_file, open,
			[ notes_test:match_str ("test/dir/file"), [ write ] ],
			{ return, { ok, IoDevice } }),

		?expect (notes_delegate_io, fwrite,
			[ IoDevice, "~p.~n", [ Record1 ] ],
			{ return, ok }),

		?expect (notes_delegate_io, fwrite,
			[ IoDevice, "~p.~n", [ Record2 ] ],
			{ return, ok }),

		?expect (notes_delegate_file, close,
			[ IoDevice ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (
			ok,
			?TARGET:write ("dir/file", Records)),

	?VERIFY.

delete_all_test () ->

	?EXPECT,

		?expect (notes_file, delete_dir,
			[ notes_test:match_str ("test") ],
			{ return, ok }),

	?REPLAY,

		?assertEqual (
			ok,
			?TARGET:delete_all ()),

	?VERIFY.
