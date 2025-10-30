
# Need v4l2loopback working

https://wiki.archlinux.org/title/V4l2loopback
yay -S  v4l2loopback-dkms linux-lts-headers
# restart??

modprobe v4l2loopback card_label=Video-Loopback exclusive_caps=1
v4l2-ctl --list-devices

# setup permanent (as root)
echo "v4l2loopback" > /etc/modules-load.d/v4l2loopback.conf
echo "options v4l2loopback card_label=Video-Loopback exclusive_caps=1" > /etc/modprobe.d/v4l2loopback-video-loopback.conf


# outputs:
# Video-Loopback (platform:v4l2loopback-000):
#     /dev/video4
# ...


yay -S obs-studio

obs

# Change which part of the screen is output
# hold down (Alt [windows for me]) and then move the red dots around
