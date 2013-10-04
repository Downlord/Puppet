#!/usr/bin/env ruby
require 'facter'
require 'facter/util/ip'

def has_address(interface)
  ip = Facter::Util::IP.get_interface_value(interface, 'ipaddress')
  if ip.nil?
    false
  else
    true
  end
end

def is_private(interface)
  rfc1918 = Regexp.new('^10\.|^172\.(?:1[6-9]|2[0-9]|3[0-1])\.|^192\.168\.')
  ip = Facter::Util::IP.get_interface_value(interface, 'ipaddress')
  if rfc1918.match(ip)
    true
  else
    false
  end
end

def find_networks
  found_public = found_private = false
  Facter::Util::IP.get_interfaces.each do |interface|
    if has_address(interface)
      if is_private(interface)
        found_private = true
      else
        found_public = true
      end
    end
  end
  [found_public, found_private]
end

# these facts check if any interface is on a public or private network
# they return the string true or false
# this fact will always be present

Facter.add(:on_public) do
  confine :kernel => Facter::Util::IP.supported_platforms
  setcode do
    found_public, found_private = find_networks
    found_public
  end
end

Facter.add(:on_private) do
  confine :kernel => Facter::Util::IP.supported_platforms
  setcode do
    found_public, found_private = find_networks
    found_private
  end
end

# these facts return the first public or private ip address found
# when iterating over the interfaces in alphabetical order
# if no matching address is found the fact won't be present

Facter.add(:ipaddress_public) do
  confine :kernel => Facter::Util::IP.supported_platforms
  setcode do
    ip=""
    Facter::Util::IP.get_interfaces.each do |interface|
      if has_address(interface)
        if not is_private(interface)
          ip = Facter::Util::IP.get_interface_value(interface, 'ipaddress')
          break
        end
      end
    end
    ip
  end
end

Facter.add(:ipaddress_private) do
  confine :kernel => Facter::Util::IP.supported_platforms
  setcode do
    ip=""
    Facter::Util::IP.get_interfaces.each do |interface|
      if has_address(interface)
        if is_private(interface)
          ip = Facter::Util::IP.get_interface_value(interface, 'ipaddress')
          break
        end
      end
    end
    ip
  end
end
#
# httpd.rb - facter to show apache version
#

if Facter.value(:ipaddress_eth0) =~ /^10.*/
  aifa=Facter.value(:ipaddress_eth0)
  aifn="eth0"
elsif Facter.value(:ipaddress_eth1) =~ /^10.*/
  aifa=Facter.value(:ipaddress_eth1)
  aifn="eth1"
elsif Facter.value(:ipaddress_eth2) =~ /^10.*/
  aifa=Facter.value(:ipaddress_eth2)
  aifn="eth2"
elsif Facter.value(:ipaddress_eth3) =~ /^10.*/
  aifa=Facter.value(:ipaddress_eth3)
  aifn="eth3"
elsif Facter.value(:ipaddress_eth4) =~ /^10.*/
  aifa=Facter.value(:ipaddress_eth4)
  aifn="eth4"
elsif Facter.value(:ipaddress_eth5) =~ /^10.*/
  aifa=Facter.value(:ipaddress_eth5)
  aifn="eth5"
elsif Facter.value(:ipaddress_eth6) =~ /^10.*/
  aifa=Facter.value(:ipaddress_eth6)
  aifn="eth6"
elsif Facter.value(:ipaddress_eth7) =~ /^10.*/
  aifa=Facter.value(:ipaddress_eth7)
  aifn="eth7"
elsif Facter.value(:ipaddress_eth8) =~ /^10.*/
  aifa=Facter.value(:ipaddress_eth8)
  aifn="eth8"
elsif Facter.value(:ipaddress_eth9) =~ /^10.*/
  aifa=Facter.value(:ipaddress_eth9)
  aifn="eth9"
end

Facter.add("interface_admin_ip") do
  setcode do
    aifa
  end
end

Facter.add("interface_admin") do
  setcode do
    aifn
  end
end

if Facter.value(:ipaddress_eth0) =~ /^193.*/
  pifa=Facter.value(:ipaddress_eth0)
  pifn="eth0"
elsif Facter.value(:ipaddress_eth1) =~ /^193.*/
  pifa=Facter.value(:ipaddress_eth1)
  pifn="eth1"
elsif Facter.value(:ipaddress_eth2) =~ /^193.*/
  pifa=Facter.value(:ipaddress_eth2)
  pifn="eth2"
elsif Facter.value(:ipaddress_eth3) =~ /^193.*/
  pifa=Facter.value(:ipaddress_eth3)
  pifn="eth3"
elsif Facter.value(:ipaddress_eth4) =~ /^193.*/
  pifa=Facter.value(:ipaddress_eth4)
  pifn="eth4"
