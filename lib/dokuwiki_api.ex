defmodule DokuwikiApi do
  def append_page(page, text) do
    "core.appendPage"
    |> request(%{page: page, text: text})
    |> expect_true_result()
  end

  def save_media(name, base64) do
    "core.saveMedia"
    |> request(%{media: name, base64: base64})
    |> expect_true_result()
  end

  defp base_url(), do: System.fetch_env!("DOKUWIKI_URL")

  defp request(operation, content) do
    Req.post(
      "#{base_url()}/lib/exe/jsonrpc.php/#{operation}",
      auth: {:bearer, token()},
      json: content
    )
  end

  defp expect_true_result({:ok, %Req.Response{body: %{"result" => true}}}), do: :ok

  defp expect_true_result({:ok, %Req.Response{body: %{"error" => error}}}),
    do: {:error, {:dokuwiki_error, error}}

  defp expect_true_result({:ok, %Req.Response{status: status}}),
    do: {:error, {:unexpected_response, status}}

  defp expect_true_result({:error, _} = error), do: error

  defp token(), do: System.fetch_env!("DOKUWIKI_TOKEN")
end
