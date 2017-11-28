+++
title = "Generating image mosaics in Go"
date = "2017-11-25T13:54:46-05:00"
draft = true
+++

In this article, I'll describe how my [Mosaic Generator](https://mosaic.pcfbeta.io/) works.

---

## What is it?

You provide a source image and a subreddit name. The Mosaic generator will then attempt to recreate your source image using the top N images from that subreddit as tiles.


## Example 