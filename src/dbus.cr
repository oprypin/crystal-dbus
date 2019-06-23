require "./lib"
require "./signature"
require "./util"

module DBus
  extend self

  alias BusType = LibDBus::BusType

  class Variant
    getter value : Type
    getter signature : String?

    def initialize(@value : Type, @signature : String? = nil)
    end

    def signature
      @signature ||= DBus.type_to_sig(@value.class)
    end

    def inspect(io : IO)
      io << "DBus.variant(" << value << ")"
    end
  end

  def variant(value, signature : String? = nil)
    Variant.new(value, signature)
  end

  alias Type = UInt8 | Bool | Int16 | UInt16 | Int32 | UInt32 | Int64 | UInt64 | Float64 | String | Array(Type) | Hash(Type, Type) | Variant

  class Bus
    getter type : BusType

    def initialize(@type = BusType::SESSION)
      LibDBus.error_init(out err)

      @bus = LibDBus.bus_get(@type, pointerof(err))
      if LibDBus.error_is_set(pointerof(err)) == LibDBus::TRUE
        error = String.new(err.message)
        LibDBus.error_free(pointerof(err))
        raise error
      end
      assert @bus, "bus_get error"
    end

    def finalize
      LibDBus.connection_unref(@bus)
    end

    def object(destination : String, path : String)
      Object.new(self, destination, path)
    end

    def destination(destination : String)
      Object.new(self, destination, "/")
    end

    def inspect(io : IO)
      io << type
    end

    def to_unsafe
      @bus
    end
  end


  class Object
    getter bus : Bus
    getter destination : String?

    def initialize(@bus : Bus, @destination : String? = nil, @path : String = "/")
      unless @path.starts_with? "/"
        raise ArgumentError.new("Must specify absolute path")
      end
      @path = @path.chomp "/"
    end

    def path
      @path.empty? ? "/" : @path
    end
    def name
      path.split('/')[-1]
    end

    def object(path : String)
      if !path.starts_with? "/"
        path = @path + "/" + path
      end
      Object.new(bus, destination, path)
    end

    def interface(interface : String)
      Interface.new(self, interface)
    end

    def inspect(io : IO)
      bus.inspect(io)
      io << ' ' << destination << ' ' << path
    end

    def property_interface
      interface "org.freedesktop.DBus.Properties"
    end
  end


  struct Interface
    getter object : Object
    getter interface : String

    def initialize(@object : Object, @interface : String)
    end

    def call(name : String, args : Array = [] of Nil, signature : String? = nil, timeout : Int32 = -1)
      if dest = object.destination
        msg = LibDBus.message_new_method_call(
          dest, object.path, interface, name
        )
        assert msg, "message_new_method_call error"
      else
        msg = LibDBus.message_new_signal(
          object.path, interface, name
        )
        assert msg, "message_new_signal error"
      end

      #LibDBus.message_set_no_reply(msg, LibDBus::TRUE)

      iter_v = uninitialized LibDBus::MessageIter
      iter = pointerof(iter_v)
      LibDBus.message_iter_init_append(msg, iter)

      signatures = if signature
                     DBus.signature_split(signature)
                   else
                     args.map { |arg| DBus.type_to_sig(arg.class) }
                   end
      args.zip(signatures) do |arg, sig|
        append_arg(arg, iter, sig)
      end

      pending = uninitialized LibDBus::PendingCall
      assert LibDBus.connection_send_with_reply(object.bus, msg, pointerof(pending), timeout) == LibDBus::TRUE, "connection_send_with_reply error"
      assert pending, "connection_send_with_reply error"

      #assert LibDBus.connection_send(object.bus, msg, nil) == LibDBus::TRUE, "connection_send error"

      LibDBus.connection_flush(object.bus)

      LibDBus.message_unref(msg)

      Pending.new(pending)
    end

    private def append_arg(arg, iter : LibDBus::MessageIter*, signature : String)
      case sig0 = signature[0]
      when LibDBus::TYPE_BYTE
        assert arg.is_a? UInt8
        append_basic_arg(arg, iter, sig0)
      when LibDBus::TYPE_BOOLEAN
        assert arg.is_a? Bool
        append_basic_arg(arg ? 1u32 : 0u32, iter, sig0)
      when LibDBus::TYPE_INT16
        assert arg.is_a? Int16
        append_basic_arg(arg, iter, sig0)
      when LibDBus::TYPE_UINT16
        assert arg.is_a? UInt16
        append_basic_arg(arg, iter, sig0)
      when LibDBus::TYPE_INT32
        assert arg.is_a? Int32
        append_basic_arg(arg, iter, sig0)
      when LibDBus::TYPE_UINT32
        assert arg.is_a? UInt32
        append_basic_arg(arg, iter, sig0)
      when LibDBus::TYPE_INT64
        assert arg.is_a? Int64
        append_basic_arg(arg, iter, sig0)
      when LibDBus::TYPE_UINT64
        assert arg.is_a? UInt64
        append_basic_arg(arg, iter, sig0)
      when LibDBus::TYPE_DOUBLE
        assert arg.is_a? Float64
        append_basic_arg(arg, iter, sig0)
      when LibDBus::TYPE_STRING
        assert arg.is_a? String
        append_basic_arg(arg, iter, sig0)
      when LibDBus::TYPE_OBJECT_PATH
        assert arg.is_a? String
        append_basic_arg(arg, iter, sig0)
      when LibDBus::TYPE_ARRAY
        item_sig = signature[1..-1]

        arr_iter_v = uninitialized LibDBus::MessageIter
        arr_iter = pointerof(arr_iter_v)
        assert LibDBus.message_iter_open_container(
          iter, LibDBus::TYPE_ARRAY.ord, item_sig, arr_iter
        ) == LibDBus::TRUE, "message_iter_open_container error"

        if item_sig[0] == LibDBus::DICT_ENTRY_BEGIN_CHAR
          assert arg.is_a? Hash
          debug_assert item_sig[-1] == LibDBus::DICT_ENTRY_END_CHAR
          kv_sigs = DBus.signature_split(item_sig[1...-1])
          debug_assert kv_sigs.size == 2
          key_sig, value_sig = kv_sigs

          arg.each do |key, value|
            entry_iter_v = uninitialized LibDBus::MessageIter
            entry_iter = pointerof(entry_iter_v)
            assert LibDBus.message_iter_open_container(
              arr_iter, LibDBus::TYPE_DICT_ENTRY.ord, nil, entry_iter
            ) == LibDBus::TRUE, "message_iter_open_container error"

            append_arg(key, entry_iter, key_sig)
            append_arg(value, entry_iter, value_sig)

            assert LibDBus.message_iter_close_container(
              arr_iter, entry_iter
            ) == LibDBus::TRUE, "message_iter_close_container error"
          end

        else
          assert arg.is_a? Array
          arg.each do |item|
            append_arg(item, arr_iter, item_sig)
          end
        end

        assert LibDBus.message_iter_close_container(
          iter, arr_iter
        ) == LibDBus::TRUE, "message_iter_close_container error"

      when LibDBus::TYPE_VARIANT
        assert arg.is_a? Variant

        var_iter_v = uninitialized LibDBus::MessageIter
        var_iter = pointerof(var_iter_v)
        assert LibDBus.message_iter_open_container(
          iter, LibDBus::TYPE_VARIANT.ord, arg.signature, var_iter
        ) == LibDBus::TRUE, "message_iter_open_container error"

        append_arg(arg.value, var_iter, arg.signature)

        assert LibDBus.message_iter_close_container(
          iter, var_iter
        ) == LibDBus::TRUE, "message_iter_close_container error"

      else
        raise "Unsupported type '#{signature}'"
      end
    end

    private def append_basic_arg(arg, iter : LibDBus::MessageIter*, signature : Char)
      val = if arg.responds_to?(:to_unsafe)
              arg.to_unsafe
            else
              arg
            end
      assert LibDBus.message_iter_append_basic(
        iter, signature.ord, pointerof(val).as Pointer(Void)
      ) == LibDBus::TRUE, "message_iter_append_basic error"
    end

    def get(key : String, timeout : Int32 = -1)
      @object.property_interface.call("Get", [@interface, key], timeout: timeout)
    end

    def set(key : String, value : T, timeout : Int32 = -1) forall T
      @object.property_interface.call("Set", [@interface, key, value], timeout: timeout)
    end

    def inspect(io : IO)
      object.inspect(io)
      io << ' ' << interface
    end
  end


  class Pending
    def initialize(@pending : LibDBus::PendingCall)
    end

    def reply
      LibDBus.pending_call_block(@pending)
      msg = LibDBus.pending_call_steal_reply(@pending)
      assert msg, "pending_call_steal_reply error"

      iter_v = uninitialized LibDBus::MessageIter
      iter = pointerof(iter_v)
      reply = [] of Type
      if LibDBus.message_iter_init(msg, iter) == LibDBus::TRUE
        while LibDBus.message_iter_get_arg_type(iter) != LibDBus::TYPE_INVALID.ord
          reply << read_arg(iter)
          LibDBus.message_iter_next(iter)
        end
      end
      #       if (!dbus_message_iter_next(&args))
      #           fprintf(stderr, "Message has too few arguments!\n");
      #       else if (DBUS_TYPE_UINT32 != dbus_message_iter_get_arg_type(&args))
      #           fprintf(stderr, "Argument is not int!\n");
      #       else
      #           dbus_message_iter_get_basic(&args, &level);

      LibDBus.message_unref(msg)

      reply
    end

    private def read_arg(iter : LibDBus::MessageIter*)
      case type = LibDBus.message_iter_get_arg_type(iter)
      when LibDBus::TYPE_BYTE.ord
        result_u8 = uninitialized UInt8
        LibDBus.message_iter_get_basic(iter, pointerof(result_u8).as Pointer(Void))
        result_u8
      when LibDBus::TYPE_BOOLEAN.ord
        result_u32 = uninitialized UInt32
        LibDBus.message_iter_get_basic(iter, pointerof(result_u32).as Pointer(Void))
        result_u32 != 0u32
      when LibDBus::TYPE_INT16.ord
        result_i16 = uninitialized Int16
        LibDBus.message_iter_get_basic(iter, pointerof(result_i16).as Pointer(Void))
        result_i16
      when LibDBus::TYPE_UINT16.ord
        result_u16 = uninitialized UInt16
        LibDBus.message_iter_get_basic(iter, pointerof(result_u16).as Pointer(Void))
        result_u16
      when LibDBus::TYPE_INT32.ord
        result_i32 = uninitialized Int32
        LibDBus.message_iter_get_basic(iter, pointerof(result_i32).as Pointer(Void))
        result_i32
      when LibDBus::TYPE_UINT32.ord
        result_u32 = uninitialized UInt32
        LibDBus.message_iter_get_basic(iter, pointerof(result_u32).as Pointer(Void))
        result_u32
      when LibDBus::TYPE_INT64.ord
        result_i64 = uninitialized Int64
        LibDBus.message_iter_get_basic(iter, pointerof(result_i64).as Pointer(Void))
        result_i64
      when LibDBus::TYPE_UINT64.ord
        result_u64 = uninitialized UInt64
        LibDBus.message_iter_get_basic(iter, pointerof(result_u64).as Pointer(Void))
        result_u64
      when LibDBus::TYPE_DOUBLE.ord
        result_f64 = uninitialized Float64
        LibDBus.message_iter_get_basic(iter, pointerof(result_f64).as Pointer(Void))
        result_f64
      when LibDBus::TYPE_STRING.ord
        result_pchar = uninitialized Pointer(UInt8)
        LibDBus.message_iter_get_basic(iter, pointerof(result_pchar).as Pointer(Void))
        String.new(result_pchar)
      when LibDBus::TYPE_OBJECT_PATH.ord
        result_pchar = uninitialized Pointer(UInt8)
        LibDBus.message_iter_get_basic(iter, pointerof(result_pchar).as Pointer(Void))
        String.new(result_pchar)
      when LibDBus::TYPE_STRUCT.ord
        arr_iter_v = uninitialized LibDBus::MessageIter
        arr_iter = pointerof(arr_iter_v)
        LibDBus.message_iter_recurse(
          iter, arr_iter
        )

        result_array = [] of DBus::Type
        while LibDBus.message_iter_get_arg_type(arr_iter) != LibDBus::TYPE_INVALID.ord
          result_array << read_arg(arr_iter)
          LibDBus.message_iter_next(arr_iter)
        end
        result_array

      when LibDBus::TYPE_ARRAY.ord
        arr_iter_v = uninitialized LibDBus::MessageIter
        arr_iter = pointerof(arr_iter_v)
        LibDBus.message_iter_recurse(
          iter, arr_iter
        )

        if LibDBus.message_iter_get_element_type(iter) == LibDBus::TYPE_DICT_ENTRY.ord
          result_hash = {} of Type => Type

          while LibDBus.message_iter_get_arg_type(arr_iter) != LibDBus::TYPE_INVALID.ord
            entry_iter_v = uninitialized LibDBus::MessageIter
            entry_iter = pointerof(entry_iter_v)
            LibDBus.message_iter_recurse(
              arr_iter, entry_iter
            )

            key = read_arg(entry_iter)
            LibDBus.message_iter_next(entry_iter)
            result_hash[key] = read_arg(entry_iter)

            LibDBus.message_iter_next(arr_iter)
          end

          result_hash

        else
          result_array = [] of Type

          while LibDBus.message_iter_get_arg_type(arr_iter) != LibDBus::TYPE_INVALID.ord
            result_array << read_arg(arr_iter)
            LibDBus.message_iter_next(arr_iter)
          end

          result_array
        end

      when LibDBus::TYPE_VARIANT.ord
        var_iter_v = uninitialized LibDBus::MessageIter
        var_iter = pointerof(var_iter_v)
        LibDBus.message_iter_recurse(
          iter, var_iter
        )

        DBus.variant(read_arg(var_iter))

      else
        raise "Unsupported type '#{type.chr}'"
      end
    end

    def finalize
      LibDBus.pending_call_unref(@pending)
    end
  end
end
