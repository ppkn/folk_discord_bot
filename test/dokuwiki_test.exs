defmodule DokuWikiTest do
  use ExUnit.Case, async: true

  describe "new/1" do
    test "builds the JSON-RPC base url" do
      assert {:ok, wiki} = DokuWiki.new(base_url: "https://wiki.test", token: "token")
      assert wiki.options.base_url == "https://wiki.test/lib/exe/jsonrpc.php"
    end

    test "ignores a trailing slash on the base url" do
      assert {:ok, wiki} = DokuWiki.new(base_url: "https://wiki.test/", token: "token")
      assert wiki.options.base_url == "https://wiki.test/lib/exe/jsonrpc.php"
    end

    test "returns an error when config is missing or empty" do
      assert DokuWiki.new(token: "token") == {:error, {:missing_config, :base_url}}

      assert DokuWiki.new(base_url: "https://wiki.test", token: "") ==
               {:error, {:missing_config, :token}}
    end
  end
end
