! The following is a sample ASA configuration file for reference only.

hostname ${hostname}
enable password ${enable_password}
!
ip local pool VPN_POOL1 ${vpn_ip_pool_start}-${vpn_ip_pool_end} mask ${vpn_pool_netmask}
!
interface GigabitEthernet0/0
 description "Inside network to GCP"
 nameif inside
 security-level 20
 ip address dhcp
!
interface GigabitEthernet0/1
 description "Outside network to Internet"
 nameif outside
 security-level 0
 ip address dhcp
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
access-list GCP_ACL_Split_Tunnel_List standard permit ${split("/", gcp_private_supernet_cidr)[0]} ${cidrnetmask(gcp_private_supernet_cidr)}
!
route outside 0.0.0.0 0.0.0.0 ${cidrhost(outside_subnetwork_cidr, 1)}
route inside ${split("/", gcp_private_supernet_cidr)[0]} ${cidrnetmask(gcp_private_supernet_cidr)} ${cidrhost(inside_subnetwork_cidr, 1)}
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
ssh scopy enable
ssh timeout 60
ssh version 2
ssh 0 0 management
console timeout 0
!
no call-home reporting anonymous
!
username ${admin_username} password ${admin_password} privilege 15
%{ if ssh_key != "" }
username ${admin_username} attributes
  ssh authentication publickey ${ssh_key}
  service-type admin
%{ endif }
!
group-policy DfltGrpPolicy attributes
 dns-server value 8.8.8.8
 vpn-tunnel-protocol ikev2 ssl-client
 split-tunnel-policy tunnelspecified
 split-tunnel-network-list value GCP_ACL_Split_Tunnel_List
 address-pools value VPN_POOL1
!
license smart
    feature tier standard
    throughput level ${throughput_level}

%{ if smart_account_registration_token != "" }
license smart register idtoken ${smart_account_registration_token}
%{ endif }
!
!
webvpn
 enable outside
 anyconnect enable
 tunnel-group-list enable
!
!
!END
