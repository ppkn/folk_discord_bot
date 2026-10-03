defmodule FolkDiscordBot.MemberTest do
  use ExUnit.Case, async: true

  alias FolkDiscordBot.Member

  @guild %{roles: %{1 => %{name: "folk-system-havers"}, 2 => %{name: "other"}}}

  test "true when the member has the role" do
    assert Member.has_role?(%{roles: [2, 1]}, @guild, "folk-system-havers")
  end

  test "false when the member lacks the role" do
    refute Member.has_role?(%{roles: [2]}, @guild, "folk-system-havers")
  end

  test "false when the member has no roles" do
    refute Member.has_role?(%{roles: []}, @guild, "folk-system-havers")
  end

  test "ignores role ids missing from the guild" do
    refute Member.has_role?(%{roles: [99]}, @guild, "folk-system-havers")
  end
end
