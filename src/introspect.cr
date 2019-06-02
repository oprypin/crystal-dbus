require "xml"
require "./dbus"

module DBus
  class Object
    @introspection : XML::Node?

    def introspect
      @introspection ||= XML.parse(
        interface("org.freedesktop.DBus.Introspectable").call("Introspect").reply[0].as String
      ).children[-1]
    end

    def list_objects
      introspect.children.select { |c| c.name == "node" }.map { |obj| object(obj["name"].not_nil!) }
    end

    def list_interfaces
      introspect.children.select { |c| c.name == "interface" }.map { |int| interface(int["name"].not_nil!) }
    end
  end

  struct Interface
    def introspect
      object.introspect.children.each do |item|
        if item.name == "interface" && item["name"] == interface
          return item
        end
      end
      raise "No such interface"
    end

    def list_methods
      introspect.children.select { |c| c.name == "method" }.map { |meth|
        in_args, out_args = [] of Argument, [] of Argument
        meth.children.select { |c| c.name == "arg" }.each do |arg|
          (arg["direction"]? == "out" ? out_args : in_args) << Argument.new(arg["name"]?, arg["type"].not_nil!)
        end
        Method.new(self, meth["name"].not_nil!, in_args, out_args)
      }
    end

    def list_signals
      introspect.children.select { |c| c.name == "signal" }.map { |sig|
        args = sig.children.select { |c| c.name == "arg" }.map { |arg|
          Argument.new(arg["name"], arg["type"])
        }
        Signal.new(self, sig["name"].not_nil!, args)
      }
    end

    def list_properties
      introspect.children.select { |c| c.name == "property" }.map { |sig|
        args = sig.children.select { |c| c.name == "arg" }.map { |arg|
          Argument.new(arg["name"], arg["type"])
        }
        Property.new(
          self, sig["name"].not_nil!, sig["type"].not_nil!,
          sig["access"].try &.includes?("read") || false, sig["access"].try &.includes?("write") || false)
      }
    end
  end

  struct Method
    getter interface : Interface
    getter name : String
    getter args : Array(Argument)
    getter out_args : Array(Argument)

    def initialize(@interface, @name, @args, @out_args)
    end

    def signature
      args.map { |arg| arg.type }.join
    end

    def call(args : Array = [] of Nil, timeout : Int32 = -1)
      @interface.call(@name, args, signature: signature, timeout: timeout)
    end

    def inspect(io : IO)
      interface.inspect(io)
      io << ' ' << name << "(" << (args.map &.inspect).join(", ") << ")->(" << (out_args.map &.inspect).join(", ") << ")"
    end
  end

  struct Signal
    getter interface : Interface
    getter name : String
    getter args : Array(Argument)

    def initialize(@interface, @name, @args)
    end

    def signature
      args.map { |arg| arg.type }.join
    end

    def inspect(io : IO)
      interface.inspect(io)
      io << ' ' << name << '(' << (args.map &.inspect).join(", ") << ')'
    end
  end

  struct Property
    getter interface : Interface
    getter name : String
    getter type : String
    getter? readable : Bool
    getter? writable : Bool

    def initialize(@interface, @name, @type, @readable, @writable)
    end

    def get(timeout : Int32 = -1)
      @interface.call(@name, signature: "", timeout: timeout)
    end

    def set(value, timeout : Int32 = -1)
      @interface.call(@name, [value], signature: @type, timeout: timeout)
    end

    def inspect(io : IO)
      interface.inspect(io)
      io << ' ' << name << '[' << (@readable && 'r') << (@writable && 'w') << ']' << ':' << type
    end
  end

  struct Argument
    getter name : String?
    getter type : String?

    def initialize(@name, @type)
    end

    def inspect(io : IO)
      io << name << ':' << type
    end
  end
end
