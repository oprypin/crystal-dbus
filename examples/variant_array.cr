# This example illustrates passing an array as a Variant type needed in some DBus method arguments.
# Note: This code will actually work properly and pull all contacts from a phone to a file "/tmp/contacts.txt"
# provided there is a phonebookAccess session already started. 
# And X in "/org/bluez/obex/client/sessionX" must be replaced by the correct session number that has previously been started.
# This can be observed via a dbus monitoring tool like D-feet.
# See Bluez obex PhonebookAccess for more info

require "dbus"
bus_s = DBus::Bus.new DBus::BusType::SESSION

dest_obex = bus_s.destination("org.bluez.obex")
obj_obex = dest_obex.object("/org/bluez/obex/client/session27")
int_obex = obj_obex.interface("org.bluez.obex.PhonebookAccess1")

obex_res = int_obex.call("PullAll",["/tmp/contacts.txt",{"Format" => DBus.variant("vcard30"), "Fields" => DBus.variant_array(["FN","TEL","PHOTO","ADR"],String)}], signature: "sa{sv}")
puts obex_res.reply
