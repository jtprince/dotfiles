
1. jupyter-install-nbextensions

    That will install the extensions and install css js stuff. Effectively:

        pip install jupyter_contrib_nbextensions

        # you may also need to try without --user
        jupyter contrib nbextension install --user
        jupyter contrib nbextension install

2. Make sure you're using a NOTEBOOK (doesn't work on lab).

3. Make sure you have isort <5 installed.



