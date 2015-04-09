VERSION=1.8
URL=https://nixos.org/releases/nix/nix-$(VERSION)/nix-$(VERSION)-x86_64-linux.tar.bz2
SHA256SUM=52fab207b4ce4d098a12d85357d0353e972c492bab0aa9e08e1600363e76fefb

.PHONY: default

default: nixdock

tmp:
	mkdir -p "$@"

tmp/nix.tar.bz2: tmp
	wget -O tmp/nix.tar.bz2 "$(URL)"
        echo "$(SHA256SUM)  tmp/nix.tar.bz2" | sha256sum -c

tmp/nix-archive: tmp/nix.tar.bz2
	mkdir -p "$@"
	tar --strip-components 1 -C tmp/nix-archive -xjf tmp/nix.tar.bz2

nixdock: tmp/nix-archive
	docker build -t nixdock .

available: nixdock
	docker login
	docker tag nixdock jeanfric/nixdock:latest
	docker push jeanfric/nixdock:latest
	docker tag nixdock jeanfric/nixdock:$(VERSION)
	docker push jeanfric/nixdock:$(VERSION)
