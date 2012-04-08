% Filename: include/notes_data.hrl
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

-record (workspace, {
	workspace_id,
	name }).

-record (workspace_note, {
	note_id,
	text }).

-record (workspace_perm, {
	user_id,
	roles }).

-record (workspace_state, {
	workspace_id,
	workspace,
	perms = [],
	notes = [] }).

-record (user_workspace, {
	workspace_id,
	name }).

-record (user_state, {
	user_id,
	workspaces = [] }).