elsif Facter.value(:ipaddress_eth5) =~ /^193.*/
  pifa=Facter.value(:ipaddress_eth5)
  pifn="eth5"
elsif Facter.value(:ipaddress_eth6) =~ /^193.*/
  pifa=Facter.value(:ipaddress_eth6)
  pifn="eth6"
elsif Facter.value(:ipaddress_eth7) =~ /^193.*/
  pifa=Facter.value(:ipaddress_eth7)
  pifn="eth7"
elsif Facter.value(:ipaddress_eth8) =~ /^193.*/
  pifa=Facter.value(:ipaddress_eth8)
  pifn="eth8"
elsif Facter.value(:ipaddress_eth9) =~ /^193.*/
  pifa=Facter.value(:ipaddress_eth9)
  pifn="eth9"
end

Facter.add("interface_public_ip") do
  setcode do
    pifa
  end
end

Facter.add("interface_public") do
  setcode do
    pifn
  end
end

ip=''
port=''
name=''
apache_output=''
myurl=''

apache_runtime=Facter::Util::Resolution.exec("ps x | grep -v grep | egrep '/usr/sbin/(httpd2-prefork|apache|apache2)' |awk '{ print $5;exit}'")
if apache_runtime
  Facter.add("apache_active") do
    setcode do
      apache_runtime.chomp
    end
  end
  apache_version=Facter::Util::Resolution.exec("#{apache_runtime} -v|awk '{print $3;exit}'")
  if apache_version
    Facter.add("apache_version") do
    setcode do
      apache_version.chomp
    end
  end
  ipp=''
  apache_output=Facter::Util::Resolution.exec("#{apache_runtime} -S 2>&1")
  if apache_output
    ipp=pifa
    apache_output.chomp.split("\n").each_with_index do |line,idx|

    if line =~ /.*is a NameVirtualHost.*/
      ipport=line.split(' ')[0]
      if ipport != ""
        ipp=ipport.split(':')[0]
        pport=ipport.split(':')[1]

        ssl=''
        if pport == "443"
          ssl=443
        end

        if ipp =~ /\*/
          ipp=pifa
        end

        if ipp != "" and pport != ""
          Facter.add("apache_host_url") do
            setcode do
              "http://"+ipp+":"+pport+"/"
            end
          end
          Facter.add("apache_host_ip") do
            setcode do
              ipp
            end
          end
          Facter.add("apache_host_port") do
            setcode do
              ipport.split(':')[1]
            end
          end
        end

      end #if ipport != ""
    end # line =~ /.* is a NameVirtualHost.*/

    if line =~ /.*default server.*/
      ip=line.split(' ')[2]
      if ip != ""

        Facter.add("apache_host_name") do
          setcode do
            line.split(' ')[2]
          end
        end
      end
    end # if line =~ /.*default server.*/

    ip=''
    port=''
    name=''
    #ip = line.split(' ')[0].split(':')[0]
    #port = line.split(' ')[0].split(':')[1]
    #name = line.split(' ')[1]
    #print "ip = "+ip+"\n"
    #print "port = "+port+"\n"
    #print "name = "+name+"\n"
    #print "url = "+url+"\n"

    if(ip != "" and port != "" and name != "is")
      url = "http://" + ip + ":" + port + "/"
      Facter.add("apache_vhost_#{idx}_name") do
        setcode do
          name
        end
      end
      Facter.add("apache_vhost_#{idx}_port") do
        setcode do
          port
        end
      end
      Facter.add("apache_vhost_#{idx}_ip") do
        setcode do
          ip
        end
      end
      Facter.add("apache_vhost_#{idx}_url") do
        setcode do
          url
        end
      end
    end
      end
    end
  end

ipport=`lsof -P -iTCP -a -c '/(apache|http)/i' |grep LISTEN|sort -k9 -r|awk '/\*/{ print $(NF-1);exit}'`
if ipport
    ip=ipport.chomp.split(':')[0]
    port=ipport.chomp.split(':')[1]
    if ip != "" and port != ""

      if ip == '*'
        iip=pifa
      else
        iip=ip
      end

      if iip != '' && iip != nil && port != '' && port != nil
        myurl='http://'+iip+':'+port+'/'
      elsif iip != '' && iip != nil
        myurl='http://'+iip+'/'
      else
        hostname=`hostname -f`
        iip=pifa
        port='80'
        myurl='http://'+iip+':'+port+'/'
      end


      Facter.add("apache_host_url") do
        setcode do
          myurl
        end
      end
      Facter.add("apache_host_port") do
        setcode do
          port
        end
      end

      Facter.add("apache_host_ip") do
        setcode do
          iip
        end
      end

    end
end

maxclients=`awk '($1=="MaxClients"){print $2;exit}' /etc/apache2/server-tuning.conf`
if maxclients
   Facter.add("apache_max_clients") do
        setcode do
          maxclients.chomp
        end
      end
end
end # if apache_runtime
