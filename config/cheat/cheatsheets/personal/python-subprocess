
cmd = ["ls", "-alh"]

# returns bytes
subprocess.check_output(cmd, text=True)  # -> b'total 76M\ndrwx...'

# returns str
subprocess.check_output("ls -alh", text=True, shell=True)  # -> "total 76M..."
