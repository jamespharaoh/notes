-record (workspace, {
	workspace_id,
	owner }).

-record (workspace_note, {
	note_id,
	text }).

-record (workspace_perm, {
	user_id,
	roles }).

-record (user_workspace, {
	workspace_id,
	name }).
