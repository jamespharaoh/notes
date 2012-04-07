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
