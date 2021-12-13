hostname ${hostname}
!
enable password ${enable_password}
!
interface GigabitEthernet0/0
 description "Inside network peering"
 nameif inside
 security-level 20
 ip address ${inside_interface_ip_address} ${cidrnetmask(inside_subnetwork_cidr)}
!
interface GigabitEthernet0/1
 description "Outside network"
 nameif outside
 security-level 0
 ip address ${outside_interface_ip_address} ${cidrnetmask(outside_subnetwork_cidr)}
!
interface Management0/0
 management-only
 nameif management
 security-level 100
 ip address dhcp setroute
!
!
banner motd +--------------------------------------------------------------------------+
banner motd |                 *   WARNING NOTICE TO USERS   *                          |
banner motd | It is for authorized  users only.  Unauthorized users  are prohibited.   |
banner motd +--------------------------------------------------------------------------+
!
dns domain-lookup outside
dns server-group DefaultDNS
 name-server 8.8.8.8
 name-server 8.8.4.4
!
same-security-traffic permit inter-interface
same-security-traffic permit intra-interface
!
route outside 0.0.0.0 0.0.0.0 ${cidrhost(outside_subnetwork_cidr, 1)} 1
!
! Required for SSH and HTTP authentication for the API connections
aaa authentication ssh console LOCAL
aaa authentication http console LOCAL
aaa authorization command LOCAL
aaa local authentication attempts max-fail 10
aaa authorization exec LOCAL auto-enable
!
! Required for ASDM and the API connections
http server enable
http 0 0 management
!
! required for SSH
crypto key generate rsa modulus 2048
!
!
ssh timeout 60
ssh version 2
ssh 0 0 management
console timeout 0
!
username ${admin_username} password ${admin_password} privilege 15
username ${admin_username} attributes
 service-type admin
!
!
no call-home reporting anonymous
!
!END
