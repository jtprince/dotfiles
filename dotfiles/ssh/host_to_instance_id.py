from pathlib import Path
from typing import Dict


def get_ssh_host_to_instance_id(ssh_config_path: Path) -> Dict[str, str]:
    """Reads in the .ssh/config file and returns host to instance id.

    Expects:

    1. Hosts are separated by at least one newline.
    2. The config file is annotated with a commented line containing
       `InstanceId` with the last space-delimited item on that line
       being the instance id.

    Example ssh config:

    Host john-ec2-128
        User ubuntu
        HostName 172.31.76.11
        IdentityFile ~/.ssh/JohnPrinceKeyAlphaRSA.pem
        # InstanceId i-0939be1dbff1d331b

    get_ssh_host_to_instance_id(Path.home() / ".ssh/config") # ->
        {"john-ec2-128": "i-0939be1dbff1d331b"}
    """
    # TODO: make more robust
    sections = ssh_config_path.read_text().split("\n\n")
    host_to_instance = {}
    for section in sections:
        host = None
        instance_id = None
        lines = section.strip().split("\n")
        for line in lines:
            if line.startswith("Host"):
                host = line.strip().split()[-1]
            elif "InstanceId" in line:
                instance_id = line.strip().split()[-1]
        if host and instance_id:
            host_to_instance[host] = instance_id
    return host_to_instance
