ARG ELIXIR_IMAGE=elixir:1.19-otp-27-slim

FROM ${ELIXIR_IMAGE} AS build
RUN apt-get update -y && apt-get install -y build-essential git && rm -rf /var/lib/apt/lists/*
WORKDIR /app
ENV MIX_ENV=prod
RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
COPY config config
RUN mix deps.compile

COPY lib lib
RUN mix release

FROM ${ELIXIR_IMAGE}
RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses6 ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
ENV MIX_ENV=prod
COPY --from=build /app/_build/prod/rel/folk_discord_bot ./
CMD ["bin/folk_discord_bot", "start"]
