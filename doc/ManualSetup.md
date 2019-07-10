## Set up the Raspberry Pi
There are four phases to setting up the Pi:
1. Get the OS onto the micro sd card.
1. Get a shell on the Pi.
1. Set up the archive for dashcam clips.
1. Set up the USB storage functionality.

There is a streamlined process for setting up the Pi which can currently be used if you plan to use Windows file shares, MacOS Sharing, or Samba on Linux for your video archive. [Instructions](doc/OneStepSetup.md).

If you'd like to host the archive using another technology or would like to set the Pi up, yourself, continue these instructions.

### Get the OS onto the MicroSD card
[These instructions](https://www.raspberrypi.org/documentation/installation/installing-images/README.md) tell you how to get Raspbian onto your MicroSD card. Basically:
1. Connect your SD card to your computer.
2. Use Etcher to write the zip file you downloaded to the SD card.
   > Note: you don't need to uncompress the zip file you downloaded.

### Get a shell on the Pi
Follow the instructions corresponding to the OS you used to flash the OS onto the MicroSD card:
* Windows: [Instructions](doc/GetShellWithoutMonitorOnWindows.md).
* MacOS or Linux: [Instructions](doc/GetShellWithoutMonitorOnLinux.md).

Whichever instructions you followed above will leave you in a command shell on the Pi. Use this shell for the rest of the steps in these instructions.

### Become root on the Pi

First you need to get into a root shell on the Pi:
```
sudo -i
```

You'll stay in this root shell until you run the "halt" command in the "Set up USB storage functionality" below.

### Set up the archive for dashcam clips
Follow the instructions corresponding to the technology you'd like to use to host the archive for your dashcam clips. You must choose just one of these technologies; don't follow more than one of these sets of instructions:
* Windows file share, MacOS Sharing, or Samba on Linux: [Instructions](doc/SetupShare.md).
* SFTP/rsync: [Instructions](doc/SetupRSync.md)
* **Experimental:** Google Drive, Amazon S3, DropBox, Microsoft OneDrive: [Instructions](doc/SetupRClone.md)

### Optional: Allocate SD Card Storage
Indicate how much of the drive you want to allocate to recording dashcam footage and music by running this command:

```
 export camsize=<number or percentage>
```

For example, using `export camsize=100%` would allocate 100% of the space to recording footage from your car and would not create a separate music partition. `export camsize=50%` would allocate half of the space for a dashcam footage drive and allocates the other half to for a music storage drive, unless otherwise specified. If you don't set `camsize`, the script will allocate 90% of the total space to the dashcam by default. Size can be specified as a percentage or as an absolute value, e.g. `export camsize=16G` would allocate 16 gigabytes for dashcam footage.
If you want limit music storage so it doesn't use up all the remaining storage after camera storage has been allocated, use `export musicsize=<number or percentage>` to specify the size.
For example, if there is 100 gigabyte of free space, then
```
 export camsize=50%
 export musicsize=10%
```
would allocate 50 gigabytes for camera and 10 gigabytes for music, leaving 40 gigabytes free.


### Optional: Configure push notification via Pushover, Gotify, or IFTTT
If you'd like to receive a notification when your Pi finishes archiving clips follow these [Instructions](doc/ConfigureNotificationsForArchive.md).

### Optional: Configure a hostname
The default network hostname for the Pi will become `teslausb`.  If you want to have more than one TeslaUSB devices on your network (for example you have more than one Tesla in your houseold), then you can specify an alternate hostname for the Pi by running this command:

```
 export TESLAUSB_HOSTNAME=<new hostname>
```

For example, you could use `export TESLAUSB_HOSTNAME=teslausb-ModelX`

Make sure that whatever you speicfy for the new hostname is compliant with the rules for DNS hostnames; for example underscore (_) is not allowed, but dash (-) is allowed.  Full rules are in RFC 1178 at https://tools.ietf.org/html/rfc1178

### Set up the USB storage functionality
1. Run these commands:
    ```
    mkdir -p /root/bin
    cd /root/bin
    wget https://raw.githubusercontent.com/marcone/teslausb/main-dev/setup/pi/setup-teslausb
    chmod +x setup-teslausb
    ./setup-teslausb
    ```
1. Run this command:
    ```
    halt
    ```
1. Disconnect the Pi from the computer.

On the next boot, the Pi hostname will become `teslausb`, so future `ssh` sessions will be `ssh pi@teslausb.local`.   If you specified your own hostname, be sure to use that name (for example `ssh pi@teslausb-ModelX.local`)

Your Pi is now ready to be plugged into your Tesla. If you want to add music to the Pi, follow the instructions in the next section.

## Optional: Add music to the Pi
> Note: If you set `camsize` to `100%` then skip this step.

Connect the Pi to a computer. If you're using a cable be sure to use the port labeled "USB" on the circuitboard.
1. Wait for the Pi to show up on the computer as a USB drive.
1. Copy any music you'd like to the drive labeled MUSIC.
1. Eject the drives.
1. Unplug the Pi from the computer.
1. Plug the Pi into your Tesla.

Alternatively, you can configure the Pi to automatically copy from a CIFS share. To do this, define the "musicsharename" variable to point at a CIFS share and folder. The share currently must exist on the same server as the one where recordings will be backed up, and use the same credentials. The Pi will sync down ALL music it finds under the specified folder, so be sure there is enough space on the Pi's music drive.
For example, if you have your music on a share called 'Music', and on that share have a folder called 'CarMusic' where you copied all the songs that you want to have available in the car, use `export musicsharename=Music/CarMusic` in the setup file.


## Optional: Making changes to the system after setup
The setup process configures the Pi with read-only file systems for the operating system but with read-write
access through the USB interface. This means that you'll be able to record dashcam video and add and remove
music files but you won't be able to make changes to files on / or on /boot. This is to protect against
corruption of the operating system when the Tesla cuts power to the Pi.

To make changes to the system partitions:
```
ssh pi@teslausb.
sudo -i
/root/bin/remountfs_rw
```
Then make whatever changes you need to. The next time the system boots the partitions will once again be read-only.
