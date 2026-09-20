.PHONY: validate configure-desktop configure-server build-desktop build-server clean

validate:
	./scripts/validate.sh

configure-desktop:
	./scripts/configure.sh desktop

configure-server:
	./scripts/configure.sh server

build-desktop:
	sudo ./scripts/build.sh desktop

build-server:
	sudo ./scripts/build.sh server

clean:
	./scripts/clean.sh all
