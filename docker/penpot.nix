{ config, pkgs, ... }:

let
  penpotDataDir = "/var/lib/penpot";
  penpotFlags = "disable-email-verification disable-secure-session-cookies enable-login-with-password enable-mcp enable-registration enable-smtp";
  penpotPostgresPassword = "penpot";
  penpotSecretKey = "change-this-insecure-key";
  penpotVersion = "2.15";
  penpotServices = [
    "penpot-backend"
    "penpot-exporter"
    "penpot-frontend"
    "penpot-mailcatch"
    "penpot-mcp"
    "penpot-postgres"
    "penpot-valkey"
  ];
in
{
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "penpot";
      runtimeInputs = [
        pkgs.sudo
        pkgs.systemd
      ];
      text = ''
        if [[ "$EUID" -eq 0 ]]; then
          systemctl_cmd=(systemctl)
        else
          systemctl_cmd=(sudo systemctl)
        fi

        "''${systemctl_cmd[@]}" start \
          docker-network-penpot.service \
          docker-penpot-postgres.service \
          docker-penpot-valkey.service \
          docker-penpot-backend.service \
          docker-penpot-mcp.service \
          docker-penpot-exporter.service \
          docker-penpot-frontend.service \
          docker-penpot-mailcatch.service

        echo "Penpot is starting: http://localhost:9001"
        echo "Mailcatcher: http://localhost:9002"
      '';
    })
  ];

  systemd.tmpfiles.rules = [
    "d ${penpotDataDir} 0750 root root - -"
    "d ${penpotDataDir}/assets 0750 root root - -"
  ];

  systemd.services =
    {
      docker-network-penpot = {
        description = "Create the Penpot Docker network";
        after = [ "docker.service" ];
        before = map (name: "docker-${name}.service") penpotServices;
        requires = [ "docker.service" ];
        wantedBy = [ "multi-user.target" ];
        path = [ config.virtualisation.docker.package ];
        script = ''
          docker network inspect penpot >/dev/null 2>&1 || docker network create penpot
        '';
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
    }
    // builtins.listToAttrs (
      map (name: {
        name = "docker-${name}";
        value = {
          after = [ "docker-network-penpot.service" ];
          requires = [ "docker-network-penpot.service" ];
        };
      }) penpotServices
    );

  virtualisation.oci-containers.containers = {
    penpot-postgres = {
      autoStart = false;
      image = "postgres:15";
      environment = {
        POSTGRES_INITDB_ARGS = "--data-checksums";
        POSTGRES_DB = "penpot";
        POSTGRES_USER = "penpot";
        POSTGRES_PASSWORD = penpotPostgresPassword;
      };
      networks = [ "penpot" ];
      volumes = [
        "penpot_postgres_v15:/var/lib/postgresql/data"
      ];
    };

    penpot-valkey = {
      autoStart = false;
      image = "valkey/valkey:8.1";
      environment = {
        VALKEY_EXTRA_FLAGS = "--maxmemory 128mb --maxmemory-policy volatile-lfu";
      };
      networks = [ "penpot" ];
    };

    penpot-backend = {
      autoStart = false;
      image = "penpotapp/backend:${penpotVersion}";
      dependsOn = [
        "penpot-postgres"
        "penpot-valkey"
      ];
      environment = {
        PENPOT_FLAGS = penpotFlags;
        PENPOT_PUBLIC_URI = "http://localhost:9001";
        PENPOT_SECRET_KEY = penpotSecretKey;
        PENPOT_DATABASE_URI = "postgresql://penpot-postgres/penpot";
        PENPOT_DATABASE_USERNAME = "penpot";
        PENPOT_DATABASE_PASSWORD = penpotPostgresPassword;
        PENPOT_REDIS_URI = "redis://penpot-valkey/0";
        PENPOT_OBJECTS_STORAGE_BACKEND = "fs";
        PENPOT_OBJECTS_STORAGE_FS_DIRECTORY = "/opt/data/assets";
        PENPOT_SMTP_DEFAULT_FROM = "no-reply@example.com";
        PENPOT_SMTP_DEFAULT_REPLY_TO = "no-reply@example.com";
        PENPOT_SMTP_HOST = "penpot-mailcatch";
        PENPOT_SMTP_PORT = "1025";
        PENPOT_SMTP_SSL = "false";
        PENPOT_SMTP_TLS = "false";
        PENPOT_TELEMETRY_ENABLED = "true";
        PENPOT_TELEMETRY_REFERER = "nixos";
      };
      networks = [ "penpot" ];
      volumes = [
        "${penpotDataDir}/assets:/opt/data/assets"
      ];
    };

    penpot-mcp = {
      autoStart = false;
      image = "penpotapp/mcp:${penpotVersion}";
      networks = [ "penpot" ];
    };

    penpot-exporter = {
      autoStart = false;
      image = "penpotapp/exporter:${penpotVersion}";
      dependsOn = [
        "penpot-valkey"
      ];
      environment = {
        PENPOT_PUBLIC_URI = "http://penpot-frontend:8080";
        PENPOT_REDIS_URI = "redis://penpot-valkey/0";
        PENPOT_SECRET_KEY = penpotSecretKey;
      };
      networks = [ "penpot" ];
    };

    penpot-frontend = {
      autoStart = false;
      image = "penpotapp/frontend:${penpotVersion}";
      dependsOn = [
        "penpot-backend"
        "penpot-exporter"
        "penpot-mcp"
      ];
      ports = [
        "127.0.0.1:9001:8080"
      ];
      environment = {
        PENPOT_FLAGS = penpotFlags;
        PENPOT_PUBLIC_URI = "http://localhost:9001";
      };
      networks = [ "penpot" ];
      volumes = [
        "${penpotDataDir}/assets:/opt/data/assets"
      ];
    };

    penpot-mailcatch = {
      autoStart = false;
      image = "sj26/mailcatcher:latest";
      ports = [
        "127.0.0.1:9002:1080"
      ];
      networks = [ "penpot" ];
    };
  };
}
