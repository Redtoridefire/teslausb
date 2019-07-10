# teslausb

## Changes

This fork contains the following changes compared to the upstream [cimryan/teslausb](https://github.com/cimryan/teslausb):
1. Supports Tesla firmware 2019.x
1. Supports exporting the recordings as a CIFS share
1. Supports automatically syncing music from a CIFS share folder
1. Supports using the Tesla API to keep the car awake during archiving
1. Status indicator while running
1. Easier and more flexible way to specify sizes of camera and music disks
1. Support for Gotify and IFTTT in addition to Pushover for notifications

It is recommended to use the [prebuilt image](https://github.com/marcone/teslausb/releases) and [one step setup instructions](https://github.com/marcone/teslausb/blob/main-dev/doc/OneStepSetup.md) to get started, as the instructions below may be outdated.


## Intro

You can configure a Raspberry Pi Zero W so that your Tesla thinks it's a USB drive and will write dashcam footage to it. Since it's a computer:
* Scripts running on the Pi can automatically copy the clips to an archive server when you get home.
* The Pi can hold both dashcam clips and music files.
* The Pi can automatically repair filesystem corruption produced by the Tesla's current failure to properly dismount the USB drives before cutting power to the USB ports.

Archiving the clips can take from seconds to hours depending on how many clips you've saved and how strong the WiFi signal is in your Tesla. If you find that the clips aren't getting completely transferred before the car powers down after you park or before you leave you can use the Tesla app to turn on the Climate control. This will send power to the Raspberry Pi, allowing it to complete the archival operation.

Alternatively, you can provide your Tesla account credentials and VIN in TeslaUSB's settings, which will allow it to use the [Tesla API](https://tesla-api.timdorr.com) to keep the car awake while the files transfer. Instructions are available below and in the [one step setup instructions](https://github.com/marcone/teslausb/blob/main-dev/doc/OneStepSetup.md)

## Contributing
You're welcome to contribute to this repo by submitting pull requests and creating issues.

## Prerequisites

### Assumptions
* You park in range of your wireless network.
* Your wireless network is configured with WPA2 PSK access.

### Hardware

Required:
* [Raspberry Pi Zero W](https://www.raspberrypi.org/products/raspberry-pi-zero-w/):  [Adafruit](https://www.adafruit.com/product/3400) or [Amazon](https://www.amazon.com/Raspberry-Pi-Zero-Wireless-model/dp/B06XFZC3BX/)
  > Note: Of the many varieties of Raspberry Pi avaiable only the Raspberry Pi Zero and Raspberry Pi Zero W can be used as simulated USB drives. It may be possible to use a Pi Zero with a USB Wifi adapter to achieve the same result as the Pi Zero W but this hasn't been confirmed.

* A Micro SD card, at least 16 GB in size, and an adapter (if necessary) to connect the card to your computer.
* A mechanism to connect the Pi to the Tesla. Either:
  * A USB A/Micro B cable: [Adafruit](https://www.adafruit.com/product/898) or [Amazon](https://www.amazon.com/gp/product/B013G4EAEI/), or
  * A USB A Add-on Board if you want to plug your Pi into your Tesla like a USB drive instead of using a cable. [Amazon](https://www.amazon.com/gp/product/B07BK2BR6C/), or
  * A PCB kit if you want the lowest profile possible and you're able to solder. [Sparkfun](https://www.sparkfun.com/products/14526)

Optional:
* A case. The "Official" case: [Adafruit](https://www.adafruit.com/product/3446) or [Amazon](https://www.amazon.com/gp/product/B06Y593MHV). There are many others to choose from. Note that the official case won't work with the USB A Add-on board or the PCB kit.
* USB Splitter if you don't want to lose a front USB port. [The Onvian Splitter](https://www.amazon.com/gp/product/B01KX4TKH6) has been reported working by multiple people on reddit.

### Software
Download: [Raspbian Stretch Lite](https://www.raspberrypi.org/downloads/raspbian/)

**NOTE:** it is highly recommended that you use the [prebuilt teslausb image](https://github.com/marcone/teslausb/releases) instead and follow the [one step headless setup process](https://github.com/marcone/teslausb/blob/main-dev/doc/OneStepSetup.md).

Download and install: [Etcher](http://etcher.io)

## Set up the Raspberry Pi
This is a streamlined process for setting up the Pi. You'll flash a preconfigured version of Raspbian Stretch Lite and then fill out a config file. There is a [manual setup process](https://github.com/marcone/teslausb/blob/main-dev/doc/ManualSetup.md), but it is highly recommended to follow the instructions below. 

## Notes

* Assumes your Pi has access to Wifi, with internet access (during setup). (But all setup methods do currently.) USB networking is still enabled for troubleshooting or manual setup
* This image will work for either _headless_ (tested) or _manual_ (tested less) setup.
* Currently not tested with the RSYNC/SFTP method when using headless setup.

## Configure the SD card before first boot of the Pi

1. Flash the [latest image release](https://github.com/marcone/teslausb/releases) using Etcher or similar.

### For headless (automatic) setup

1. Mount the card again, and in the `boot` directory create a `teslausb_setup_variables.conf` file to export the same environment variables normally needed for manual setup (including archive info, Wifi, and push notifications (if desired).
A sample conf file is located in the `boot` folder on the SD card.

    The file should contain the entries below at a minimum, but **replace with your own values**. Be sure that your WiFi password is enclosed in single quotes, and that if it contains one or more single quote characters you replace each single quote character with a backslash followed by a single quote character.

    For example, if your password were
    ```
    a'b
    ```
    you would have

    ```
    export WIFIPASS='a\'b'
    ```
If your WiFi SSID has spaces in its name, make sure they're escaped.

For example, if your SSID were
```
Foo Bar 2.4 GHz
```
you would use
```
export SSID=Foo\ Bar\ 2.4\ GHz
```
or
```
export SSID='Foo Bar 2.4 GHz'
```

Example file:

    export ARCHIVE_SYSTEM=cifs
    export archiveserver=Nautilus
    export sharename=SailfishCam
    export shareuser=sailfish
    export sharepassword='pa$$w0rd'
    export camsize=100%
    # SSID of your 2.4 GHz network
    export SSID='your_ssid'
    export WIFIPASS='your_wifi_password'
    export HEADLESS_SETUP=true
    # export REPO=marcone
    # export BRANCH=main-dev
    # By default will use the main repo, but if you've been asked to test the image,
    # these variables should be uncommunted and updated to point to the right repo/branch

    # Set to either an actual timezone, or "auto" to attempt automatic timezone detection.
    # If unset, defaults to the default Raspbian timezone, Europe/London (BST).
    # export timezone=America/Los_Angeles

    # By default there is a 20 second delay between connecting to wifi and
    # starting the archiving of recorded clips. Uncomment this to change
    # the duration of that delay
    # export archivedelay=20

    # export pushover_enabled=false
    # export pushover_user_key=user_key
    # export pushover_app_key=app_key

    # export gotify_enabled=false
    # export gotify_domain=https://gotify.domain.com
    # export gotify_app_token=put_your_token_here
    # export gotify_priority=5

    # export ifttt_enabled=false
    # export ifttt_event_name=put_your_event_name_here
    # export ifttt_key=put_your_key_here

    # TeslaUSB can optionally use the Tesla API to keep your car awake, so it can
    # power the Pi long enough for the archiving process to complete. To enable
    # that, please provide your Tesla account email and password below.
    # TeslaUSB will only send your credentials to the Tesla API itself.
    # export tesla_email=joeshmo@gmail.com
    # export tesla_password=teslapass
    # Please also provide your vehicle's VIN, so TeslaUSB can keep the correct
    # vehicle awake.
    # export tesla_vin=5YJ3E1EA4JF000001

1. Boot it in your Pi, give it a bit, watching for a series of flashes (2, 3, 4, 5) and then a reboot and/or the CAM/music drives to become available on your PC/Mac. The LED flash stages are:

| Stage (number of flashes)  |  Activity |
|---|---|
| 2 | Verify the requested configuration is creatable |
| 3 | Grab scripts to start/continue setup |
| 4 | Create partition and files to store camera clips/music) |
| 5 | Setup completed; remounting filesystems as read-only and rebooting |

The Pi should be available for `ssh` at `pi@teslausb.local`, over Wifi (if automatic setup works) or USB networking (if it doesn't). It takes about 5 minutes, or more depending on network speed, etc.

If plugged into just a power source, or your car, give it a few minutes until the LED starts pulsing steadily which means the archive loop is running and you're good to go.

You should see in `/boot` the `TESLAUSB_SETUP_FINISHED` and `WIFI_ENABLED` files as markers of headless setup success as well.

### For manual setup

1. After flashing the image, boot it in your Pi and:
    *  connect via USB networking at `ssh pi@teslausb.local`. (The Pi must be connected to your PC and plugged into the port labeled USB on the Pi. Or...
    * You can also just automate the Wifi portion of setup by creating the `boot/teslausb_setup_variables.conf` file and populating it with the `SSID` and `WIFIPASS` variables:
    ```
    export SSID=your_ssid
    export WIFIPASS=your_wifi_pass
    ```

1. Once you have an `ssh` session, follow the steps starting at [Set up the USB storage functionality](https://github.com/marcone/teslausb#set-up-the-usb-storage-functionality) in the main guide.

### Troubleshooting

#### Headless (full or Wifi) setup
* `ssh` to `pi@teslausb.local` (assuming Wifi came up, or your Pi is connected to your computer via USB) and look at the `/boot/teslausb-headless-setup.log`.
* Try `sudo -i` and then run `/etc/rc.local`. The scripts are  fairly resilient to restarting and not re-running previous steps, and will tell you about progress/failure.
* If Wifi didn't come up:
    * Double-check the SSID and WIFIPASS variables in `teslausb_setup_variables.conf`, and remove `/boot/WIFI_ENABLED`, then booting the SD in your Pi to retry automatic Wifi setup.
  * If still no go, re-run `/etc/rc.local`
  * If all else fails, copy `/boot/wpa_supplicant.conf.sample` to `/boot/wpa_supplicant.conf` and edit out the `TEMP` variables to your desired settings.
* (Note: if you get an error about `read-only filesystem`, you may have to `sudo -i` and run `/root/bin/remountfs_rw`.


### Background information
##### What happens under the covers

When the Pi boots the first time:
* A `/boot/teslausb-headless-setup.log` file will be created and stages logged.
* Marker files will be created in `boot` like `TESLA_USB_SETUP_STARTED` and `TESLA_USB_SETUP_FINISHED` to track progress.
* Wifi is detected by looking for `/boot/WIFI_ENABLED` and if not, creates the `wpa_supplicant.conf` file in place, using `SSID` and `WIFIPASS` from `teslausb_setup_variables.conf` and reboots.
* The Pi LED will flash patterns (2, 3, 4, 5) as it gets to each stage (labeled in the setup-teslausb script).
  * ~~10 flashes means setup failed!~~ (not currently working)
* After the final stage and reboot the LED will go back to normal. Remember, the step to remount the filesystem takes a few minutes.

At this point the next boot should start the Dashcam/music drives like normal. If you're watching the LED it will start flashing every 1 second, which is the archive loop running.

> NOTE: Don't delete the `TESLAUSB_SETUP_FINISHED` or `WIFI_ENABLED` files. This is how the system knows setup is complete.

### Image modification sources

The sources for the image modifications, and instructions, are in the [pi-gen-sources folder](https://github.com/marcone/teslausb/tree/main-dev/pi-gen-sources).

## Meta
This repo contains steps and scripts originally from [this thread on Reddit]( https://www.reddit.com/r/teslamotors/comments/9m9gyk/build_a_smart_usb_drive_for_your_tesla_dash_cam/)

Many people in that thread suggested that the scripts be hosted on Github but the author didn't seem interested in making that happen. I've hosted the scripts here with his/her permission.
