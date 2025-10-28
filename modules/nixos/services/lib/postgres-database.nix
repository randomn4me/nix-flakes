{ lib, ... }:

with lib;

{
  # Helper function to ensure a PostgreSQL database and user exist
  mkPostgresDatabase = {
    database,
    user,
    ensureDBOwnership ? true,
  }: {
    ensureDatabases = [ database ];
    ensureUsers = [
      {
        name = user;
        inherit ensureDBOwnership;
      }
    ];
  };
}
