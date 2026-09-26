{  ... }:

{
  users.users."daniel".openssh.authorizedKeys.keys = [
    # hermes-agent-laptop (J.A.R.V.I.S.)
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGC5gYdLzF4jUwLYega58MkYMTPVatL0oZGvCWgJB/Ip hermes-agent-laptop"
  ];

  # Only allow SSH from the Hermes agent's source IP on the 50-network
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 22 -s 10.0.50.20 -j ACCEPT
  '';
}
