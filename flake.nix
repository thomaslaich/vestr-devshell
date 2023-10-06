{
  description = "A dev shell to develop on the vestr project";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, flake-utils, devshell, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;

          config = {
            permittedInsecurePackages = ["nodejs-16.20.2"];
          };

          overlays = [ devshell.overlays.default ];
        };

        node = pkgs.nodejs_16;

        devShell = pkgs.devshell.mkShell {
          name = "vestr-devshell";
          commands = [{ package = node; }];

          packages = [ pkgs.nodePackages.node-gyp ];

          env = let
            local-docker-host = "127.0.0.1";
            local-dev-ip = "localhost";
          in [
            {
              name = "LOG_LEVEL";
              value = "DEBUG";
            }
            {
              name = "LOCAL_DOCKER_HOST_IP";
              value = local-docker-host;
            }
            {
              name = "RABBITMQ_HOST";
              value = "${local-docker-host}:5672";
            }
            {
              name = "MONGODB_HOST";
              value = "${local-docker-host}:27017";
            }
            {
              name = "ELASTICSEARCH_URI";
              value = "${local-docker-host}:9200";
            }
            {
              name = "LOCAL_DEV_IP";
              value = local-dev-ip;
            }
            {
              name = "API_URL";
              value = "${local-dev-ip}:3000";
            }
            {
              name = "EXTERNAL_API_URL";
              value = "${local-dev-ip}:3011";
            }
            {
              name = "DATA_SERVER_URL";
              value = "${local-dev-ip}:3010";
            }
            {
              name = "MEDIA_SERVER_URL";
              value = "${local-dev-ip}:3012";
            }
          ];
        };

      in { devShells.default = devShell; });
}
