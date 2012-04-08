% Filename: src/data/notes_data_user.erl
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

-module (notes_data_user).

-export ([

	% public api

	get_workspaces/1,
	create_workspace/2,
	stop/1 ]).

-include ("notes_data.hrl").

-define (TARGET,
	notes_data_user_server).

-define (CALL (Message),
	notes_server:call (
		?TARGET,
		UserId,
		Message)).

% public api

get_workspaces (UserId) ->

	?CALL (get_workspaces).

create_workspace (UserId, Name) ->

	?CALL ({ create_workspace, Name }).

stop (UserId) ->

	?CALL (stop).
