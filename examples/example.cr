require "dbus"

bus = DBus::Bus.new


dest = bus.destination("org.kde.yakuake")
dest.object("/yakuake/sessions").interface("org.kde.yakuake").call("runCommand", ["echo 'Hello, World!'"])


obj = bus.object("org.freedesktop.Notifications", "/org/freedesktop/Notifications")
int = obj.interface("org.freedesktop.Notifications")

int.call("Notify", ["", 0u32, "", "", "Notification", [] of String, {} of String => DBus::Variant, -1])

int.call("Notify", [
  "Crystal Messenger", 0u32, "mail-message-new", "New Message", "<b>Hi!</b><br/>- Oleh",
  ["default", "Reply", "other", "Ignore"], {"category" => DBus.variant("email.arrived")}, -1
], signature: "susssasa{sv}i")

p int.call("GetServerInformation").reply


require "dbus/introspect"

macro show(arr)
  puts {{arr.stringify}} + ":"
  {{arr}}.each do |x|
    puts "  " + x.inspect
  end
end

dest = bus.destination("org.freedesktop.Notifications")
show dest.list_objects

obj = dest.object("/org/freedesktop/Notifications")
show obj.list_interfaces

int = obj.interface("org.freedesktop.Notifications")
show int.list_methods
show int.list_signals
show int.list_properties
