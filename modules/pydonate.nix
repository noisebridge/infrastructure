# pydonate — Python donation app (Stripe integration).
# Translated from roles/pydonate/ and group_vars/m5_noisebridge_net/.
{ config, pkgs, lib, ... }:
let
  pydonatePort = 8888;

  # The pydonate source — pin to the commit from Ansible config
  pydonateSrc = pkgs.fetchFromGitHub {
    owner = "noisebridge";
    repo = "python-nb-donate";
    rev = "aa87fa9ece9d2a0f66a5fe03e852a95cb2cb1450";
    # TODO: replace with actual hash after first build
    hash = lib.fakeHash;
  };

  # Python environment with pydonate and its dependencies
  pythonEnv = pkgs.python3.withPackages (ps: [
    ps.flask
    ps.gunicorn
    ps.mysqlclient
    ps.stripe
    ps.python-dotenv
  ]);
in
{
  age.secrets = {
    stripe-keys = {
      file = ../secrets/stripe-keys.age;
      owner = "pydonate";
    };
    mysql-pydonate = {
      file = ../secrets/mysql-pydonate.age;
      owner = "pydonate";
    };
  };

  users.users.pydonate = {
    isSystemUser = true;
    group = "pydonate";
    home = "/var/lib/pydonate";
    createHome = true;
  };
  users.groups.pydonate = {};

  # Systemd service for pydonate
  systemd.services.pydonate = {
    description = "Noisebridge Donation App (pydonate)";
    after = [ "network.target" "mysql.service" ];
    requires = [ "mysql.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = "pydonate";
      Group = "pydonate";
      WorkingDirectory = "/var/lib/pydonate";
      ExecStart = "${pythonEnv}/bin/flask run --host 127.0.0.1 --port ${toString pydonatePort}";
      Restart = "on-failure";
      RestartSec = "5s";

      # Environment file for secrets — assembled at activation
      EnvironmentFile = "/run/agenix/pydonate-env";

      # Hardening
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = [ "/var/lib/pydonate" ];
      PrivateTmp = true;
    };

    environment = {
      FLASK_APP = "${pydonateSrc}/autoapp.py";
      FLASK_ENV = "PRODUCTION";
      FLASK_DEBUG = "0";
      FLASK_RUN_PORT = toString pydonatePort;
      DB_USER = "donate";
      DB_HOST = "localhost";
      DB_SOCK = "/run/mysqld/mysqld.sock";
      DB_PROD_NAME = "donate_prod";
      DB_TEST_NAME = "donate_test";
    };
  };

  # Assemble the pydonate environment file from agenix secrets at activation.
  # stripe-keys.age should contain lines like:
  #   STRIPE_KEY=sk_live_...
  #   STRIPE_SECRET=...
  #   DONATE_PRODUCT=...
  #   DONATE_SECRET=...
  # mysql-pydonate.age should contain the raw password.
  system.activationScripts.pydonate-env = lib.stringAfter [ "agenix" ] ''
    install -m 0400 -o pydonate -g pydonate /dev/null /run/agenix/pydonate-env
    {
      cat ${config.age.secrets.stripe-keys.path}
      echo "DB_PASS=$(cat ${config.age.secrets.mysql-pydonate.path})"
      echo 'PROD_DATABASE_URI=mysql+mysqldb://donate:$(cat ${config.age.secrets.mysql-pydonate.path})@localhost/donate_prod?unix_socket=/run/mysqld/mysqld.sock'
    } > /run/agenix/pydonate-env
    chown pydonate:pydonate /run/agenix/pydonate-env
    chmod 0400 /run/agenix/pydonate-env
  '';
}
