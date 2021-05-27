#!/usr/bin/bash

if [ -d /usr/local/cuda -a -d /usr/local/cuda-10.2 ]; then
    export PATH=/usr/local/cuda/bin:${PATH:+$PATH}
    export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/usr/local/cuda-10.2/lib64
fi
