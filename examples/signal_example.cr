require "dbus"
require "dbus/signals"

sys_bus = DBus::Bus.new(DBus::BusType::SYSTEM)
ses_bus = DBus::Bus.new(DBus::BusType::SESSION)

def system_sig_handler( event : Array(DBus::Type)) : Void
  puts "SYSTEM : #{event}" 
end

def session_sig_handler( event : Array(DBus::Type)) : Void
  puts "SESSION : #{event}" 
end

DBus.start_properties_changed_listener( ses_bus, ->session_sig_handler(Array(DBus::Type)))
DBus.start_properties_changed_listener( sys_bus, ->system_sig_handler(Array(DBus::Type)))

while(true)
  sleep 1
end

