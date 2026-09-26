{  ... }:

{
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 22 -s 10.0.10.16 -j ACCEPT
  '';
}
