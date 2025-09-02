{
  description = "GKE demo shell (gcloud + GKE auth plugin + kubectl)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
  let
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
  in {
    devShells = forAllSystems (system:
      let
        pkgs = import nixpkgs { inherit system; };
        gcloudWithPlugin =
          pkgs.google-cloud-sdk.withExtraComponents (with pkgs.google-cloud-sdk.components; [
            gke-gcloud-auth-plugin
          ]);
      in {
        default = pkgs.mkShell {
          buildInputs = [ gcloudWithPlugin pkgs.kubectl ];
          shellHook = ''
            export USE_GKE_GCLOUD_AUTH_PLUGIN=True
            echo "gcloud + kubectl ready; GKE auth plugin enabled."
          '';
        };
      });
  };
}

