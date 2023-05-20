## Intro

I've stopped using archinstall because:

1. archinstall is buggy on some installs and that sucks badly
2. the initial luks password takes ~7-10 extra seconds on boot
3. it's not that much more work to just do the install by hand

Still, if you want to do archinstall, here's the gist of it:

## pre-archinstall

Need network connection (see installation-initial.md)

```bash
archinstall
```

## archinstall

If you get a keyring issue [like this](https://github.com/archlinux/archinstall/issues/1389) when running archinstall, just [wait a minute](https://github.com/archlinux/archinstall/issues/1389#issuecomment-1235597526) and re-run the command and it should work.

Basic install using archinstall:

```script
Default is fine unless noted
Mirror region -> United States (space, then Enter)
Drive(s) -> [nvme0n1 typically]
Disk Layout -> "Wipe all ..." -> ext4; sep partition for home -> no
Encryption Password -> [set]
Hostname -> [set]
Root password -> [set]
User account -> password -> yes superuser -> 'Confirm and exit'
Profile -> desktop -> sway; graphics driver -> [whatever]
Audio -> pipewire
Kernels -> maybe linux-lts for now?
Additional packages -> See installation.yaml `core-packages` (??? trying nothing extra this time ??)
Network Configuration -> Use Network Manager
Timezone -> America/Denver
Install
```

Then, switch over to `installation-initial.md`
