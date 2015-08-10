require "./lib"
require "./signature"
require "./util"

module DBus
extend self
  
  alias BusType = LibDBus::BusType
  
  class Variant
    def initialize(@value, signature=nil: String?)
      if signature
        @signature = signature
      else
        @signature = DBus.type_to_sig(@value.class)
      end
    end
    
    getter value
    getter signature
  end
  
  def variant(value, signature=nil: String?)
    Variant.new(value, signature)
  end
  
  class Bus
    def initialize(bus_type=BusType::SESSION)
      LibDBus.error_init(out err)
      
      @bus = LibDBus.bus_get(bus_type, pointerof(err))
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
    
    def object(destination: String, path: String)
      Object.new(self, destination, path)
    end
    def destination(destination: String)
      Object.new(self, destination, "/")
    end
    
    def to_unsafe
      @bus
    end
  end
  
  
  class Object
    def initialize(@bus: Bus, @destination=nil: String?, @path="/": String)
    end
    
    property bus
    property destination
    property path
    
    def object(path: String)
      if !path.starts_with? "/"
        path = @path + "/" + path
      end
      Object.new(bus, destination, path)
    end
    
    def interface(interface: String)
      Interface.new(self, interface)
    end
  end
  
  
  class Interface
    def initialize(@object: Object, @interface: String)
    end
    
    property object
    property interface
    
    def call(name: String, args: Array, signature=nil: String?, timeout=-1: Int32, reply=true: Bool)
      if object.destination
        msg = LibDBus.message_new_method_call(
          object.destination, object.path, interface, name
        )
        assert msg, "message_new_method_call error"
      else
        msg = LibDBus.message_new_signal(
          object.path, interface, name
        )
        assert msg, "message_new_signal error"
      end
      
      if !reply
        LibDBus.message_set_no_reply(msg, LibDBus::TRUE)
      end
      
      iter_v :: LibDBus::MessageIter
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
      
      if reply
        assert LibDBus.connection_send_with_reply(object.bus, msg, out pending, timeout) == LibDBus::TRUE, "connection_send_with_reply error"
      else
        assert LibDBus.connection_send(object.bus, msg, nil) == LibDBus::TRUE, "connection_send error"
      end

      LibDBus.connection_flush(object.bus)

      LibDBus.message_unref(msg)
    end
    
    private def append_arg(arg, iter: LibDBus::MessageIter*, signature: String)
      case signature[0]
        when LibDBus::TYPE_BYTE
          assert arg.is_a? UInt8
          append_basic_arg(arg, iter, signature[0])
        when LibDBus::TYPE_BOOLEAN
          assert arg.is_a? Bool
          append_basic_arg(arg ? 1u32 : 0u32, iter, signature[0])
        when LibDBus::TYPE_INT16
          assert arg.is_a? Int16
          append_basic_arg(arg, iter, signature[0])
        when LibDBus::TYPE_UINT16
          assert arg.is_a? UInt16
          append_basic_arg(arg, iter, signature[0])
        when LibDBus::TYPE_INT32
          assert arg.is_a? Int32
          append_basic_arg(arg, iter, signature[0])
        when LibDBus::TYPE_UINT32
          assert arg.is_a? UInt32
          append_basic_arg(arg, iter, signature[0])
        when LibDBus::TYPE_INT64
          assert arg.is_a? Int64
          append_basic_arg(arg, iter, signature[0])
        when LibDBus::TYPE_UINT64
          assert arg.is_a? UInt64
          append_basic_arg(arg, iter, signature[0])
        when LibDBus::TYPE_DOUBLE
          assert arg.is_a? Float64
          append_basic_arg(arg, iter, signature[0])
        when LibDBus::TYPE_STRING
          assert arg.is_a? String
          append_basic_arg(arg, iter, signature[0])
        
        when LibDBus::TYPE_ARRAY
          item_sig = signature[1..-1]
          
          arr_iter_v :: LibDBus::MessageIter
          arr_iter = pointerof(arr_iter_v)
          assert LibDBus.message_iter_open_container(
            iter, LibDBus::TYPE_ARRAY.ord, item_sig, arr_iter
          ) == LibDBus::TRUE, "message_iter_open_container error"
          
          if item_sig[0] == LibDBus::DICT_ENTRY_BEGIN_CHAR
            assert arg.is_a? Hash
            debug_assert item_sig[-1] == LibDBus::DICT_ENTRY_END_CHAR
            kv_sigs = DBus.signature_split(item_sig[1...-1])
            debug_assert kv_sigs.length == 2
            key_sig, value_sig = kv_sigs
            
            arg.each do |key, value|
              entry_iter_v :: LibDBus::MessageIter
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
          
          var_iter_v :: LibDBus::MessageIter
          var_iter = pointerof(var_iter_v)
          assert LibDBus.message_iter_open_container(
            iter, LibDBus::TYPE_VARIANT.ord, arg.signature, var_iter
          ) == LibDBus::TRUE, "message_iter_open_container error"
          
          append_arg(arg.value, var_iter, arg.signature)
          
          assert LibDBus.message_iter_close_container(
            iter, var_iter
          ) == LibDBus::TRUE, "message_iter_close_container error"
      end
    end
    
    private def append_basic_arg(arg, iter: LibDBus::MessageIter*, signature: Char)
      val = if arg.responds_to? :to_unsafe
        arg.to_unsafe
      else
        arg
      end
      assert LibDBus.message_iter_append_basic(
        iter, signature.ord, pointerof(val) as Pointer(Void)
      ) == LibDBus::TRUE, "message_iter_append_basic error"
    end
  end
end
