NODEHACK_IMAGE=mgoltzsche/nodehack:latest

image:
	docker build --force-rm -t $(NODEHACK_IMAGE) -f build/Dockerfile .
