defmodule FolkDiscordBot.MemberTest do
  use ExUnit.Case, async: true

  alias FolkDiscordBot.Member

  @roles %{1 => %{name: "folk-system-havers"}, 2 => %{name: "other"}}

  test "true when the member has the role" do
    assert Member.has_role_in?(%{roles: [2, 1]}, @roles, "folk-system-havers")
  end

  test "false when the member lacks the role" do
    refute Member.has_role_in?(%{roles: [2]}, @roles, "folk-system-havers")
  end

  test "false when the member has no roles" do
    refute Member.has_role_in?(%{roles: []}, @roles, "folk-system-havers")
  end

  test "ignores role ids missing from the guild" do
    refute Member.has_role_in?(%{roles: [99]}, @roles, "folk-system-havers")
  end
end
