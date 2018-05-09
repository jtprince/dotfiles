ps -e | grep urxvtd | cut --delimiter=' ' -f 3 | (read ps; kill -s KILL "$ps")
urxvtd --quiet --opendisplay --fork
