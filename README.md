EMBA Builder
============

This repository contains code to automate building a dedicated VM for
[EMBA](https://www.securefirmware.de/). As EMBA runs best on [Kali
Linux](https://www.kali.org/), it uses Kali's own [build script for VM
images](https://gitlab.com/kalilinux/build-scripts/kali-vm/) and modifies it to
install EMBA.

Setup
-----

1. Clone this repository
2. Run `setup.sh` (or manually clone the submodule and apply the patches from the `kali-vm-patches` directory)
3. Optionally: Add your SSH public key to `kali-vm/overlays/ssh-keys/home/emba/.ssh/authorized_keys` and/or `kali-vm/overlays/ssh-keys/home/autoemba/.ssh/authorized_keys`. Change the user name in the first path if the primary user is not named `emba` (`-U` option to `build.sh`, see below)

Usage
-----

Refer to the documentation of the Kali build scripts for details information.
The short version:

* `build.sh` builds directly on the host system and therefore requires several tools to be installed.
* `build-in-container.sh` is a wrapper that should just work, if a supported container runtime is installed.

**Note**: Kali's scripts do not work if the current working directory is not
the `kali-vm` repository. Be sure to `cd` to that directory before trying any
of the commands below.

To build a minimal VM image for [QEMU](https://www.qemu.org/)/[libvirt](https://libvirt.org/), run something like:

```sh
./build-in-container.sh -f qemu -v qemu -s 50 -D none -T none -L ${LANG/utf8/UTF-8} -Z Europe/Berlin -H emba -U emba:hunter2
```

To build the same for [VirtualBox](https://www.virtualbox.org/), run:

```sh
./build-in-container.sh -f virtualbox -v virtualbox -s 50 -D none -T none -L ${LANG/utf8/UTF-8} -Z Europe/Berlin -H emba -U emba:hunter2
```

Refer to `build.sh --help` for the meaning of the individual arguments and further customization options.

The build process takes a few minutes and creates a VM image in the `images` directory.
Manually import it into you favourite VM management software and assign the necessary resources.

**Important:** The EMBA installation in the VM image is not finished. EMBA
still needs to install several packages, compile some code and fetch a
container image. Unfortunately, this can not be done during VM image creation.
Therefore, the EMBA setup will automatically be finished on first boot.
This will take a while.
Monitor the `emba-setup` Systemd unit or the VM's CPU and disk load to check on
the progress.
The output of the setup process can be seen on the VM's first TTY.

**Important:** As the VM's first TTY is used to display EMBA logs, it can not
be used to log in to the system. Use the second or any other TTY instead. Or
use SSH, of course.

Updating
--------

Once set up, the VM image can be used like any VM and updated accordingly.
It may be easier, though, to simply build an new image from time to time to get
the latest versions of Kali and EMBA.
VM management software may provide a comfortable way to overwrite the disk
image of the existing VM, rather than reconfiguring it from scratch.
