################# Azure ###############
# Dictionary of VM configurations
declare -A azure_vms
azure_vms=(
    ["normal"]="data-science-dev-ncus-rg-01:shaurya-dev-vm"
    ["bigboi"]="data-science-dev-ncus-rg-01:shaurya-bigboi-vm"
)

# Unalias any existing commands
unalias vmstart 2>/dev/null
unalias vmstop 2>/dev/null
unalias vminfo 2>/dev/null

function vmstart() {
    if [[ -z "$1" ]]; then
        echo "Usage: vmstart <vm-name>"
        return 1
    fi
    
    vm_config="${azure_vms[$1]}"
    if [[ -z "$vm_config" ]]; then
        echo "Unknown VM name: $1"
        return 1
    fi
    
    resource_group="${vm_config%%:*}"
    vm_name="${vm_config#*:}"
    
    # renew certificate
    refresh-azure-cert "$resource_group" "$vm_name"
    # start vm
    az vm start --resource-group "$resource_group" --name "$vm_name"
}

function vmstop() {
    if [[ -z "$1" ]]; then
        echo "Usage: vmstop <vm-name>"
        return 1
    fi
    
    vm_config="${azure_vms[$1]}"
    if [[ -z "$vm_config" ]]; then
        echo "Unknown VM name: $1"
        return 1
    fi
    
    resource_group="${vm_config%%:*}"
    vm_name="${vm_config#*:}"
    
    az vm stop -g "$resource_group" -n "$vm_name" --no-wait
}

function vminfo() {
    if [[ -z "$1" ]]; then
        echo "Usage: vminfo <vm-name>"
        return 1
    fi
    
    vm_config="${azure_vms[$1]}"
    if [[ -z "$vm_config" ]]; then
        echo "Unknown VM name: $1"
        return 1
    fi
    
    resource_group="${vm_config%%:*}"
    vm_name="${vm_config#*:}"
    
    az vm get-instance-view -g "$resource_group" -n "$vm_name" --query instanceView.statuses[1].displayStatus
}

function refresh-azure-cert() {
    resource_group="$1"
    vm_name="$2"
    actual_name="${resource_group}-${vm_name}"
    config_file="$HOME/.ssh/azure_vm_config"
    ssh_key_dir="$HOME/.ssh/az_ssh_config/${resource_group}-${vm_name}"

    # Remove old config and keys if they exist
    rm -rf "$ssh_key_dir" "$config_file"

    # Generate new SSH config without prompting for overwrites
    az ssh config --vm-name "$vm_name" --resource-group "$resource_group" --prefer-private-ip --file "$config_file"

    # Verify the config file was generated
    if [[ ! -f "$config_file" ]]; then
        echo "Error: SSH config file was not generated."
        return 1
    fi

    # Find the exact Host line with $actual_name and replace it with "Host vm"
    awk -v actual_name="$actual_name" '
        $1 == "Host" && $2 == actual_name { $2 = "vm" }
        { print }
    ' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
}
