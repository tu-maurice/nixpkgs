{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.fishnet;
in
{

  ###### interface

  meta.maintainers = with maintainers; [ tu-maurice ];

  options = {

    services.fishnet = {

      enable = mkEnableOption "Fishnet service";

      key = mkOption {
        type = types.str;
        default = null;
        description = ''
          Personal fishnet key. Can be requested through https://lichess.org/get-fishnet
        '';
      };

      keep_idle = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Set to true if you only want your client to join the computation when a backlog builds up.
          Set to false if you want your client to always compute.
        '';
      };

      cores = mkOption {
        type = with types; nullOr str;
        default = null;
        description = ''
          How many cores to use. null (default) means automatic selection of number of cores.
        '';
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Extra configuration for fishnet.ini
        '';
      };

      package = mkOption {
        type = types.package;
        default = pkgs.fishnet;
        defaultText = "pkgs.fishnet";
        description = ''
          The package to use for the fishnet binary.
        '';
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    # use a static uid as default to ensure it is the same on all nodes
    users.users.fishnet = {
      name = "fishnet";
      group = "nobody";
    };

    systemd.services.fishnet = let
      configFile = pkgs.writeText "fishnet.ini"
        ''
          [fishnet]
          key=${cfg.key}
          cores=${if isNull cfg.cores then "auto" else cfg.cores}
          systembacklog=${if cfg.keep_idle then "long" else "0"}
          userbacklog=${if cfg.keep_idle then "short" else "0"}
          ${cfg.extraConfig}
        '';
    in
      {
        wantedBy = [ "network-online.target" ];
        after = [ "network-online.target" ];

        # From fishnet systemd command
        serviceConfig = {
          KillMode = "mixed";
          ExecStart = "${cfg.package}/bin/fishnet --conf ${configFile} run";
          Nice = 5;
          WorkingDirectory = "/tmp";
          User = "fishnet";
          PrivateTmp = true;
          PrivateDevices = true;
          DevicePolicy = "closed";
          ProtectSystem = "full";
          NoNewPriviliges = true;
          Restart = "on-failure";
        };
      };
  };
}
