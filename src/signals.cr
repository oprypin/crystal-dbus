require "./lib"
require "./util"

module DBus
  extend self

  def start_properties_changed_listener(bus : Bus, proc : Proc(Array(Type), Void))
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
            arg = DBus::SignalArg.new(msg)
            res = arg.arguments
            proc.call(res)
          end
        end
      end
    end
  end

  class SignalArg
    def initialize(@msg : LibDBus::Message)
    end

    def arguments
      iter_v = uninitialized LibDBus::MessageIter
      iter = pointerof(iter_v)
      reply = [] of Type
      if LibDBus.message_iter_init(@msg, iter) == LibDBus::TRUE
        while LibDBus.message_iter_get_arg_type(iter) != LibDBus::TYPE_INVALID.ord
          reply << DBus.read_arg(iter)
          LibDBus.message_iter_next(iter)
        end
      end
      LibDBus.message_unref(@msg)
      reply
    end
  end
end
