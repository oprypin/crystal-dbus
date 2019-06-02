require "./lib"
require "./util"

module DBus
  extend self

  private def tokens_to_sig(tokens, io)
    case tok = tokens.next
    when "UInt8"
      io << LibDBus::TYPE_BYTE
    when "Bool"
      io << LibDBus::TYPE_BOOLEAN
    when "Int16"
      io << LibDBus::TYPE_INT16
    when "UInt16"
      io << LibDBus::TYPE_UINT16
    when "Int32"
      io << LibDBus::TYPE_INT32
    when "UInt32"
      io << LibDBus::TYPE_UINT32
    when "Int64"
      io << LibDBus::TYPE_INT64
    when "UInt64"
      io << LibDBus::TYPE_UINT64
    when "Float64"
      io << LibDBus::TYPE_DOUBLE
    when "String"
      io << LibDBus::TYPE_STRING
    when "Variant"
      io << LibDBus::TYPE_VARIANT
    when "Array"
      io << LibDBus::TYPE_ARRAY
      tok = tokens.next; debug_assert tok == "("
      tokens_to_sig(tokens, io) # Recursively parse whatever type is inside
      tok = tokens.next; debug_assert tok == ")"
    when "Hash"
      io << LibDBus::TYPE_ARRAY << LibDBus::DICT_ENTRY_BEGIN_CHAR
      tok = tokens.next
      debug_assert tok == "("
      tokens_to_sig(tokens, io)
      tok = tokens.next
      debug_assert tok == ","
      tokens_to_sig(tokens, io)
      tok = tokens.next
      debug_assert tok == ")"
      io << LibDBus::DICT_ENTRY_END_CHAR
    when "{"
      io << LibDBus::STRUCT_BEGIN_CHAR
      loop do
        tokens_to_sig(tokens, io)
        tok = tokens.next
        break if tok == "}"
        debug_assert tok == ","
      end
      io << LibDBus::STRUCT_END_CHAR
    else
      raise ArgumentError.new("Unexpected #{tok.inspect}")
    end
  end

  # Convert a Crystal type name (limited subset) to a DBus signature
  private def type_name_to_sig(type : String) : String
    tokens = type.gsub("DBus::", "").gsub { |c|
      c.alphanumeric? ? c : " #{c} "
    }.split

    io = String::Builder.new
    tokens_to_sig(tokens.each, io)
    io.to_s
  end

  # Convert a Crystal type (limited subset) to a DBus signature
  def type_to_sig(type) : String
    type_name_to_sig(type.name)
  end

  # Slight optimization in trivial cases
  def type_to_sig(type : UInt8.class) : String
    LibDBus::TYPE_BYTE.to_s
  end

  def type_to_sig(type : Bool.class) : String
    LibDBus::TYPE_BOOLEAN.to_s
  end

  def type_to_sig(type : Int16.class) : String
    LibDBus::TYPE_INT16.to_s
  end

  def type_to_sig(type : UInt16.class) : String
    LibDBus::TYPE_UINT16.to_s
  end

  def type_to_sig(type : Int32.class) : String
    LibDBus::TYPE_INT32.to_s
  end

  def type_to_sig(type : UInt32.class) : String
    LibDBus::TYPE_UINT32.to_s
  end

  def type_to_sig(type : Int64.class) : String
    LibDBus::TYPE_INT64.to_s
  end

  def type_to_sig(type : UInt64.class) : String
    LibDBus::TYPE_UINT64.to_s
  end

  def type_to_sig(type : Float64.class) : String
    LibDBus::TYPE_DOUBLE.to_s
  end

  def type_to_sig(type : String.class) : String
    LibDBus::TYPE_STRING.to_s
  end

  def type_to_sig(type : Variant.class) : String
    LibDBus::TYPE_VARIANT.to_s
  end

  private def signature_next(signature : String, index : Int = 0)
    if index < signature.size
      case signature[index]
      when LibDBus::TYPE_ARRAY
        index += 1
        index = signature_next(signature, index)
      when LibDBus::STRUCT_BEGIN_CHAR
        index += 1
        while signature[index = signature_next(signature, index)] != LibDBus::STRUCT_END_CHAR
        end
        index += 1
      when LibDBus::DICT_ENTRY_BEGIN_CHAR
        index += 1
        index = signature_next(signature, index)
        index = signature_next(signature, index)
        debug_assert signature[index] == LibDBus::DICT_ENTRY_END_CHAR
        index += 1
      else
        index += 1
      end
      index
    else
      signature.size
    end
  end

  # Split a DBus signature into separate types
  def signature_split(signature : String) : Array(String)
    result = [] of String
    prev = 0
    loop do
      nxt = signature_next(signature, prev)
      result << signature[prev...nxt]
      break unless nxt < signature.size
      prev = nxt
    end
    result
  end
end
