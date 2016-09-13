ExUnit.start
defmodule BooksTest do
  import Worldenglishbible.Books
  use ExUnit.Case
  alias Worldenglishbible.Books

  test "sanity" do
    assert true, "insane if fails"
  end

  test "update one field" do
    book = Books.new
    new_gen = Books.revise(book, key: "GEN")
    assert  new_gen.key == "GEN"
  end

  test "update multiple fields" do
    book = Books.new
    new_book = Books.revise(book, [key: "GEN", name: "Genesis", blork: "duh"])
    assert new_book.key == "GEN"
    assert new_book.name == "Genesis"
    assert new_book.info == []
    assert_raise KeyError, fn -> new_book.blork end
  end
end