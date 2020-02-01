FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update && \
    apt-get -y install \
        git vim parted \
        quilt coreutils qemu-user-static debootstrap zerofree zip dosfstools \
        bsdtar libcap2-bin rsync grep udev xz-utils curl xxd file kmod bc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY pi-gen/ /pi-gen/
COPY config /pi-gen/config
COPY 00-teslausb-tweaks/ /pi-gen/stage_teslausb

RUN rm -rf /pi-gen/stage2/EXPORT_NOOBS \
    && touch /pi-gen/stage_teslausb/EXPORT_IMAGE \
    && cp /pi-gen/stage2/prerun.sh /pi-gen/stage_teslausb/prerun.sh

VOLUME [ "/pi-gen/work", "/pi-gen/deploy"]
