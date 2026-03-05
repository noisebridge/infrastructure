# Hardware-specific configuration.
# Replace with output of `nixos-generate-config --show-hardware-config`
# after installing on the actual colo machine.
{ config, lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-amd" ]; # or kvm-intel for Xeon

  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
