start:
	source .env && iex -S mix

setup: .env

.env:
	cp .env.sample .env

clean:
	rm .env
