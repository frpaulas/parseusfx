ExUnit.start
defmodule ChaptersTest do
  import Worldenglishbible.Chapters
  use ExUnit.Case
  alias Worldenglishbible.Chapters

  test "sanity" do
    assert true, "insane if fails"
  end

  test "update one field" do
    chap = Chapters.new
    new_chap = Chapters.revise(chap, book: "GEN")
    assert new_chap.book == "GEN"
  end

  test "update multiple fields" do
    chap = Chapters.new
    new_chap = Chapters.revise(chap, [key: "GEN.1", chap: 1, book: "GEN", blork: "duh"])
    assert new_chap.key == "GEN.1"
    assert new_chap.chap == 1
    assert new_chap.book == "GEN"
    assert_raise KeyError, fn -> new_chap.blork end
    refute chap == new_chap
  end
end