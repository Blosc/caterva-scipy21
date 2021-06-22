---
jupytext:
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.11.3
kernelspec:
  display_name: Python 3
  language: python
  name: python3
---

+++ {"slideshow": {"slide_type": "slide"}}

# Caterva: a multidimensional container with double partitioning

The Blosc Developers. SciPy Conference 2021.

+++ {"slideshow": {"slide_type": "slide"}}

## Who we are?

TODO

+++ {"slideshow": {"slide_type": "slide"}}

## Poster Outline

1. Introduction
1. No type information
1. Double partitioning. Slicing performance
1. Metalayers. ironArray
1. Multiple formats
1. Future Work

+++ {"slideshow": {"slide_type": "fragment"}}

Build using a myst file.

+++ {"slideshow": {"slide_type": "slide"}}

# Introduction

+++ {"slideshow": {"slide_type": "fragment"}}

Caterva intro.

```{code-cell} ipython3
---
slideshow:
  slide_type: fragment
---
import caterva as cat

print(cat.__version__)
```

+++ {"slideshow": {"slide_type": "slide"}}

## Double partitioning

![title](static/two-level-chunking-slice.png)

```{code-cell} ipython3
---
slideshow:
  slide_type: subslide
---
import numpy as np
import zarr
import caterva as cat

%load_ext memprofiler
```

```{code-cell} ipython3
shape = (500, 500, 500)
chunks = (250, 10,  250)
blocks = (50, 10, 50)
dtype = np.dtype("f8")
itemsize = dtype.itemsize

data = np.arange(np.prod(shape), dtype=dtype).reshape(shape)
```

```{code-cell} ipython3
---
slideshow:
  slide_type: subslide
---
from numcodecs import Blosc

z_data = zarr.array(data, chunks=chunks)

z_data.info
```

```{code-cell} ipython3
---
slideshow:
  slide_type: subslide
---
c_data = cat.asarray(data, chunks=chunks, blocks=blocks)

c_data.info
```

+++ {"slideshow": {"slide_type": "subslide"}}

Compression ratios are different due to data organitzation. Explain it!

```{code-cell} ipython3
---
slideshow:
  slide_type: subslide
---
planes_id0 = np.random.randint(0, shape[0], 100)
```

```{code-cell} ipython3
---
slideshow:
  slide_type: '-'
---
%%mprof_run -q zarr::id0

for i in planes_id0:
    block = z_data[i, :, :]
```

```{code-cell} ipython3
%%mprof_run -q caterva::id0

for i in planes_id0:
    block = c_data[i, :, :]
```

```{code-cell} ipython3
---
slideshow:
  slide_type: subslide
---
planes_id1 = np.random.randint(0, shape[1], 100)
```

```{code-cell} ipython3
---
slideshow:
  slide_type: '-'
---
%%mprof_run -q zarr::id1

for i in planes_id1:
    block = z_data[:, i, :]
```

```{code-cell} ipython3
%%mprof_run -q caterva::id1

for i in planes_id1:
    block = c_data[:, i, :]
```

```{code-cell} ipython3
---
slideshow:
  slide_type: subslide
---
planes_id2 = np.random.randint(0, shape[2], 100)
```

```{code-cell} ipython3
---
slideshow:
  slide_type: '-'
---
%%mprof_run -q zarr::id2

for i in planes_id2:
    block = z_data[:, :, i]
```

```{code-cell} ipython3
%%mprof_run -q caterva::id2

for i in planes_id2:
    block = c_data[:, :, i]
```

```{code-cell} ipython3
---
slideshow:
  slide_type: subslide
---
%mprof_barplot --variable time --groupby 1 .*
```
