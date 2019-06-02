@[Link("dbus-1")]
lib LibDBus
  TRUE  = 1u32
  FALSE = 0u32

  HAVE_INT64 = true

  MAJOR_VERSION  =  1
  MINOR_VERSION  =  6
  MICRO_VERSION  = 18
  VERSION_STRING = "1.6.18"
  VERSION        = ((1 << 16) | (6 << 8) | (18))

  alias UnicharT = UInt32

  alias BoolT = UInt32

  struct EightByteStruct
    first32 : UInt32
    second32 : UInt32
  end

  union BasicValue
    bytes : UInt8[8]
    i16 : Int16
    u16 : UInt16
    i32 : Int32
    u32 : UInt32
    bool_val : BoolT
    i64 : Int64
    u64 : UInt64
    eight : EightByteStruct
    dbl : Float64
    byt : UInt8
    str : UInt8*
    fd : Int32
  end

  LITTLE_ENDIAN = 'l'
  BIG_ENDIAN    = 'B'

  MAJOR_PROTOCOL_VERSION = 1

  TYPE_INVALID     = '\0'
  TYPE_BYTE        = 'y'
  TYPE_BOOLEAN     = 'b'
  TYPE_INT16       = 'n'
  TYPE_UINT16      = 'q'
  TYPE_INT32       = 'i'
  TYPE_UINT32      = 'u'
  TYPE_INT64       = 'x'
  TYPE_UINT64      = 't'
  TYPE_DOUBLE      = 'd'
  TYPE_STRING      = 's'
  TYPE_OBJECT_PATH = 'o'
  TYPE_SIGNATURE   = 'g'
  TYPE_UNIX_FD     = 'h'
  TYPE_ARRAY       = 'a'
  TYPE_VARIANT     = 'v'
  TYPE_STRUCT      = 'r'
  TYPE_DICT_ENTRY  = 'e'

  NUMBER_OF_TYPES = 16

  STRUCT_BEGIN_CHAR     = '('
  STRUCT_END_CHAR       = ')'
  DICT_ENTRY_BEGIN_CHAR = '{'
  DICT_ENTRY_END_CHAR   = '}'

  MAXIMUM_NAME_LENGTH           =      255
  MAXIMUM_SIGNATURE_LENGTH      =      255
  MAXIMUM_MATCH_RULE_LENGTH     =     1024
  MAXIMUM_MATCH_RULE_ARG_NUMBER =       63
  MAXIMUM_ARRAY_LENGTH          = 67108864
  MAXIMUM_ARRAY_LENGTH_BITS     =       26
  MAXIMUM_MESSAGE_LENGTH        = (DBUS_MAXIMUM_ARRAY_LENGTH * 2)
  MAXIMUM_MESSAGE_LENGTH_BITS   = 27
  MAXIMUM_MESSAGE_UNIX_FDS      = (DBUS_MAXIMUM_MESSAGE_LENGTH / 4)
  MAXIMUM_MESSAGE_UNIX_FDS_BITS = (DBUS_MAXIMUM_MESSAGE_LENGTH_BITS - 2)

  MAXIMUM_TYPE_RECURSION_DEPTH = 32

  MESSAGE_TYPE_INVALID       = 0
  MESSAGE_TYPE_METHOD_CALL   = 1
  MESSAGE_TYPE_METHOD_RETURN = 2
  MESSAGE_TYPE_ERROR         = 3
  MESSAGE_TYPE_SIGNAL        = 4

  NUM_MESSAGE_TYPES = 5

  HEADER_FLAG_NO_REPLY_EXPECTED = 0x1u32
  HEADER_FLAG_NO_AUTO_START     = 0x2u32

  HEADER_FIELD_INVALID      = 0
  HEADER_FIELD_PATH         = 1
  HEADER_FIELD_INTERFACE    = 2
  HEADER_FIELD_MEMBER       = 3
  HEADER_FIELD_ERROR_NAME   = 4
  HEADER_FIELD_REPLY_SERIAL = 5
  HEADER_FIELD_DESTINATION  = 6
  HEADER_FIELD_SENDER       = 7
  HEADER_FIELD_SIGNATURE    = 8
  HEADER_FIELD_UNIX_FDS     = 9

  HEADER_FIELD_LAST = DBUS_HEADER_FIELD_UNIX_FDS

  HEADER_SIGNATURE = [TYPE_BYTE, TYPE_BYTE, TYPE_BYTE, TYPE_BYTE, TYPE_UINT32, TYPE_UINT32, TYPE_ARRAY, STRUCT_BEGIN_CHAR, TYPE_BYTE, TYPE_VARIANT, STRUCT_END_CHAR].join

  MINIMUM_HEADER_SIZE = 16

  struct Error
    name : UInt8*
    message : UInt8*
    dummy1 : UInt32
    dummy2 : UInt32
    dummy3 : UInt32
    dummy4 : UInt32
    dummy5 : UInt32
    padding1 : Void*
  end

  fun error_init = "dbus_error_init"(error : Error*) : Void

  fun error_free = "dbus_error_free"(error : Error*) : Void

  fun set_error = "dbus_set_error"(error : Error*, name : UInt8*, message : UInt8*, ...) : Void

  fun set_error_const = "dbus_set_error_const"(error : Error*, name : UInt8*, message : UInt8*) : Void

  fun move_error = "dbus_move_error"(src : Error*, dest : Error*) : Void

  fun error_has_name = "dbus_error_has_name"(error : Error*, name : UInt8*) : BoolT

  fun error_is_set = "dbus_error_is_set"(error : Error*) : BoolT

  type AddressEntry = Void*

  fun parse_address = "dbus_parse_address"(address : UInt8*, entry : AddressEntry**, array_len : Int32*, error : Error*) : BoolT

  fun address_entry_get_value = "dbus_address_entry_get_value"(entry : AddressEntry, key : UInt8*) : UInt8*

  fun address_entry_get_method = "dbus_address_entry_get_method"(entry : AddressEntry) : UInt8*

  fun address_entries_free = "dbus_address_entries_free"(entries : AddressEntry*) : Void

  fun address_escape_value = "dbus_address_escape_value"(value : UInt8*) : UInt8*

  fun address_unescape_value = "dbus_address_unescape_value"(value : UInt8*, error : Error*) : UInt8*

  fun malloc = "dbus_malloc"(bytes : LibC::SizeT) : Void*

  fun malloc0 = "dbus_malloc0"(bytes : LibC::SizeT) : Void*

  fun realloc = "dbus_realloc"(memory : Void*, bytes : LibC::SizeT) : Void*

  fun free = "dbus_free"(memory : Void*) : Void

  fun free_string_array = "dbus_free_string_array"(str_array : UInt8**) : Void

  alias FreeFunction = Void* -> Void

  fun shutdown = "dbus_shutdown" : Void

  type Message = Void*

  struct MessageIter
    dummy1 : Void*
    dummy2 : Void*
    dummy3 : UInt32
    dummy4 : Int32
    dummy5 : Int32
    dummy6 : Int32
    dummy7 : Int32
    dummy8 : Int32
    dummy9 : Int32
    dummy10 : Int32
    dummy11 : Int32
    pad1 : Int32
    pad2 : Int32
    pad3 : Void*
  end

  fun message_new = "dbus_message_new"(message_type : Int32) : Message

  fun message_new_method_call = "dbus_message_new_method_call"(bus_name : UInt8*, path : UInt8*, iface : UInt8*, method : UInt8*) : Message

  fun message_new_method_return = "dbus_message_new_method_return"(method_call : Message) : Message

  fun message_new_signal = "dbus_message_new_signal"(path : UInt8*, iface : UInt8*, name : UInt8*) : Message

  fun message_new_error = "dbus_message_new_error"(reply_to : Message, error_name : UInt8*, error_message : UInt8*) : Message

  fun message_new_error_printf = "dbus_message_new_error_printf"(reply_to : Message, error_name : UInt8*, error_format : UInt8*, ...) : Message

  fun message_copy = "dbus_message_copy"(message : Message) : Message

  fun message_ref = "dbus_message_ref"(message : Message) : Message

  fun message_unref = "dbus_message_unref"(message : Message) : Void

  fun message_get_type = "dbus_message_get_type"(message : Message) : Int32

  fun message_set_path = "dbus_message_set_path"(message : Message, object_path : UInt8*) : BoolT

  fun message_get_path = "dbus_message_get_path"(message : Message) : UInt8*

  fun message_has_path = "dbus_message_has_path"(message : Message, object_path : UInt8*) : BoolT

  fun message_set_interface = "dbus_message_set_interface"(message : Message, iface : UInt8*) : BoolT

  fun message_get_interface = "dbus_message_get_interface"(message : Message) : UInt8*

  fun message_has_interface = "dbus_message_has_interface"(message : Message, iface : UInt8*) : BoolT

  fun message_set_member = "dbus_message_set_member"(message : Message, member : UInt8*) : BoolT

  fun message_get_member = "dbus_message_get_member"(message : Message) : UInt8*

  fun message_has_member = "dbus_message_has_member"(message : Message, member : UInt8*) : BoolT

  fun message_set_error_name = "dbus_message_set_error_name"(message : Message, name : UInt8*) : BoolT

  fun message_get_error_name = "dbus_message_get_error_name"(message : Message) : UInt8*

  fun message_set_destination = "dbus_message_set_destination"(message : Message, destination : UInt8*) : BoolT

  fun message_get_destination = "dbus_message_get_destination"(message : Message) : UInt8*

  fun message_set_sender = "dbus_message_set_sender"(message : Message, sender : UInt8*) : BoolT

  fun message_get_sender = "dbus_message_get_sender"(message : Message) : UInt8*

  fun message_get_signature = "dbus_message_get_signature"(message : Message) : UInt8*

  fun message_set_no_reply = "dbus_message_set_no_reply"(message : Message, no_reply : BoolT) : Void

  fun message_get_no_reply = "dbus_message_get_no_reply"(message : Message) : BoolT

  fun message_is_method_call = "dbus_message_is_method_call"(message : Message, iface : UInt8*, method : UInt8*) : BoolT

  fun message_is_signal = "dbus_message_is_signal"(message : Message, iface : UInt8*, signal_name : UInt8*) : BoolT

  fun message_is_error = "dbus_message_is_error"(message : Message, error_name : UInt8*) : BoolT

  fun message_has_destination = "dbus_message_has_destination"(message : Message, bus_name : UInt8*) : BoolT

  fun message_has_sender = "dbus_message_has_sender"(message : Message, unique_bus_name : UInt8*) : BoolT

  fun message_has_signature = "dbus_message_has_signature"(message : Message, signature : UInt8*) : BoolT

  fun message_get_serial = "dbus_message_get_serial"(message : Message) : UInt32

  fun message_set_serial = "dbus_message_set_serial"(message : Message, serial : UInt32) : Void

  fun message_set_reply_serial = "dbus_message_set_reply_serial"(message : Message, reply_serial : UInt32) : BoolT

  fun message_get_reply_serial = "dbus_message_get_reply_serial"(message : Message) : UInt32

  fun message_set_auto_start = "dbus_message_set_auto_start"(message : Message, auto_start : BoolT) : Void

  fun message_get_auto_start = "dbus_message_get_auto_start"(message : Message) : BoolT

  fun message_get_path_decomposed = "dbus_message_get_path_decomposed"(message : Message, path : UInt8***) : BoolT

  fun message_append_args = "dbus_message_append_args"(message : Message, first_arg_type : Int32, ...) : BoolT

  fun message_append_args_valist = "dbus_message_append_args_valist"(message : Message, first_arg_type : Int32, ...) : BoolT

  fun message_get_args = "dbus_message_get_args"(message : Message, error : Error*, first_arg_type : Int32, ...) : BoolT

  fun message_get_args_valist = "dbus_message_get_args_valist"(message : Message, error : Error*, first_arg_type : Int32, ...) : BoolT

  fun message_contains_unix_fds = "dbus_message_contains_unix_fds"(message : Message) : BoolT

  fun message_iter_init = "dbus_message_iter_init"(message : Message, iter : MessageIter*) : BoolT

  fun message_iter_has_next = "dbus_message_iter_has_next"(iter : MessageIter*) : BoolT

  fun message_iter_next = "dbus_message_iter_next"(iter : MessageIter*) : BoolT

  fun message_iter_get_signature = "dbus_message_iter_get_signature"(iter : MessageIter*) : UInt8*

  fun message_iter_get_arg_type = "dbus_message_iter_get_arg_type"(iter : MessageIter*) : Int32

  fun message_iter_get_element_type = "dbus_message_iter_get_element_type"(iter : MessageIter*) : Int32

  fun message_iter_recurse = "dbus_message_iter_recurse"(iter : MessageIter*, sub : MessageIter*) : Void

  fun message_iter_get_basic = "dbus_message_iter_get_basic"(iter : MessageIter*, value : Void*) : Void

  fun message_iter_get_array_len = "dbus_message_iter_get_array_len"(iter : MessageIter*) : Int32

  fun message_iter_get_fixed_array = "dbus_message_iter_get_fixed_array"(iter : MessageIter*, value : Void*, n_elements : Int32*) : Void

  fun message_iter_init_append = "dbus_message_iter_init_append"(message : Message, iter : MessageIter*) : Void

  fun message_iter_append_basic = "dbus_message_iter_append_basic"(iter : MessageIter*, type : Int32, value : Void*) : BoolT

  fun message_iter_append_fixed_array = "dbus_message_iter_append_fixed_array"(iter : MessageIter*, element_type : Int32, value : Void*, n_elements : Int32) : BoolT

  fun message_iter_open_container = "dbus_message_iter_open_container"(iter : MessageIter*, type : Int32, contained_signature : UInt8*, sub : MessageIter*) : BoolT

  fun message_iter_close_container = "dbus_message_iter_close_container"(iter : MessageIter*, sub : MessageIter*) : BoolT

  fun message_iter_abandon_container = "dbus_message_iter_abandon_container"(iter : MessageIter*, sub : MessageIter*) : Void

  fun message_lock = "dbus_message_lock"(message : Message) : Void

  fun set_error_from_message = "dbus_set_error_from_message"(error : Error*, message : Message) : BoolT

  fun message_allocate_data_slot = "dbus_message_allocate_data_slot"(slot_p : Int32*) : BoolT

  fun message_free_data_slot = "dbus_message_free_data_slot"(slot_p : Int32*) : Void

  fun message_set_data = "dbus_message_set_data"(message : Message, slot : Int32, data : Void*, free_data_func : FreeFunction) : BoolT

  fun message_get_data = "dbus_message_get_data"(message : Message, slot : Int32) : Void*

  fun message_type_from_string = "dbus_message_type_from_string"(type_str : UInt8*) : Int32

  fun message_type_to_string = "dbus_message_type_to_string"(type : Int32) : UInt8*

  fun message_marshal = "dbus_message_marshal"(msg : Message, marshalled_data_p : UInt8**, len_p : Int32*) : BoolT

  fun message_demarshal = "dbus_message_demarshal"(str : UInt8*, len : Int32, error : Error*) : Message

  fun message_demarshal_bytes_needed = "dbus_message_demarshal_bytes_needed"(str : UInt8*, len : Int32) : Int32

  enum BusType
    SESSION
    SYSTEM
    STARTER
  end
  BUS_SESSION = BusType::SESSION
  BUS_SYSTEM  = BusType::SYSTEM
  BUS_STARTER = BusType::STARTER

  enum HandlerResult
    HANDLED
    NOT_YET_HANDLED
    NEED_MEMORY
  end
  HANDLER_RESULT_HANDLED         = HandlerResult::HANDLED
  HANDLER_RESULT_NOT_YET_HANDLED = HandlerResult::NOT_YET_HANDLED
  HANDLER_RESULT_NEED_MEMORY     = HandlerResult::NEED_MEMORY

  NAME_FLAG_ALLOW_REPLACEMENT = 0x1u32
  NAME_FLAG_REPLACE_EXISTING  = 0x2u32
  NAME_FLAG_DO_NOT_QUEUE      = 0x4u32

  REQUEST_NAME_REPLY_PRIMARY_OWNER = 1
  REQUEST_NAME_REPLY_IN_QUEUE      = 2
  REQUEST_NAME_REPLY_EXISTS        = 3
  REQUEST_NAME_REPLY_ALREADY_OWNER = 4

  RELEASE_NAME_REPLY_RELEASED     = 1
  RELEASE_NAME_REPLY_NON_EXISTENT = 2
  RELEASE_NAME_REPLY_NOT_OWNER    = 3

  START_REPLY_SUCCESS         = 1
  START_REPLY_ALREADY_RUNNING = 2

  type Watch = Void*

  type Timeout = Void*

  type PreallocatedSend = Void*

  type PendingCall = Void*

  type Connection = Void*

  @[Flags]
  enum WatchFlags
    READABLE = 1 << 0
    WRITABLE = 1 << 1
    ERROR    = 1 << 2
    HANGUP   = 1 << 3
  end
  WATCH_READABLE = WatchFlags::READABLE
  WATCH_WRITABLE = WatchFlags::WRITABLE
  WATCH_ERROR    = WatchFlags::ERROR
  WATCH_HANGUP   = WatchFlags::HANGUP

  enum DispatchStatus
    DATA_REMAINS
    COMPLETE
    NEED_MEMORY
  end
  DISPATCH_DATA_REMAINS = DispatchStatus::DATA_REMAINS
  DISPATCH_COMPLETE     = DispatchStatus::COMPLETE
  DISPATCH_NEED_MEMORY  = DispatchStatus::NEED_MEMORY

  alias AddWatchFunction = (Watch, Void*) -> BoolT

  alias WatchToggledFunction = (Watch, Void*) -> Void

  alias RemoveWatchFunction = (Watch, Void*) -> Void

  alias AddTimeoutFunction = (Timeout, Void*) -> BoolT

  alias TimeoutToggledFunction = (Timeout, Void*) -> Void

  alias RemoveTimeoutFunction = (Timeout, Void*) -> Void

  alias DispatchStatusFunction = (Connection, DispatchStatus, Void*) -> Void

  alias WakeupMainFunction = Void* -> Void

  alias AllowUnixUserFunction = (Connection, LibC::Long, Void*) -> BoolT

  alias AllowWindowsUserFunction = (Connection, UInt8*, Void*) -> BoolT

  alias PendingCallNotifyFunction = (PendingCall, Void*) -> Void

  alias HandleMessageFunction = (Connection, Message, Void*) -> HandlerResult

  fun connection_open = "dbus_connection_open"(address : UInt8*, error : Error*) : Connection

  fun connection_open_private = "dbus_connection_open_private"(address : UInt8*, error : Error*) : Connection

  fun connection_ref = "dbus_connection_ref"(connection : Connection) : Connection

  fun connection_unref = "dbus_connection_unref"(connection : Connection) : Void

  fun connection_close = "dbus_connection_close"(connection : Connection) : Void

  fun connection_get_is_connected = "dbus_connection_get_is_connected"(connection : Connection) : BoolT

  fun connection_get_is_authenticated = "dbus_connection_get_is_authenticated"(connection : Connection) : BoolT

  fun connection_get_is_anonymous = "dbus_connection_get_is_anonymous"(connection : Connection) : BoolT

  fun connection_get_server_id = "dbus_connection_get_server_id"(connection : Connection) : UInt8*

  fun connection_can_send_type = "dbus_connection_can_send_type"(connection : Connection, type : Int32) : BoolT

  fun connection_set_exit_on_disconnect = "dbus_connection_set_exit_on_disconnect"(connection : Connection, exit_on_disconnect : BoolT) : Void

  fun connection_flush = "dbus_connection_flush"(connection : Connection) : Void

  fun connection_read_write_dispatch = "dbus_connection_read_write_dispatch"(connection : Connection, timeout_milliseconds : Int32) : BoolT

  fun connection_read_write = "dbus_connection_read_write"(connection : Connection, timeout_milliseconds : Int32) : BoolT

  fun connection_borrow_message = "dbus_connection_borrow_message"(connection : Connection) : Message

  fun connection_return_message = "dbus_connection_return_message"(connection : Connection, message : Message) : Void

  fun connection_steal_borrowed_message = "dbus_connection_steal_borrowed_message"(connection : Connection, message : Message) : Void

  fun connection_pop_message = "dbus_connection_pop_message"(connection : Connection) : Message

  fun connection_get_dispatch_status = "dbus_connection_get_dispatch_status"(connection : Connection) : DispatchStatus

  fun connection_dispatch = "dbus_connection_dispatch"(connection : Connection) : DispatchStatus

  fun connection_has_messages_to_send = "dbus_connection_has_messages_to_send"(connection : Connection) : BoolT

  fun connection_send = "dbus_connection_send"(connection : Connection, message : Message, client_serial : UInt32*) : BoolT

  fun connection_send_with_reply = "dbus_connection_send_with_reply"(connection : Connection, message : Message, pending_return : PendingCall*, timeout_milliseconds : Int32) : BoolT

  fun connection_send_with_reply_and_block = "dbus_connection_send_with_reply_and_block"(connection : Connection, message : Message, timeout_milliseconds : Int32, error : Error*) : Message

  fun connection_set_watch_functions = "dbus_connection_set_watch_functions"(connection : Connection, add_function : AddWatchFunction, remove_function : RemoveWatchFunction, toggled_function : WatchToggledFunction, data : Void*, free_data_function : FreeFunction) : BoolT

  fun connection_set_timeout_functions = "dbus_connection_set_timeout_functions"(connection : Connection, add_function : AddTimeoutFunction, remove_function : RemoveTimeoutFunction, toggled_function : TimeoutToggledFunction, data : Void*, free_data_function : FreeFunction) : BoolT

  fun connection_set_wakeup_main_function = "dbus_connection_set_wakeup_main_function"(connection : Connection, wakeup_main_function : WakeupMainFunction, data : Void*, free_data_function : FreeFunction) : Void

  fun connection_set_dispatch_status_function = "dbus_connection_set_dispatch_status_function"(connection : Connection, function : DispatchStatusFunction, data : Void*, free_data_function : FreeFunction) : Void

  fun connection_get_unix_user = "dbus_connection_get_unix_user"(connection : Connection, uid : LibC::Long*) : BoolT

  fun connection_get_unix_process_id = "dbus_connection_get_unix_process_id"(connection : Connection, pid : LibC::Long*) : BoolT

  fun connection_get_adt_audit_session_data = "dbus_connection_get_adt_audit_session_data"(connection : Connection, data : Void**, data_size : Int32*) : BoolT

  fun connection_set_unix_user_function = "dbus_connection_set_unix_user_function"(connection : Connection, function : AllowUnixUserFunction, data : Void*, free_data_function : FreeFunction) : Void

  fun connection_get_windows_user = "dbus_connection_get_windows_user"(connection : Connection, windows_sid_p : UInt8**) : BoolT

  fun connection_set_windows_user_function = "dbus_connection_set_windows_user_function"(connection : Connection, function : AllowWindowsUserFunction, data : Void*, free_data_function : FreeFunction) : Void

  fun connection_set_allow_anonymous = "dbus_connection_set_allow_anonymous"(connection : Connection, value : BoolT) : Void

  fun connection_set_route_peer_messages = "dbus_connection_set_route_peer_messages"(connection : Connection, value : BoolT) : Void

  fun connection_add_filter = "dbus_connection_add_filter"(connection : Connection, function : HandleMessageFunction, user_data : Void*, free_data_function : FreeFunction) : BoolT

  fun connection_remove_filter = "dbus_connection_remove_filter"(connection : Connection, function : HandleMessageFunction, user_data : Void*) : Void

  fun connection_allocate_data_slot = "dbus_connection_allocate_data_slot"(slot_p : Int32*) : BoolT

  fun connection_free_data_slot = "dbus_connection_free_data_slot"(slot_p : Int32*) : Void

  fun connection_set_data = "dbus_connection_set_data"(connection : Connection, slot : Int32, data : Void*, free_data_func : FreeFunction) : BoolT

  fun connection_get_data = "dbus_connection_get_data"(connection : Connection, slot : Int32) : Void*

  fun connection_set_change_sigpipe = "dbus_connection_set_change_sigpipe"(will_modify_sigpipe : BoolT) : Void

  fun connection_set_max_message_size = "dbus_connection_set_max_message_size"(connection : Connection, size : LibC::Long) : Void

  fun connection_get_max_message_size = "dbus_connection_get_max_message_size"(connection : Connection) : LibC::Long

  fun connection_set_max_received_size = "dbus_connection_set_max_received_size"(connection : Connection, size : LibC::Long) : Void

  fun connection_get_max_received_size = "dbus_connection_get_max_received_size"(connection : Connection) : LibC::Long

  fun connection_set_max_message_unix_fds = "dbus_connection_set_max_message_unix_fds"(connection : Connection, n : LibC::Long) : Void

  fun connection_get_max_message_unix_fds = "dbus_connection_get_max_message_unix_fds"(connection : Connection) : LibC::Long

  fun connection_set_max_received_unix_fds = "dbus_connection_set_max_received_unix_fds"(connection : Connection, n : LibC::Long) : Void

  fun connection_get_max_received_unix_fds = "dbus_connection_get_max_received_unix_fds"(connection : Connection) : LibC::Long

  fun connection_get_outgoing_size = "dbus_connection_get_outgoing_size"(connection : Connection) : LibC::Long

  fun connection_get_outgoing_unix_fds = "dbus_connection_get_outgoing_unix_fds"(connection : Connection) : LibC::Long

  fun connection_preallocate_send = "dbus_connection_preallocate_send"(connection : Connection) : PreallocatedSend

  fun connection_free_preallocated_send = "dbus_connection_free_preallocated_send"(connection : Connection, preallocated : PreallocatedSend) : Void

  fun connection_send_preallocated = "dbus_connection_send_preallocated"(connection : Connection, preallocated : PreallocatedSend, message : Message, client_serial : UInt32*) : Void

  alias ObjectPathUnregisterFunction = (Connection, Void*) -> Void

  alias ObjectPathMessageFunction = (Connection, Message, Void*) -> HandlerResult

  struct ObjectPathVTable
    unregister_function : ObjectPathUnregisterFunction
    message_function : ObjectPathMessageFunction
    dbus_internal_pad1 : Void* -> Void
    dbus_internal_pad2 : Void* -> Void
    dbus_internal_pad3 : Void* -> Void
    dbus_internal_pad4 : Void* -> Void
  end

  fun connection_try_register_object_path = "dbus_connection_try_register_object_path"(connection : Connection, path : UInt8*, vtable : ObjectPathVTable*, user_data : Void*, error : Error*) : BoolT

  fun connection_register_object_path = "dbus_connection_register_object_path"(connection : Connection, path : UInt8*, vtable : ObjectPathVTable*, user_data : Void*) : BoolT

  fun connection_try_register_fallback = "dbus_connection_try_register_fallback"(connection : Connection, path : UInt8*, vtable : ObjectPathVTable*, user_data : Void*, error : Error*) : BoolT

  fun connection_register_fallback = "dbus_connection_register_fallback"(connection : Connection, path : UInt8*, vtable : ObjectPathVTable*, user_data : Void*) : BoolT

  fun connection_unregister_object_path = "dbus_connection_unregister_object_path"(connection : Connection, path : UInt8*) : BoolT

  fun connection_get_object_path_data = "dbus_connection_get_object_path_data"(connection : Connection, path : UInt8*, data_p : Void**) : BoolT

  fun connection_list_registered = "dbus_connection_list_registered"(connection : Connection, parent_path : UInt8*, child_entries : UInt8***) : BoolT

  fun connection_get_unix_fd = "dbus_connection_get_unix_fd"(connection : Connection, fd : Int32*) : BoolT

  fun connection_get_socket = "dbus_connection_get_socket"(connection : Connection, fd : Int32*) : BoolT

  fun watch_get_fd = "dbus_watch_get_fd"(watch : Watch) : Int32

  fun watch_get_unix_fd = "dbus_watch_get_unix_fd"(watch : Watch) : Int32

  fun watch_get_socket = "dbus_watch_get_socket"(watch : Watch) : Int32

  fun watch_get_flags = "dbus_watch_get_flags"(watch : Watch) : UInt32

  fun watch_get_data = "dbus_watch_get_data"(watch : Watch) : Void*

  fun watch_set_data = "dbus_watch_set_data"(watch : Watch, data : Void*, free_data_function : FreeFunction) : Void

  fun watch_handle = "dbus_watch_handle"(watch : Watch, flags : UInt32) : BoolT

  fun watch_get_enabled = "dbus_watch_get_enabled"(watch : Watch) : BoolT

  fun timeout_get_interval = "dbus_timeout_get_interval"(timeout : Timeout) : Int32

  fun timeout_get_data = "dbus_timeout_get_data"(timeout : Timeout) : Void*

  fun timeout_set_data = "dbus_timeout_set_data"(timeout : Timeout, data : Void*, free_data_function : FreeFunction) : Void

  fun timeout_handle = "dbus_timeout_handle"(timeout : Timeout) : BoolT

  fun timeout_get_enabled = "dbus_timeout_get_enabled"(timeout : Timeout) : BoolT

  fun bus_get = "dbus_bus_get"(type : BusType, error : Error*) : Connection

  fun bus_get_private = "dbus_bus_get_private"(type : BusType, error : Error*) : Connection

  fun bus_register = "dbus_bus_register"(connection : Connection, error : Error*) : BoolT

  fun bus_set_unique_name = "dbus_bus_set_unique_name"(connection : Connection, unique_name : UInt8*) : BoolT

  fun bus_get_unique_name = "dbus_bus_get_unique_name"(connection : Connection) : UInt8*

  fun bus_get_unix_user = "dbus_bus_get_unix_user"(connection : Connection, name : UInt8*, error : Error*) : LibC::Long

  fun bus_get_id = "dbus_bus_get_id"(connection : Connection, error : Error*) : UInt8*

  fun bus_request_name = "dbus_bus_request_name"(connection : Connection, name : UInt8*, flags : UInt32, error : Error*) : Int32

  fun bus_release_name = "dbus_bus_release_name"(connection : Connection, name : UInt8*, error : Error*) : Int32

  fun bus_name_has_owner = "dbus_bus_name_has_owner"(connection : Connection, name : UInt8*, error : Error*) : BoolT

  fun bus_start_service_by_name = "dbus_bus_start_service_by_name"(connection : Connection, name : UInt8*, flags : UInt32, reply : UInt32*, error : Error*) : BoolT

  fun bus_add_match = "dbus_bus_add_match"(connection : Connection, rule : UInt8*, error : Error*) : Void

  fun bus_remove_match = "dbus_bus_remove_match"(connection : Connection, rule : UInt8*, error : Error*) : Void

  fun get_local_machine_id = "dbus_get_local_machine_id" : UInt8*

  fun get_version = "dbus_get_version"(major_version_p : Int32*, minor_version_p : Int32*, micro_version_p : Int32*) : Void

  TIMEOUT_INFINITE = 0x7fffffff

  TIMEOUT_USE_DEFAULT = (-1)

  fun pending_call_ref = "dbus_pending_call_ref"(pending : PendingCall) : PendingCall

  fun pending_call_unref = "dbus_pending_call_unref"(pending : PendingCall) : Void

  fun pending_call_set_notify = "dbus_pending_call_set_notify"(pending : PendingCall, function : PendingCallNotifyFunction, user_data : Void*, free_user_data : FreeFunction) : BoolT

  fun pending_call_cancel = "dbus_pending_call_cancel"(pending : PendingCall) : Void

  fun pending_call_get_completed = "dbus_pending_call_get_completed"(pending : PendingCall) : BoolT

  fun pending_call_steal_reply = "dbus_pending_call_steal_reply"(pending : PendingCall) : Message

  fun pending_call_block = "dbus_pending_call_block"(pending : PendingCall) : Void

  fun pending_call_allocate_data_slot = "dbus_pending_call_allocate_data_slot"(slot_p : Int32*) : BoolT

  fun pending_call_free_data_slot = "dbus_pending_call_free_data_slot"(slot_p : Int32*) : Void

  fun pending_call_set_data = "dbus_pending_call_set_data"(pending : PendingCall, slot : Int32, data : Void*, free_data_func : FreeFunction) : BoolT

  fun pending_call_get_data = "dbus_pending_call_get_data"(pending : PendingCall, slot : Int32) : Void*

  type Server = Void*

  alias NewConnectionFunction = (Server, Connection, Void*) -> Void

  fun server_listen = "dbus_server_listen"(address : UInt8*, error : Error*) : Server

  fun server_ref = "dbus_server_ref"(server : Server) : Server

  fun server_unref = "dbus_server_unref"(server : Server) : Void

  fun server_disconnect = "dbus_server_disconnect"(server : Server) : Void

  fun server_get_is_connected = "dbus_server_get_is_connected"(server : Server) : BoolT

  fun server_get_address = "dbus_server_get_address"(server : Server) : UInt8*

  fun server_get_id = "dbus_server_get_id"(server : Server) : UInt8*

  fun server_set_new_connection_function = "dbus_server_set_new_connection_function"(server : Server, function : NewConnectionFunction, data : Void*, free_data_function : FreeFunction) : Void

  fun server_set_watch_functions = "dbus_server_set_watch_functions"(server : Server, add_function : AddWatchFunction, remove_function : RemoveWatchFunction, toggled_function : WatchToggledFunction, data : Void*, free_data_function : FreeFunction) : BoolT

  fun server_set_timeout_functions = "dbus_server_set_timeout_functions"(server : Server, add_function : AddTimeoutFunction, remove_function : RemoveTimeoutFunction, toggled_function : TimeoutToggledFunction, data : Void*, free_data_function : FreeFunction) : BoolT

  fun server_set_auth_mechanisms = "dbus_server_set_auth_mechanisms"(server : Server, mechanisms : UInt8**) : BoolT

  fun server_allocate_data_slot = "dbus_server_allocate_data_slot"(slot_p : Int32*) : BoolT

  fun server_free_data_slot = "dbus_server_free_data_slot"(slot_p : Int32*) : Void

  fun server_set_data = "dbus_server_set_data"(server : Server, slot : Int32, data : Void*, free_data_func : FreeFunction) : BoolT

  fun server_get_data = "dbus_server_get_data"(server : Server, slot : Int32) : Void*

  struct SignatureIter
    dummy1 : Void*
    dummy2 : Void*
    dummy8 : UInt32
    dummy12 : Int32
    dummy17 : Int32
  end

  fun signature_iter_init = "dbus_signature_iter_init"(iter : SignatureIter*, signature : UInt8*) : Void

  fun signature_iter_get_current_type = "dbus_signature_iter_get_current_type"(iter : SignatureIter*) : Int32

  fun signature_iter_get_signature = "dbus_signature_iter_get_signature"(iter : SignatureIter*) : UInt8*

  fun signature_iter_get_element_type = "dbus_signature_iter_get_element_type"(iter : SignatureIter*) : Int32

  fun signature_iter_next = "dbus_signature_iter_next"(iter : SignatureIter*) : BoolT

  fun signature_iter_recurse = "dbus_signature_iter_recurse"(iter : SignatureIter*, subiter : SignatureIter*) : Void

  fun signature_validate = "dbus_signature_validate"(signature : UInt8*, error : Error*) : BoolT

  fun signature_validate_single = "dbus_signature_validate_single"(signature : UInt8*, error : Error*) : BoolT

  fun type_is_valid = "dbus_type_is_valid"(typecode : Int32) : BoolT

  fun type_is_basic = "dbus_type_is_basic"(typecode : Int32) : BoolT

  fun type_is_container = "dbus_type_is_container"(typecode : Int32) : BoolT

  fun type_is_fixed = "dbus_type_is_fixed"(typecode : Int32) : BoolT

  fun validate_path = "dbus_validate_path"(path : UInt8*, error : Error*) : BoolT

  fun validate_interface = "dbus_validate_interface"(name : UInt8*, error : Error*) : BoolT

  fun validate_member = "dbus_validate_member"(name : UInt8*, error : Error*) : BoolT

  fun validate_error_name = "dbus_validate_error_name"(name : UInt8*, error : Error*) : BoolT

  fun validate_bus_name = "dbus_validate_bus_name"(name : UInt8*, error : Error*) : BoolT

  fun validate_utf8 = "dbus_validate_utf8"(alleged_utf8 : UInt8*, error : Error*) : BoolT

  type Mutex = Void*

  type CondVar = Void*

  alias MutexNewFunction = -> Mutex

  alias MutexFreeFunction = Mutex -> Void

  alias MutexLockFunction = Mutex -> BoolT

  alias MutexUnlockFunction = Mutex -> BoolT

  alias RecursiveMutexNewFunction = -> Mutex

  alias RecursiveMutexFreeFunction = Mutex -> Void

  alias RecursiveMutexLockFunction = Mutex -> Void

  alias RecursiveMutexUnlockFunction = Mutex -> Void

  alias CondVarNewFunction = -> CondVar

  alias CondVarFreeFunction = CondVar -> Void

  alias CondVarWaitFunction = (CondVar, Mutex) -> Void

  alias CondVarWaitTimeoutFunction = (CondVar, Mutex, Int32) -> BoolT

  alias CondVarWakeOneFunction = CondVar -> Void

  alias CondVarWakeAllFunction = CondVar -> Void

  @[Flags]
  enum ThreadFunctionsMask
    MUTEX_NEW_MASK              = 1 << 0
    MUTEX_FREE_MASK             = 1 << 1
    MUTEX_LOCK_MASK             = 1 << 2
    MUTEX_UNLOCK_MASK           = 1 << 3
    CONDVAR_NEW_MASK            = 1 << 4
    CONDVAR_FREE_MASK           = 1 << 5
    CONDVAR_WAIT_MASK           = 1 << 6
    CONDVAR_WAIT_TIMEOUT_MASK   = 1 << 7
    CONDVAR_WAKE_ONE_MASK       = 1 << 8
    CONDVAR_WAKE_ALL_MASK       = 1 << 9
    RECURSIVE_MUTEX_NEW_MASK    = 1 << 10
    RECURSIVE_MUTEX_FREE_MASK   = 1 << 11
    RECURSIVE_MUTEX_LOCK_MASK   = 1 << 12
    RECURSIVE_MUTEX_UNLOCK_MASK = 1 << 13
    ALL_MASK                    = (1 << 14) - 1
  end
  THREAD_FUNCTIONS_MUTEX_NEW_MASK              = ThreadFunctionsMask::MUTEX_NEW_MASK
  THREAD_FUNCTIONS_MUTEX_FREE_MASK             = ThreadFunctionsMask::MUTEX_FREE_MASK
  THREAD_FUNCTIONS_MUTEX_LOCK_MASK             = ThreadFunctionsMask::MUTEX_LOCK_MASK
  THREAD_FUNCTIONS_MUTEX_UNLOCK_MASK           = ThreadFunctionsMask::MUTEX_UNLOCK_MASK
  THREAD_FUNCTIONS_CONDVAR_NEW_MASK            = ThreadFunctionsMask::CONDVAR_NEW_MASK
  THREAD_FUNCTIONS_CONDVAR_FREE_MASK           = ThreadFunctionsMask::CONDVAR_FREE_MASK
  THREAD_FUNCTIONS_CONDVAR_WAIT_MASK           = ThreadFunctionsMask::CONDVAR_WAIT_MASK
  THREAD_FUNCTIONS_CONDVAR_WAIT_TIMEOUT_MASK   = ThreadFunctionsMask::CONDVAR_WAIT_TIMEOUT_MASK
  THREAD_FUNCTIONS_CONDVAR_WAKE_ONE_MASK       = ThreadFunctionsMask::CONDVAR_WAKE_ONE_MASK
  THREAD_FUNCTIONS_CONDVAR_WAKE_ALL_MASK       = ThreadFunctionsMask::CONDVAR_WAKE_ALL_MASK
  THREAD_FUNCTIONS_RECURSIVE_MUTEX_NEW_MASK    = ThreadFunctionsMask::RECURSIVE_MUTEX_NEW_MASK
  THREAD_FUNCTIONS_RECURSIVE_MUTEX_FREE_MASK   = ThreadFunctionsMask::RECURSIVE_MUTEX_FREE_MASK
  THREAD_FUNCTIONS_RECURSIVE_MUTEX_LOCK_MASK   = ThreadFunctionsMask::RECURSIVE_MUTEX_LOCK_MASK
  THREAD_FUNCTIONS_RECURSIVE_MUTEX_UNLOCK_MASK = ThreadFunctionsMask::RECURSIVE_MUTEX_UNLOCK_MASK
  THREAD_FUNCTIONS_ALL_MASK                    = ThreadFunctionsMask::ALL_MASK

  struct ThreadFunctions
    mask : UInt32
    mutex_new : MutexNewFunction
    mutex_free : MutexFreeFunction
    mutex_lock : MutexLockFunction
    mutex_unlock : MutexUnlockFunction
    condvar_new : CondVarNewFunction
    condvar_free : CondVarFreeFunction
    condvar_wait : CondVarWaitFunction
    condvar_wait_timeout : CondVarWaitTimeoutFunction
    condvar_wake_one : CondVarWakeOneFunction
    condvar_wake_all : CondVarWakeAllFunction
    recursive_mutex_new : RecursiveMutexNewFunction
    recursive_mutex_free : RecursiveMutexFreeFunction
    recursive_mutex_lock : RecursiveMutexLockFunction
    recursive_mutex_unlock : RecursiveMutexUnlockFunction
    padding1 : -> Void
    padding2 : -> Void
    padding3 : -> Void
    padding4 : -> Void
  end

  fun threads_init = "dbus_threads_init"(functions : ThreadFunctions*) : BoolT

  fun threads_init_default = "dbus_threads_init_default" : BoolT
end
