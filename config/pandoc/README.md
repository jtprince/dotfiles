https://github.com/tajmone/pandoc-goodies/tree/master/templates/html5/github

The template should already be in the proper location (pandoc --version for
data directory)

Add this 
```
--template=GitHub.html5 FILENAME.md
```

If your document relies on external resources (images, additional CSS files,
etc), then also add:

```
--self-contained
```
