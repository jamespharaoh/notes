-module (notes_path_test_reset).

-include_lib ("kernel/include/file.hrl").
-include_lib ("nitrogen_core/include/wf.hrl").

-include ("data.hrl").

-compile (export_all).

main () ->

	StopFunc = fun

		({ user, UserId }, Count) ->
			notes_data_user:stop (UserId),
			Count + 1;

		({ workspace, WorkspaceId }, Count) ->
			notes_data_workspace:stop (WorkspaceId),
			Count + 1;

		(_, Count) ->
			Count

		end,

	NumStopped = lists:foldl (
		StopFunc,
		0,
		global:registered_names ()),

	io:format (
		"RESET - stopped ~w processes.~n",
		[ NumStopped ]),

	timer:sleep (1),

	delete_dir ("data/workspaces"),

	delete_dir ("data/users"),

	"DATABASE RESET".

delete_dir (Path) ->

	delete_dir ([ Path ], undefined).

delete_dir ([ Path | Rest ], Prefix) ->

	FullPath =
		case Prefix of
			undefined -> Path;
			_ -> [ Prefix, "/", Path ]
			end,

	case file:read_link_info (FullPath) of

		{ error, enoent } ->

			ok;

		{ ok, FileInfo } ->

			case FileInfo #file_info.type of

				regular ->

					file:delete (FullPath),

					delete_dir (Rest, Prefix);

				directory ->

					{ ok, Filenames } =
						file:list_dir (FullPath),

					delete_dir (Filenames, FullPath),

					file:del_dir (FullPath),

					delete_dir (Rest, Prefix)

				end
		end;

delete_dir ([], _Prefix) ->

	ok.
