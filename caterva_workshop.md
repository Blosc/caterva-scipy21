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

1. Background
1. Introduction
1. Double partitioning. Slicing performance
1. No type information
1. Metalayers. ironArray
1. Multiple formats
1. Future Work

+++ {"slideshow": {"slide_type": "slide"}}

## Background

Talk about chunking, compression...

Describe some real-world use cases where these concepts are used.

+++ {"slideshow": {"slide_type": "slide"}}

## Introduction

Describe Caterva

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
import caterva
import numpy as np
import zarr
import caterva as cat

%load_ext memprofiler
```

```{code-cell} ipython3
shape = (8_000, 8_000)
chunks = (500, 50)
blocks = (500, 10)
dtype = np.dtype("f8")
itemsize = dtype.itemsize
```

+++ {"slideshow": {"slide_type": "slide"}}

## Getting items

```{code-cell} ipython3
data = np.arange(np.prod(shape), dtype=dtype).reshape(shape)
```

```{code-cell} ipython3
---
slideshow:
  slide_type: subslide
---
c_data = cat.asarray(data, chunks=chunks, blocks=blocks)

c_data.info
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
%%mprof_run -q caterva::id0

for i in planes_id0:
    block = c_data[i, :]
```

```{code-cell} ipython3
---
slideshow:
  slide_type: '-'
---
%%mprof_run -q zarr::id0

for i in planes_id0:
    block = z_data[i, :]
```

```{code-cell} ipython3
---
slideshow:
  slide_type: subslide
---
planes_id1 = np.random.randint(0, shape[1], 100)
```

```{code-cell} ipython3
%%mprof_run -q caterva::id1

for i in planes_id1:
    block = c_data[:, i]
```

```{code-cell} ipython3
---
slideshow:
  slide_type: '-'
---
%%mprof_run -q zarr::id1

for i in planes_id1:
    block = z_data[:, i]
```

```{code-cell} ipython3
---
slideshow:
  slide_type: subslide
---
%mprof_barplot --title "Getting items" --variable time --groupby 1 .*
```

+++ {"slideshow": {"slide_type": "slide"}}

## Setting items

```{code-cell} ipython3
---
slideshow:
  slide_type: '-'
---
c_data = cat.empty(shape, itemsize, chunks=chunks, blocks=blocks)

z_data = zarr.empty(shape, dtype=dtype, chunks=chunks)
```

```{code-cell} ipython3
---
slideshow:
  slide_type: subslide
---
planes_id0 = np.random.randint(0, shape[0], 100)
block_id0 = np.arange(shape[0], dtype=dtype)
```

```{code-cell} ipython3
%%mprof_run -q caterva::id0

for i in planes_id0:
    c_data[i, :] = block_id0
```

```{code-cell} ipython3
---
slideshow:
  slide_type: '-'
---
%%mprof_run -q zarr::id0

for i in planes_id0:
    z_data[i, :] = block_id0
```

```{code-cell} ipython3
---
slideshow:
  slide_type: subslide
---
planes_id1 = np.random.randint(0, shape[1], 100)
block_id1 = np.arange(shape[1], dtype=dtype)
```

```{code-cell} ipython3
%%mprof_run -q caterva::id1

for i in planes_id1:
    c_data[:, i] = block_id1
```

```{code-cell} ipython3
---
slideshow:
  slide_type: '-'
---
%%mprof_run -q zarr::id1

for i in planes_id1:
    z_data[:, i] = block_id1
```

```{code-cell} ipython3
---
slideshow:
  slide_type: subslide
---
%mprof_barplot --variable time --groupby 1 .*
```

+++ {"slideshow": {"slide_type": "slide"}}

## No data type information

PROS

- Lightweight library
- Allow users to define custom data types

+++ {"slideshow": {"slide_type": "subslide"}}

Show the integration with other libraries as numpy

```{code-cell} ipython3
---
slideshow:
  slide_type: '-'
---
import caterva as cat
import numpy as np

shape = (1_000, 1_000)
chunks = (500, 20)
blocks = (200, 10)
dtype = np.dtype("f4")
itemsize = dtype.itemsize

a = cat.empty(shape, itemsize, chunks=chunks, blocks=blocks)

for i in range(shape[0]):
    a[i] = np.linspace(0, 1, shape[1], dtype=dtype)
```

```{code-cell} ipython3
---
slideshow:
  slide_type: subslide
---
b = a[5:7, 5:10]

b.info
```

Talk about plainbuffer backend and the support of buffer and array protocols.

```{code-cell} ipython3
---
slideshow:
  slide_type: subslide
---
c = np.asarray(b)

c
```

Explain that a cast is needed

```{code-cell} ipython3
c = np.asarray(b).view(dtype)

c
```

```{code-cell} ipython3
b[0] = np.arange(5, dtype=dtype)

c
```

Explain the behaviour. Share the same buffer. No copies are made.

+++ {"slideshow": {"slide_type": "slide"}}

## Metalayers

+++ {"slideshow": {"slide_type": "subslide"}}

We create an array with one metalayer storing some info.

```{code-cell} ipython3
---
slideshow:
  slide_type: '-'
---
import caterva as cat
from struct import pack

urlpath = "arr_with_meta.caterva"

shape = (1_000, 1_000)
chunks = (500, 500)
blocks = (10, 250)

meta = {
    b"date": b"01/01/2021"
}

a = cat.full(shape, fill_value=pack("f", 3.14), chunks=chunks, blocks=blocks, meta=meta,
             urlpath=urlpath)
```

```{code-cell} ipython3
---
slideshow:
  slide_type: subslide
---
a = cat.open(urlpath)
```

Get the name of all metalayers on the array:

```{code-cell} ipython3
a.meta.keys()
```

Get the informatrion stored in the *date* metalayer:

```{code-cell} ipython3
assert a.meta.get("date") == a.meta["date"]

a.meta["date"]
```

Update the content of the *date* metalayer. Comment that the length of the metalayer can not change. Use vl-metalayers (in the roadmap).

```{code-cell} ipython3
a.meta["date"] = b"08/01/2021"
try:
    a.meta["date"] = b"8/1/2021"
except ValueError as err:
    print(err)
```

+++ {"slideshow": {"slide_type": "subslide"}}

Caterva introduces by iteself a metalayer storing the multidimensional information. Inspect Caterva metalayer.

```{code-cell} ipython3
---
slideshow:
  slide_type: '-'
---
import msgpack

caterva_meta = msgpack.unpackb(a.meta.get("caterva"))

print(f"Format version: {caterva_meta[0]}")
print(f"N. dimensions: {caterva_meta[1]}")
print(f"Shape: {caterva_meta[2]}")
print(f"Chunks: {caterva_meta[3]}")
print(f"Blocks: {caterva_meta[4]}")

cat.remove(urlpath)
```

+++ {"slideshow": {"slide_type": "subslide"}}

### Iron Array

Description. Introduce a metalayer on TOP of caterva storing the dtype.

```{code-cell} ipython3
# import iarrayce as ia

# Example of use
```
