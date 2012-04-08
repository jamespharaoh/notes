% Filename: src/layout/notes_layout_loginout.erl
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

-module (notes_layout_loginout).

-include_lib ("nitrogen_core/include/wf.hrl").

-include ("notes_data.hrl").

-compile (export_all).

layout () ->

	case wf:user () of

		undefined ->

			#link {
				text = "Log in",
				url = "/" };

		_ ->

			#button {
				id = log_out_button,
				text = "Log out",
				delegate = ?MODULE,
				postback = logout }

		end.

event (logout) ->

	wf:clear_user (),

	wf:redirect ("/").
