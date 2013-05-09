# expects an install into wine: http://www.docu-track.com/product/pdf-xchange-viewer

echo "attempting to open $1"
$HOME/Dropbox/env/pdfx/PDFXCview.exe $1 &
