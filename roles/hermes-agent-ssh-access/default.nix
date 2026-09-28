{ username, ... }:

{
  users.users.${username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGC5gYdLzF4jUwLYega58MkYMTPVatL0oZGvCWgJB/Ip hermes-agent-laptop"
  ];

  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 22 -s 10.0.50.20 -j ACCEPT
  '';
}
