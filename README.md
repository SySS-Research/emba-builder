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
3. Optionally: Add your SSH public key to `kali-vm/overlays/ssh-keys/home/emba/.ssh/authorized_keys` and/or `kali-vm/overlays/ssh-keys/home/autoemba/.ssh/authorized_keys`. Change the user name in the first path if the primary user is not named `emba` (`-U` option to `build.sh`, see below). Note that these files and directories *must not* be group or world writable for OpenSSH to accept them!

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

Using EMBA
----------

To actually use EMBA, you may simply log in via SSH or the console, copy the
firmware into the VM and run EMBA with the desired parameters.
However, this is rather cumbersome as it requires typing several commands
manually.

To make things simpler (for simple use cases), there is another option:
Connect to the VM via SFTP as the user `autoemba`. You will see the two
directories `upload` and `log`. `upload` contains subdirectories named like
EMBA scan profiles. Simply upload a firmware image into one of those
directories to trigger a scan with the respective profile.

It takes about 30 seconds before the scan starts. The firmware is then removed
from the `upload` directory and a directory named like the firmware file is
created in `logs`. EMBA will write the scan results into this directory.

Example console-based workflow (GUI SFTP client work similarly):

```
sftp autoemba@192.168.122.2
Connected to 192.168.122.2.
sftp> ls
logs    upload
sftp> ls upload
upload/default-sbom                upload/default-scan
upload/default-scan-emulation      upload/default-scan-gpt
upload/default-scan-long           upload/default-scan-no-notify
upload/default-vex                 upload/example-disable-module
upload/full-scan                   upload/quick-sbom
upload/quick-scan
sftp> put sample-firmware.img upload/default-scan/
Uploading sample-firmware.img to /upload/default-scan/sample-firmware.img
sample-firmware.img                  100% 1337MB   1.3GB/s   00:00
sftp> ls upload/default-scan
upload/default-scan/sample-firmware.img
sftp> ls upload/default-scan
sftp> ls logs
logs/sample-firmware.img
sftp> ls logs/sample-firmware.img/
logs/sample-firmware.img/csv_logs
logs/sample-firmware.img/emba.log
logs/sample-firmware.img/etc
logs/sample-firmware.img/firmware
logs/sample-firmware.img/html-report
logs/sample-firmware.img/json_logs
logs/sample-firmware.img/orig_user.log
logs/sample-firmware.img/print_running_modules.pid
logs/sample-firmware.img/tmp
```

The console output of the scans can be monitored on the VM's first TTY, similar
to the output of the setup process.
