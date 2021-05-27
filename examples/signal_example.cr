# This example illustrates how to listen for the signals emitted on the system and the session buses

require "dbus"

def start_properties_changed_listener(bus : DBus::Bus, proc : Proc(Array(DBus::Type), Void))
  spawn do
    err = LibDBus::Error.new
    LibDBus.error_init(pointerof(err))
    conn = bus.to_unsafe
    puts "Bus Address #{conn}"
    str = "type='signal',interface='org.freedesktop.DBus.Properties'"
    LibDBus.bus_add_match(conn, str, pointerof(err))
    if LibDBus.error_is_set(pointerof(err)) == LibDBus::TRUE
      error = String.new(err.message)
      LibDBus.error_free(pointerof(err))
      raise error
    end
    LibDBus.connection_flush(conn)

    while LibDBus.connection_read_write(conn, 0)
      msg = LibDBus.connection_pop_message(conn)
      if msg.null?
        sleep 1
        next
      else
        if LibDBus.message_is_signal(msg, "org.freedesktop.DBus.Properties", "PropertiesChanged")
          arg = DBus::MethodArg.new(msg)
          res = arg.arguments
          proc.call(res)
        end
      end
    end
  end
end


sys_bus = DBus::Bus.new(DBus::BusType::SYSTEM)
ses_bus = DBus::Bus.new(DBus::BusType::SESSION)

def system_sig_handler(event : Array(DBus::Type)) : Void
  puts "SYSTEM : #{event}"
end

def session_sig_handler(event : Array(DBus::Type)) : Void
  puts "SESSION : #{event}"
end

start_properties_changed_listener(ses_bus, ->session_sig_handler(Array(DBus::Type)))
start_properties_changed_listener(sys_bus, ->system_sig_handler(Array(DBus::Type)))

sleep
