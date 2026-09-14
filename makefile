-include .env

start:
	@cd llama && \
	./llama serve \
	--api-key "${API_KEY}" \
	--gpu-layers all \
	--ctx-size ${CONTEXT_SIZE} \
	--tools all \
	--models-dir ../models \
	--no-ui

start-ui:
	@cd llama && \
	./llama serve \
	--api-key "${API_KEY}" \
	--gpu-layers all \
	--ctx-size ${CONTEXT_SIZE} \
	--tools all \
	--models-dir ../models \
	--ui

init:
	@v init.vsh

install-high:
	@cd llama && \
	./llama download --hf-repo openbmb/MiniCPM5-2B-GGUF:Q8_0

install-low:
	@cd llama && \
	./llama download --hf-repo openbmb/MiniCPM5-2B-GGUF:Q4_K_M

install-high-fast:
	@aria2c \
	--max-connection-per-server ${SPLIT_COUNT} \
	--split ${SPLIT_COUNT} \
	https://huggingface.co/openbmb/MiniCPM5-2B-GGUF/resolve/main/MiniCPM5-2B-Q8_0.gguf?download=true \
	--out ./models/MiniCPM5-2B-Q8_0.gguf

install-low-fast:
	@aria2c \
	--max-connection-per-server ${SPLIT_COUNT} \
	--split ${SPLIT_COUNT} \
	https://huggingface.co/openbmb/MiniCPM5-2B-GGUF/resolve/main/MiniCPM5-2B-Q4_K_M.gguf?download=true \
	--out ./models/MiniCPM5-2B-Q4_K_M.gguf
