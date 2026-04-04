{ self, ... }:
{
  flake.homeModules.scripts-local = { config, lib, pkgs, ... }:
    let
      cfg = config.localScripts;

      mkScriptPackage = scriptPath:
        let
          resolvedPath =
            if builtins.isPath scriptPath then scriptPath else (self + "/${scriptPath}");
          scriptName = builtins.baseNameOf (toString resolvedPath);
          scriptText = builtins.readFile resolvedPath;
        in
        pkgs.writeShellApplication {
          name = scriptName;
          text = scriptText;
        };
    in
    {
      options.localScripts.paths = lib.mkOption {
        type = lib.types.listOf (lib.types.oneOf [ lib.types.path lib.types.str ]);
        default = [ ];
        example = [ "modules/scripts/utilities/ssh-config" ];
        description = "List of repo script paths that should be exposed as commands in PATH.";
      };

      config.home.packages = map mkScriptPackage cfg.paths;
    };
}
