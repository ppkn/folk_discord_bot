defmodule DokuwikiApi do
  def append_page(page, text) do
    body = %{page: page, text: text}

    case request("core.appendPage", body) do
      {:ok, %Req.Response{body: %{"result" => true}}} ->
        :ok

      {:ok, %Req.Response{body: %{"error" => error}}} ->
        {:error, {:dokuwiki_error, error}}

      {:error, error} ->
        {:error, error}
    end
  end

  def save_media(name, base64) do
    body = %{media: name, base64: base64}

    case request("core.saveMedia", body) do
      {:ok, %Req.Response{body: %{"result" => true}}} ->
        :ok

      {:ok, %Req.Response{body: %{"error" => error}}} ->
        {:error, {:dokuwiki_error, error}}

      {:error, error} ->
        {:error, error}
    end
  end

  def version() do
    case request("core.getAPIVersion", %{}) do
      {:ok, %Req.Response{body: body}} ->
        {:ok, body}

      {:error, error} ->
        {:error, error}
    end
  end

  defp base_url(), do: System.fetch_env!("DOKUWIKI_URL")

  defp request(operation, content) do
    Req.post(
      "#{base_url()}/lib/exe/jsonrpc.php/#{operation}",
      auth: {:bearer, token()},
      json: content
    )
  end

  defp token(), do: System.fetch_env!("DOKUWIKI_TOKEN")
end
