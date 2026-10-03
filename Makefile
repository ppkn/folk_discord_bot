start:
	source .env && iex -S mix

setup: .env

.env:
	cp .env.sample .env

clean:
	rm .env

.PHONY: test
test:
	mix test

deploy:
	fly deploy

remote:
	fly ssh console --pty -C "/app/bin/folk_discord_bot remote"
