# dot2gdf
A script to transform a .dot file into a .gdf file.

`dot2gdf` takes a [Graphviz](http://www.graphviz.org/) .dot file created with [markusos/site-mapper](https://github.com/markusos/site-mapper) into a [GUESS](http://graphexploration.cond.org/) .gdf file.

This .gdf file can then be imported into [Gephi](https://gephi.org/) to explore data and relationships.

## Exported features
| Feature | Extracted from | Example |
|---------|----------------|--------|
| node name (or id) | node id | httpmywebsitethefirstpage
| path | node label | /the-first-page |
| title | node label | The first page |
| count of links from the node | computed from the list of links | 12 |
| count of links to the node | computed from the list of links | 10 |
