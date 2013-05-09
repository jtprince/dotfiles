
latex is a frickin' mess.  This is a straightforward path to sanity:

== Use XeTeX (xelatex)

You want to use xelatex because it includes complete ttf font support and
assumes your files are written in UTF-8 (which they are).  It is superior to
pdflatex.

For ubuntu, it is found in this package:

    sudo apt-get install texlive-xetex

    xelatex <myfile>.tex

== Get the commonly used styles and such from your distro packages

    sudo apt-get install texlive-latex-recommended texlive-science texlive-fonts-recommended texlive-fonts-extra

== Store style files and bibstyles in expected places

~/texmf is a very structured folder

The directory pointed to by the user specified TEXINPUTS env var is much less
structured and can just take .sty files inside in basically any arrangement

I currently use both.

For proper configuration, link texmf to ~/texmf and bst to ~/.config/bst

.bst files must be in the base ~/.config/bst directory (no nested dirs)

== Use an autoupdater

I wrote a simple script that relies on inotify that will recreate the pdf each
time you save your file:
https://gist.github.com/2956565

execute_on_modify.rb <file>.tex xelatex {{}}

evince will autoload the pdf anytime it changes.  Now, you edit away and each
time you save the pdf will automatically update on your screen with no effort
on your part.

== Where to put your own files (mine are softlinked to a Dropbox directory)

Put your own files here:

~/texmf/tex/latex/<name>/<name>.sty

