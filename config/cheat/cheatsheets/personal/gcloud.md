# what projects can I use?
gcloud projects list

# change to another project
gcloud config set project <PROJECT-ID>

# see details of current project
gcloud config list

---

# INITIALIZE!
yay -S google-cloud-sdk --noconfirm

# set "disable_updater": false in /opt/google-cloud-sdk/lib/googlecloudsdk/core/config.json and then manage components using gcloud components <command>:
sudo gcloud components install pubsub-emulator

gcloud init
# gcloud auth login  # redundant?
gcloud auth application-default login

# Get IP address for an instance
gcloud compute instances list

# Start an instance
gcloud compute instances start example-instance-1 example-instance-2

# Stop an instance
gcloud compute instances stop example-instance-1 example-instance-2

