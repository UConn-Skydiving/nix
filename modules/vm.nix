# modules/vm.nix
################################################################################
# Enables a local VM runner for fast iteration on the jonathan host config.
# Example usage:
# nix run .#vm
# Behavior auto-switches by host platform:
# - Linux: uses the NixOS VM runner from system.build.vm
# - Darwin: launches the jonathan ISO with local Darwin QEMU
################################################################################

{ inputs, community, ... }:
{
  den.aspects.jonathan.includes = [
    community.vm._.gui
    # community.vm._.tui
  ];

  perSystem =
    { pkgs, ... }:
    let
      host = inputs.self.nixosConfigurations.jonathan.config;
    in
    {
      packages.vm =
        if pkgs.stdenv.isLinux then
          pkgs.writeShellApplication {
            name = "vm";
            text = ''
              ${host.system.build.vm}/bin/run-${host.networking.hostName}-vm "$@"
            '';
          }
        else if pkgs.stdenv.isDarwin then
          pkgs.writeShellApplication {
            name = "vm";
            runtimeInputs = [ pkgs.qemu ];
            text = ''
              set -euo pipefail

              readonly iso="${host.system.build.isoImage}"
              readonly qemu_share="${pkgs.qemu}/share/qemu"
              readonly ovmf_code="$qemu_share/edk2-aarch64-code.fd"

              if [ ! -e "$ovmf_code" ]; then
                echo "error: missing aarch64 UEFI firmware in $qemu_share." >&2
                echo "hint: this may indicate a qemu packaging mismatch on Darwin." >&2
                exit 1
              fi

              # Try macOS HVF acceleration first, then fall back to TCG.
              exec qemu-system-aarch64 \
                -machine virt,accel=hvf:tcg \
                -cpu max \
                -smp 4 \
                -m 4096 \
                -device virtio-gpu-pci \
                -device qemu-xhci \
                -device usb-kbd \
                -device usb-mouse \
                -display default \
                -bios "$ovmf_code" \
                -drive "file=$iso,media=cdrom,readonly=on" \
                "$@"
            '';
          }
        else
          pkgs.writeShellApplication {
            name = "vm";
            text = ''
              echo "error: .#vm is only supported on Linux and Darwin hosts." >&2
              exit 1
            '';
          };
    };
}
