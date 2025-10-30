
# Conservation mode keeps the laptop to 55-60% of capacity

# Check for that the ideapad_laptop kernel mod is loaded:
sudo lsmod | grep ideapad_laptop

# enable conservation mode:
sudo bash
# then:
echo 1 > /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode

# to see if in conservation mode:
cat /sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode
