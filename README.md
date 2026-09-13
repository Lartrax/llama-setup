# A ***[***`small`, `portable`, `quick`, `easy`***]*** llama.cpp setup

### Installing
Download or clone the repo. Then navigate inside.
```
git clone git@github.com:Lartrax/llama-setup.git
```

If you have [V](https://vlang.io) installed then just run
```
make init
```
to download llama.cpp and set up the default environment.

If you don't have V installed, either [install it](https://github.com/vlang/v) or grab a precompiled `init` file from [Releases](https://github.com/Lartrax/llama-setup/releases) and put it inside the root of the repo. Then run the `make` command above.

### Next steps
#### Install a model
```sh
make install-low   # min 2 GB v/ram available
make install-high  # min 4 GB v/ram available
```  
With aria2c installed:
```sh
make install-low-fast
make install-high-fast
```
#### Start a server
```sh
make start-ui  # http://localhost:8080
make start     # http://localhost:8080/v1
```
#### Modify environment (.env)
```.env
# Example .env
API_KEY=       # Defaults to 64 char hex key (512bit)
CONTEXT_SIZE=0 # 0 for full context, 8k-64k for 2-6 GB v/ram
SPLIT_COUNT=16 # How many connections to use with aria2c. Defaults to 16x speedup.
```

### Notes

This project only ships the `MiniCPM5-2B` model through make commands.  
If you need other models refer to the [llama.cpp docs](https://llama.app/docs/quickstart) on how to install via command line. Make sure to navigate to the `llama` folder before issuing commands to llama.cpp.

Huggingface severely throttles connections, so I recommend using [aria2c](https://aria2.github.io/) to download the models directly. With aria2c you can split the connection and download more of the project at a time. Say with 2 connections. One would download from 0-50% and the other would at the same time download from 50-100%.
```make
# Example from makefile:
aria2c \
	--max-connection-per-server 16 \
	--split 16 \
	https://huggingface.co/openbmb/MiniCPM5-2B-GGUF/resolve/main/MiniCPM5-2B-Q8_0.gguf?download=true \
	--out ./models/MiniCPM5-2B-Q8_0.gguf
```
When downloading directly put the output file into the `models` directory at the root of the repo. This ensures that the models are where the server expects them to be.
