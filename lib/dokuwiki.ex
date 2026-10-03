defmodule DokuWiki do
  @moduledoc """
  A minimal client for the DokuWiki JSON-RPC API.

  Build a client with `new/1`, then pass it to the API functions:

      {:ok, wiki} = DokuWiki.new(base_url: "https://wiki.example.com", token: "...")
      :ok = DokuWiki.append_page(wiki, "namespace:page", "Some text")
  """

  @spec new(keyword()) :: {:ok, Req.Request.t()} | {:error, {:missing_config, atom()}}
  def new(opts) do
    with {:ok, base_url} <- fetch_opt(opts, :base_url),
         {:ok, token} <- fetch_opt(opts, :token) do
      {:ok, Req.new(base_url: base_url <> "/lib/exe/jsonrpc.php", auth: {:bearer, token})}
    end
  end

  def append_page(client, page, text) do
    client
    |> request("core.appendPage", %{page: page, text: text})
    |> expect_true_result()
  end

  def save_media(client, name, base64) do
    client
    |> request("core.saveMedia", %{media: name, base64: base64})
    |> expect_true_result()
  end

  defp fetch_opt(opts, key) do
    case Keyword.get(opts, key) do
      value when value in [nil, ""] -> {:error, {:missing_config, key}}
      value -> {:ok, value}
    end
  end

  defp request(client, operation, content) do
    Req.post(client, url: "/#{operation}", json: content)
  end

  defp expect_true_result({:ok, %Req.Response{body: %{"result" => true}}}), do: :ok

  defp expect_true_result({:ok, %Req.Response{body: %{"error" => error}}}),
    do: {:error, {:dokuwiki_error, error}}

  defp expect_true_result({:ok, %Req.Response{status: status}}),
    do: {:error, {:unexpected_response, status}}

  defp expect_true_result({:error, _} = error), do: error
end
