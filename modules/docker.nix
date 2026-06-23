{ pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  virtualisation.oci-containers.backend = "docker";

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
