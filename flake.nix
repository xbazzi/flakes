{
  description = "My personal Nix flake templates";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            just
          ];

          shellHook = ''
            echo "Devshell started successfully"

            # SSH keys to add (customize this list as needed)
            SSH_KEYS=(
              "$HOME/.ssh/gh_id_ed25519"
              "$HOME/.ssh/gt_id_ed"
            )

            # Start SSH agent if not already running
            if [ -z "$SSH_AUTH_SOCK" ]; then
              # Check if any keys exist before starting agent
              key_exists=false
              for key in "''${SSH_KEYS[@]}"; do
                if [ -f "$key" ]; then
                  key_exists=true
                  break
                fi
              done

              if [ "$key_exists" = true ]; then
                eval $(ssh-agent -s) > /dev/null
                # Add all existing keys
                for key in "''${SSH_KEYS[@]}"; do
                  if [ -f "$key" ]; then
                    ssh-add "$key" 2>/dev/null && echo "Added SSH key: $(basename $key)"
                  fi
                done
              fi
            fi
          '';
        };
      }
    )
    // {
      templates = {
        devshell-base = {
          path = ./templates/devshell-base;
          description = "A flake with an empty devshell";
        };
        rust = {
          path = ./templates/rust;
          description = "A base template for any rust project";
        };
        standardml = {
          path = ./templates/standardml;
          description = "A base template for any standardml project";
        };
        cargo-workspace = {
          path = ./templates/cargo-workspace;
          description = "A base template for a new cargo workspace project";
        };
        haskell = {
          path = ./templates/haskell;
          description = "A base template with the haskell toolchain and just";
        };
        cpp = {
          path = ./templates/cpp;
          description = "A base template with the cpp toolchain and make";
        };
      };
    };
}
