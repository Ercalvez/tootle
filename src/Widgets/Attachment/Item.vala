using Gtk;

public class Tootle.Widgets.Attachment.Item : Adw.Bin {

	public API.Attachment entity { get; set; default = null; }

	protected Overlay overlay;
	protected Button button;
	protected Label badge;

	construct {
		height_request = 164;

		notify["entity"].connect (on_rebind);
		add_css_class ("flat");

		button = new Button ();
		button.clicked.connect (on_click);

		badge = new Label ("") {
			valign = Align.END,
			halign = Align.START
		};
		badge.add_css_class ("osd");
		badge.add_css_class ("heading");

		overlay = new Overlay ();
		overlay.child = button;
		overlay.add_overlay (badge);

		child = overlay;
		child.add_css_class ("attachment");
	}

	protected virtual void on_rebind () {
		badge.label = entity == null ? "" : entity.kind.up();
	}

	protected virtual void on_click () {
		open.begin ((obj, res) => {
			try {
				open.end (res);
			}
			catch (Error e) {
				app.inform (Gtk.MessageType.ERROR, _("Error"), e.message);
			}
		});
	}

	protected async void open () throws Error {
		var path = yield Desktop.download (entity.url);
		Desktop.open_uri (path);
	}

}
