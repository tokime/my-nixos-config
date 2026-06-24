{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    numad
    numactl
  ];

  systemd.services.numad = {
    description = "NUMA alignment daemon";

    after = [ "syslog.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "forking";
      ExecStart = "${pkgs.numad}/bin/numad-wrapper start";
      ExecStop = "${pkgs.numad}/bin/numad-wrapper stop";
      PIDFile = "/run/numad.pid";
      Restart = "on-failure";
    };
  };
}
