require "dbus"

bus = DBus::Bus.new


dest = bus.destination("org.kde.yakuake")
dest.object("/yakuake/sessions").interface("org.kde.yakuake").call("runCommand", ["echo 'Hello, World!'"])


obj = bus.object("org.freedesktop.Notifications", "/org/freedesktop/Notifications")
int = obj.interface("org.freedesktop.Notifications")

int.call("Notify", ["", 0u32, "", "", "Notification", [] of String, {} of String => DBus::Variant, -1])

int.call("Notify", [
  "Crystal Messenger", 0u32, "mail-message-new", "New Message", "<b>Hi!</b><br/>- Oleh",
  ["default", "Reply", "other", "Ignore"], {"category": DBus.variant("email.arrived")}, -1
], signature="susssasa{sv}i")

p int.call("GetServerInformation").reply
