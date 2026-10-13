{ username, ... }:

{
  users.users.${username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJjzcieQ64SuEq6swAfKlt540QKNJs6wNIcmOEEs0Uya daniel@nixos"
  ];

  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 22 -s 10.0.10.16 -j ACCEPT
  '';
}
