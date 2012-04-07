-module (notes_file).

-export ([
	delete_dir/1 ]).

-include_lib ("kernel/include/file.hrl").

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
