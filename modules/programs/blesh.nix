{ config, lib, pkgs, ... }:

with lib;

let cfg = config.programs.blesh;
in {
  meta.maintainers = [ maintainers.aiotter ];

  options.programs.blesh = {
    enable = mkEnableOption "ble.sh";

    package = mkPackageOption pkgs "ble.sh" { default = [ "blesh" ]; };

    manageBashrc = mkOption {
      type = types.bool;
      default = config.home.file ? ".bashrc";
      defaultText = literalExpression ''config.home.file ? ".bashrc"'';
      description = ''
        Insert <code>[[ $- == *i* ]] &amp;&amp; source /path/to/ble.sh --noattach</code> at the beggining of <filename>~/.bashrc</filename> and <code>[[ $\{BLE_VERSION-\} ]] &amp;&amp; ble-attach</code> at the end.
        This is the recommended way. If you want to manage <filename>.bashrc</filename> manually you can disable it.
      '';
    };

    options = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = ''
        Change setting variables with <code>bleopt</code> function.
      '';
      example = { complete_auto_delay = "300"; };
    };

    faces = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = ''
        Change graphic settings with <code>ble-face</code> function.
      '';
      example = { region = "bg=60,fg=white"; };
    };

    imports = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Search listed script files and sources them with <code>ble-import</code> if they are not yet sourced. Scripts are searched from <code>import_path</code> setting variables.
        Use <xref linkend="opt-programs.blesh.blercExtra"/> for delayed imports.
      '';
      example = [ "contrib/bash-preexec" ];
    };

    blercExtra = mkOption {
      type = types.str;
      default = "";
      description = ''
        Extra configlations to be added at the end of <filename>~/.blerc</filename>.
      '';
      example = ''
        function my/complete-load-hook {
          bleopt complete_auto_delay=300
        }

        blehook/eval-after-load complete my/complete-load-hook
      '';
    };
  };

  config = let
    stringifyAttrs = cmd: options:
      concatStringsSep "\n"
      (mapAttrsToList (k: v: "${cmd} ${k}=${escapeShellArg v}") options);
    stringifyLists = cmd: options:
      concatStringsSep "\n" (map (v: "${cmd} ${escapeShellArg v}") options);
    optionsStr = stringifyAttrs "bleopt" cfg.options;
    facesStr = stringifyAttrs "ble-face" cfg.faces;
    importsStr = stringifyLists "ble-import" cfg.imports;
  in mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.file.".blerc".source = pkgs.writeTextFile {
      name = "blerc";
      text =
        concatStringsSep "\n" [ optionsStr facesStr importsStr cfg.blercExtra ];
      checkPhase = ''
        ${pkgs.stdenv.shellDryRun} "$target"
      '';
    };
  };
}
