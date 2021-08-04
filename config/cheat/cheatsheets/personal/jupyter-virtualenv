

# Inside your virtualenv:
pip install ipykernel

# Since fullpath to current virtualenv should be defined in env variable $VIRTUAL_ENV
# Then you can do this (sudo is necessary if jupyter is system installed)
sudo python -m ipykernel install --name=$(basename $VIRTUAL_ENV)


Good resource:
https://towardsdatascience.com/create-virtual-environment-using-virtualenv-and-add-it-to-jupyter-notebook-6e1bf4e03415


# conda jupyter

https://stackoverflow.com/questions/58068818/how-to-use-jupyter-notebooks-in-a-conda-environment

Easiest:

# Run Jupyter server and kernel inside the conda environment

conda create -n my-conda-env         # creates new virtual env
conda activate my-conda-env          # activate environment in terminal
conda install jupyter                # install jupyter + notebook
jupyter notebook                     # start server + kernel
