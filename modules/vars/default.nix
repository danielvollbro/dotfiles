{ lib, ... }:
with lib;
{
  options.vars = {
    sshKeys = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Named SSH public keys, single source of truth";
    };

    hosts = mkOption {
      type = types.attrsOf (types.submodule {
        options.ip = mkOption {
          type = types.str;
        };
      });
    };
  };

  config.vars = {
    sshKeys = {
      hermes-agent  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGC5gYdLzF4jUwLYega58MkYMTPVatL0oZGvCWgJB/Ip hermes-agent";
      daniel-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKwN98v7Gvrmw8uh6L5HAOVOcDcLffdRBmWLgHDP2chj daniel@daniel-laptop";
    };

    hosts = {
      gaming-pc.ip      = "10.0.10.140";
      laptop.ip         = "10.0.10.16";
      docker-debian.ip  = "10.0.50.50";
    };
  };
}
