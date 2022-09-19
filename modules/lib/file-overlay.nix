{ pkgs, config }:
file:
file // pkgs.lib.attrsets.optionalAttrs
(with config.programs.blesh; enable && manageBashrc && file ? ".bashrc") {
  ".bashrc" = file.".bashrc" // {
    source = pkgs.writeTextFile {
      name = "bashrc";
      text = ''
        [[ $- == *i* ]] && source '${config.programs.blesh.package}/share/ble.sh' --noattach

        ${builtins.readFile file.".bashrc".source}

        [[ ''${BLE_VERSION-} ]] && ble-attach
      '';
    };
  };
}
