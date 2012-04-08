% Filename: test/misc/notes_file_test.erl
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
