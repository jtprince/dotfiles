
# pem is not actually a standard, but it typically means that base64 information
# is embedded in a file (usually with some headers). Anything can be in 'pem' format.

# generate a pem file from a PUBLIC ssh key:
ssh-keygen -f id_rsa.pub -m pem -e > id_rsa.public.pem

# generate a pem file from your PRIVATE ssh key (it's already in PEM format!)
cp id_rsa id_rsa.pem
