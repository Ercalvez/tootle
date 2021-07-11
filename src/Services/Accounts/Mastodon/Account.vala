public class Tootle.Mastodon.Account : InstanceAccount {

	public const string BACKEND = "Mastodon";

	public const string EVENT_NEW_POST = "update";
	public const string EVENT_DELETE_POST = "delete";
	public const string EVENT_NOTIFICATION = "notification";

    public const string KIND_MENTION = "mention";
    public const string KIND_REBLOG = "reblog";
    public const string KIND_FAVOURITE = "favourite";
    public const string KIND_FOLLOW = "follow";
    public const string KIND_POLL = "poll";
    public const string KIND_FOLLOW_REQUEST = "__follow-request";
    public const string KIND_REMOTE_REBLOG = "__remote-reblog";

    public Views.Sidebar.Item notifications_item;

    construct {
        notifications_item = new Views.Sidebar.Item () {
			label = "Notifications",
			icon = "bell-symbolic",
			on_activated = () => {
			    app.main_window.open_view (new Views.Notifications ());
			}
		};
		bind_property ("unread_count", notifications_item, "badge", BindingFlags.SYNC_CREATE);
    }

	class Test : AccountStore.BackendTest {

		public override string? get_backend (Json.Object obj) {
			return BACKEND; // Always treat instances as compatible with Mastodon
		}

	}

	public static void register (AccountStore store) {
		store.backend_tests.add (new Test ());
		store.create_for_backend[BACKEND].connect ((node) => {
			var account = Entity.from_json (typeof (Account), node) as Account;
			account.backend = BACKEND;
			return account;
		});
	}

	public override void populate_user_menu (GLib.ListStore model) {
		model.append (new Views.Sidebar.Item () {
			label = "Timelines",
			icon = "user-home-symbolic"
		});
		model.append (notifications_item);
		model.append (new Views.Sidebar.Item () {
			label = "Direct Messages",
			icon = API.Visibility.DIRECT.get_icon ()
		});
		model.append (new Views.Sidebar.Item () {
			label = "Bookmarks",
			icon = "user-bookmarks-symbolic"
		});
		model.append (new Views.Sidebar.Item () {
			label = "Favorites",
			icon = "non-starred-symbolic"
		});
		model.append (new Views.Sidebar.Item () {
			label = "Lists",
			icon = "view-list-symbolic"
		});
		model.append (new Views.Sidebar.Item () {
			label = "Search",
			icon = "system-search-symbolic"
		});
	}

    public override void describe_kind (string kind, out string? icon, out string? descr, API.Account account) {
        switch (kind) {
            case KIND_MENTION:
                icon = "user-available-symbolic";
                descr = _("<span underline=\"none\"><a href=\"%s\">%s</a> mentioned you</span>").printf (account.url, account.display_name);
                break;
            case KIND_REBLOG:
                icon = "media-playlist-repeat-symbolic";
                descr = _("<span underline=\"none\"><a href=\"%s\">%s</a> boosted your status</span>").printf (account.url, account.display_name);
                break;
            case KIND_REMOTE_REBLOG:
                icon = "media-playlist-repeat-symbolic";
                descr = _("<span underline=\"none\"><a href=\"%s\">%s</a> boosted</span>").printf (account.url, account.display_name);
                break;
            case KIND_FAVOURITE:
                icon = "starred-symbolic";
                descr = _("<span underline=\"none\"><a href=\"%s\">%s</a> favorited your status</span>").printf (account.url, account.display_name);
                break;
            case KIND_FOLLOW:
                icon = "contact-new-symbolic";
                descr = _("<span underline=\"none\"><a href=\"%s\">%s</a> now follows you</span>").printf (account.url, account.display_name);
                break;
            case KIND_FOLLOW_REQUEST:
                icon = "contact-new-symbolic";
                descr = _("<span underline=\"none\"><a href=\"%s\">%s</a> wants to follow you</span>").printf (account.url, account.display_name);
                break;
            case KIND_POLL:
                icon = "emblem-default-symbolic";
                descr = _("Poll results");
                break;
            default:
                icon = null;
                descr = null;
                break;
        }
    }

}