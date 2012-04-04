-record (workspace, {
	workspace_id,
	owner }).

-record (workspace_note, {
	note_id,
	text }).

-record (workspace_perm, {
	user_id,
	roles }).

-record (workspace_state, {
	workspace_id,
	perms = [],
	notes = [] }).

-record (user_workspace, {
	workspace_id,
	name }).
