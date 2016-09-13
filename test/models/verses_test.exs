ExUnit.start
defmodule VersesTest do
  import Worldenglishbible.Verses
  use ExUnit.Case
  alias Worldenglishbible.Verses

  test "sanity" do
    assert true, "insane if fails"
  end

  test "update one field" do
    vss = Verses.new
    new_book = Verses.revise(vss, book: "GEN")
    assert  new_book.book == "GEN"
    assert true
  end

  test "update multiple fields" do
    vss = Verses.new
    new_book = Verses.revise(vss, [book: "GEN", chap: 99, blork: "duh"])
    assert new_book.book == "GEN"
    assert new_book.chap == 99
    assert_raise KeyError, fn -> new_book.blork end
  end
end