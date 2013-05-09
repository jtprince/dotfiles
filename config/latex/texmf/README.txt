# http://tex.stackexchange.com/questions/1137/where-do-i-place-my-own-sty-files-to-make-them-available-to-all-my-tex-files
# to include packages in latex, run:

texhash ~/texmf

[[ NOTE: some say this is not necessary to run, just finds them in this dir ]]


https://help.ubuntu.com/community/LaTeX#Add_on_packages

    Installing packages manually
    If a package you desire is not in Ubuntu's repositories, you may look on CTAN's web site or TeX Catalogue Online to see if they have the package. If they do, download the archive containing the files. In this example, we'll install example package foo, contained in foo.tar.gz.

    Once foo.tar.gz has finished downloading, we unzip it somewhere in our home directory:


    tar xvf foo.tar.gz

    This expands to folder foo/. We cd into foo/ and see foo.ins. We now run LaTeX on the file:


    latex foo.ins

    This will generate foo.sty. We now have to copy this file into the correct location. This can be done in two ways. After these, you can use your new package in your LaTeX document by inserting \usepackage{foo} in the preamble.

    User install

    We will copy this into our personal texmf tree. The advantages of this solution are that if we migrate our files to a new computer, we will remember to take our texmf tree with us, resulting in keeping the same packages we had. The disadvantages are that if multiple users want to use the same packages, the tree will have to be copied to each user's home folder.

    We'll first create the necessary directory structure:


    cd ~
    mkdir -p texmf/tex/latex/foo

    Notice that the final directory created is labeled foo. It is a good idea to name directories after the packages they contain. The -p attribute to mkdir tells it to create all the necessary directories, since they don't exist. Now, using either the terminal, or the file manager, copy foo.sty into the directory labeled foo.

    Now, we must make LaTeX recognize the new package:

    texhash ~/texmf

    System install

    We will copy the foo to the LaTeX system tree. The advantages are that every user on the computer can access these files. The disadvantages are, that the method uses superuser privileges, and in a possible reformat/reinstall you have to repeat the procedure.

    First, go to the folder your foo is located. The following commands will create a new directory for your files and copy it to the new folder:


    sudo mkdir /usr/share/texmf/tex/latex/foo
    sudo cp foo.sty /usr/share/texmf/tex/latex/foo

    Then update the LaTeX package cache:

    sudo texhash
