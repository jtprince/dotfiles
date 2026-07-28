Protect work first: `tmux new -As work`

*Classify the drop*
- `Broken pipe` / timeout: network, VPN, NAT, or firewall
- `closed by remote host`: sshd, logout policy, shutdown, or reboot
- Drops while actively typing: not an idle timeout
- Note the exact message and elapsed time

*Client*
- Connect: `vm-manage ssh john-highmem`
- Keepalives: `ServerAliveInterval=30`, `ServerAliveCountMax=6`, `TCPKeepAlive=yes`
- Debug once: add `-vvv` after the `az ssh vm ... --`
- Keepalives prevent idle expiry; they cannot survive a TCP reset

*Remote: inspect after reconnect*
```bash
echo "TMOUT=${TMOUT-unset}"
sudo sshd -T | grep -Ei 'clientalive|tcpkeepalive'
sudo journalctl -b -u ssh -u sshd --since '-30 min'
sudo grep -R -E 'StopIdleSessionSec|IdleAction' /etc/systemd/logind.conf /etc/systemd/logind.conf.d 2>/dev/null
last -x | head
uptime -s
```

`TMOUT=1200` means a 20-minute shell timeout. Find its source:
```bash
grep -R 'TMOUT' ~/.profile ~/.bashrc ~/.zshrc /etc/profile /etc/profile.d 2>/dev/null
```
Remove a user-owned setting; an `/etc` or read-only setting is an admin policy.
`StopIdleSessionSec=20min` is the systemd equivalent.

*Remote: SSH keepalives*
```bash
sudoedit /etc/ssh/sshd_config.d/99-keepalive.conf
```
```text
ClientAliveInterval 30
ClientAliveCountMax 6
TCPKeepAlive yes
```
```bash
sudo sshd -t
sudo systemctl reload ssh || sudo systemctl reload sshd
sudo sshd -T | grep -Ei 'clientalive|tcpkeepalive'
```

*If it still drops*
- Reattach: `tmux attach -t work`
- Ask admins about a 20-minute VPN/SSO/session policy or VM maintenance
- Consider `mosh` if UDP is allowed; it survives network changes
