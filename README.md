# coldkernel
coldkernel is an automated build tool for grsec-enabled kernels on Debian, Ubuntu and CentOS. It also includes experimental
support for Qubes TemplateVMs.

You will need (at least) 4GB of free disk space before starting the build.

## Dependencies

### Debian 7+ / Ubuntu
```
sudo apt install paxctl bc wget gnupg fakeroot build-essential devscripts libfile-fcntllock-perl git
sudo apt-get build-dep linux
gcc --version
sudo apt install gcc-4.9-plugin-dev (for GCC 4.9)
sudo apt install gcc-5-plugin-dev (for GCC 5.x)
sudo apt install gcc-6-plugin-dev (for GCC 6.x)
```

### CentOS 7+
```
sudo yum groupinstall "Development Tools"
sudo yum install hmaccalc zlib-devel binutils-devel elfutils-libelf-devel ncurses-devel gcc-plugin-devel wget git gnupg2 bc
```

### Qubes TemplateVM (Debian)
In dom0:
```
sudo qubes-dom0-update grub2-xen
```

In Debian TemplateVM:
```
sudo apt install qubes-kernel-vm-support grub2-common
sudo apt install paxctl bc wget gnupg fakeroot build-essential devscripts libfile-fcntllock-perl git gcc-4.9-plugin-dev
```
Edit ```/etc/apt/sources.list``` and uncomment the lines starting with ```deb-src```.
```
sudo apt-get build-dep linux
```
<!---
### Qubes TemplateVM (Fedora)
In dom0:
```
sudo qubes-dom0-update grub2-xen
```

In Fedora TemplateVM:
```
sudo yum groupinstall "Development Tools"
sudo yum install hmaccalc zlib-devel binutils-devel elfutils-libelf-devel ncurses-devel gcc-plugin-devel wget git gnupg2 bc gcc-c++ rpm-build
sudo yum install qubes-kernel-vm-support grub2-tools
```
--->
## Clone / Build

### Clone
```
wget "https://coldhak.ca/coldhak/keys/coldhak.asc" -O coldhak.asc
gpg --import coldhak.asc
git clone https://github.com/coldhakca/coldkernel
cd coldkernel
git verify-tag coldkernel-0.9a-4.8.13
git checkout tags/coldkernel-0.9a-4.8.13
```

### Build
Run ```make``` without arguments to build without hypervisor support. Otherwise, select the option below that best describes
your setup.
```
make kvm-host
make kvm-guest
make virtualbox-host
make virtualbox-guest
make xen-host
make xen-guest
make vmware-host
make vmware-guest
make hyperv-guest
make qubes-guest (EXPERIMENTAL)
```

## Once built

### Debian 7+ / Ubuntu
From the coldkernel build directory:
```
wget https://grsecurity.net/paxctld/paxctld_1.2.1-1_amd64.{deb,deb.sig}
gpg --homedir=.gnupg --verify paxctld_1.2.1-1_amd64.{deb.sig,deb}
sudo dpkg -i paxctld_1.2.1-1_amd64.deb
sudo make install-deb
sudo cp paxctld.conf /etc/paxctld.conf
sudo paxctld -d
sudo systemctl enable paxctld
sudo reboot
```

## CentOS 7+
From the coldkernel build directory:
```
wget https://grsecurity.net/paxctld/paxctld-systemd-1.2.1-1.x86_64.{rpm,rpm.sig}
gpg --homedir=.gnupg --verify paxctld-systemd-1.2.1-1.x86_64.{rpm.sig,rpm}
sudo yum localinstall paxctld-systemd-1.2.1-1.x86_64.rpm
sudo make install-rpm
sudo cp paxctld.conf /etc/paxctld.conf
sudo paxctld -d
sudo systemctl enable paxctld
sudo reboot
```

## Qubes TemplateVM (Debian)
From the coldkernel build directory:
```
wget https://grsecurity.net/paxctld/paxctld_1.2.1-1_amd64.{deb,deb.sig}
gpg --homedir=.gnupg --verify paxctld_1.2.1-1_amd64.{deb.sig,deb}
sudo dpkg -i paxctld_1.2.1-1_amd64.deb
sudo make install-deb
sudo cp paxctld.conf /etc/paxctld.conf
sudo paxctld -d
sudo systemctl enable paxctld
sudo mkdir /boot/grub
sudo update-grub2
sudo shutdown -h now
```
Once the TemplateVM has been shutdown, you can change the kernel in the Qubes VM manager to ```pvgrub``` and start the VM.

<!---
## Qubes TemplateVM (Fedora)
From the coldkernel build directory:
```
wget https://grsecurity.net/paxctld/paxctld-systemd-1.2.1-1.x86_64.{rpm,rpm.sig}
gpg --homedir=.gnupg --verify paxctld-systemd-1.2.1-1.x86_64.{rpm.sig,rpm}
sudo yum localinstall paxctld-systemd-1.2.1-1.x86_64.rpm
sudo make install-rpm
sudo cp paxctld.conf /etc/paxctld.conf
sudo paxctld -d
sudo systemctl enable paxctld
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo reboot
```
Once the TemplateVM has been shutdown, you can change the kernel in the Qubes VM manager to ```pvgrub``` and start the VM.
--->

## GIDs
### ```9001```:GRKERNSEC_PROC_USERGROUP
Users in this group are exempted from grsecurity's /proc restrictions.

###  ```9002```:CONFIG_GRKERNSEC_TPE_UNTRUSTED_GID
Users in this group will not be able to execute any files that are not in root-owned directories writable only by root.

### ```9003```:CONFIG_GRKERNSEC_SOCKET_ALL
Users in this group will be unable to connect to other hosts from your machine or run server applications from your machine.

## Group Creation
```
sudo groupadd -g 9001 grsecproc
sudo groupadd -g 9002 tpeuntrusted
sudo groupadd -g 9003 denysockets
```

## Important Notice
This is still extremely alpha. If it breaks, you get to keep the pieces. There is currently support for x86_64 only.

