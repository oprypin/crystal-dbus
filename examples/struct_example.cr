require "dbus"

#Demostrates reading a Struct Type into an Array(DBus::Type)

bus = DBus::Bus.new(DBus::BusType::SYSTEM)
ofono_dest = bus.destination("org.ofono")
manager_obj = ofono_dest.object("/")
manager_int = manager_obj.interface("org.ofono.Manager")
pend = manager_int.call("GetModems")
reply = pend.reply

if reply.size > 0
  modems = reply[0].as(Array(DBus::Type))
  if modems.size > 0
    count = modems.size
    puts "#{modems.size} Modems available"
    count.times do | i | 
      modem = modems[i].as(Array(DBus::Type))
      puts "#{i+1} - Object Path\t: #{modem[0].inspect}"
      puts "Properties\t: #{modem[1].inspect}"
      puts ""
    end
  else
    puts "No Modems"
  end
end

