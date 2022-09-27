{ pkgs, config }:

# Overlay functions are applied in the order of the list.
# Latter function will be applied latter and get more precedance.
[
  (self: super:
    pkgs.lib.attrsets.optionalAttrs
    (with config.programs.blesh; enable && manageBashrc && super ? ".bashrc") {
      ".bashrc" = super.".bashrc" // {
        source = pkgs.writeTextFile {
          inherit (super.".bashrc".source) name;
          text = ''
            [[ $- == *i* ]] && source '${config.programs.blesh.package}/share/ble.sh' --noattach

            ${builtins.readFile super.".bashrc".source}

            [[ ''${BLE_VERSION-} ]] && ble-attach
          '';
        };
      };
    })
]
