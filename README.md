`zm` is a simple Linux system for work, developed based on the Debian system. It compresses the entire system into a squashfs file and realizes read and write with unionfs. It has several main functions:

- Install the system with one command. The installation medium can be a hard disk, USB flash drive, CD, etc. The entire system has only 4 files: kernel, initrd, root.sfs, home.sfs.
- Support generating differential files, and the differential files are also compressed into squashfs files.
- The top-level differential is stored in memory by default, so the startup and common software operations are very fast.
- Comes with a backup system, which backs up the working directory as a squashfs file, and the backup file also supports differential.
- Directly generate the disk image required by the virtual machine.

## Parameters

The following parameters are used in the `zm` system:

- `sfsroot`: The volume label of the system partition. It is recommended to be 20G.
- `work`: The optional work partition volume label. It is used to mount `/work`, the working disk partition. The larger the better.
- `swap`: The optional swap partition volume label. It is recommended to be 4G.
- `backup`: The optional backup partition volume label. It is used to store backup projects. It is recommended to be 200G.

## Commands

The following commands are available in the `zm` system:

- `zm`: The main command for installing and managing the system.
- `zm install`: Installs the system with one command. The installation medium can be a hard disk, USB flash drive, CD, etc.
- `zm update`: Updates the system to the latest version.
- `zm backup`: Backs up the working directory as a squashfs file. The backup file also supports differential.
- `zm restore`: Restores the system from a backup file.
- `zm diff`: Generates differential files, which are also compressed into squashfs files.
- `zm version`: Shows the version of the `zm` system.
- `zm osname`: Shows the name of the operating system.

## Usage

To install the `zm` system, follow these steps:

1. Download the `zm` file.
2. Create a partition with the volume label `sfsroot` and format it as `ext4`.
3. Create an optional work partition with the volume label `work` and format it as `ext4`.
4. Create an optional swap partition with the volume label `swap`.
5. Create an optional backup partition with the volume label `backup`.
6. Run the command `zm install` and follow the prompts.

To update the `zm` system, run the command `zm update`.

To back up the working directory, run the command `zm backup`.

To restore the system from a backup file, run the command `zm restore`.

To generate differential files, run the command `zm diff`.

To show the version of the `zm` system, run the command `zm version`.

To show the name of the operating system, run the command `zm osname`.

## Conclusion

The `zm` system is a simple and efficient Linux system for work, with easy installation and management. It is recommended for users who need a lightweight and fast system for their work.
