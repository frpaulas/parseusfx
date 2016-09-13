ExUnit.start
defmodule BibleTest do
  import Bible
  use ExUnit.Case

  setup_all do
    Bible.reset
  end

  test "sanity" do
    assert true, "insane if fails"
  end

  test "identity" do
    keys = Bible.identity |> Map.keys
    assert keys |> length == 8
    assert keys |> Enum.find_index( &(&1 == :paragraph))
    assert keys |> Enum.find_index( &(&1 == :open_tag))
    assert keys |> Enum.find_index( &(&1 == :close_tag))
    assert keys |> Enum.find_index( &(&1 == :temp_s))
    assert keys |> Enum.find_index( &(&1 == :stack))
    assert keys |> Enum.find_index( &(&1 == :verse))
    assert keys |> Enum.find_index( &(&1 == :book))
    assert keys |> Enum.find_index( &(&1 == :chap))
  end

  test "current" do
    x = Bible.identity.paragraph
    assert Bible.current == x
  end

  test "next" do
    x = identity.paragraph
    assert Bible.next == x + 1
  end

  test "push book" do
    old_stack = identity.stack
    assert old_stack |> is_list
    push("book")
    assert identity.stack == ["book"|old_stack]
    revise :book, name: "TEST"
    assert identity.book.name == "TEST"
    push("book")
    assert identity.book.name == ""
  end

  test "push chap" do
    old_stack = identity.stack
    assert old_stack |> is_list
    push("chap")
    assert identity.stack == ["chap"|old_stack]
    revise :chap, chap: 999
    assert identity.chap.chap == 999
    push("chap")
    assert identity.chap.chap == 0
  end

  test "push verse" do
    old_stack = identity.stack
    assert old_stack |> is_list
    push("verse")
    assert identity.stack == ["verse"|old_stack]
    revise :verse, book: "TEST"
    assert identity.verse.book == "TEST"
    push("verse")
    assert identity.verse.book == ""
  end

  test "pop" do
    old_stack = identity.stack
    assert old_stack |> is_list
    push("book")
    assert identity.stack == ["book" | old_stack]
    assert pop == "book"
    assert identity.stack == old_stack
  end

  test "top" do
    push("book")
    assert top == "book"
    assert identity.stack |> hd == "book"
  end

  test "book?" do
    push("book")
    assert book?
    pop
    push("chap")
    refute book?
  end

  test "chap?" do
    push("chap")
    assert chap?
    pop
    push("book")
    refute chap?
  end

  test "verse?" do
    push "verse"
    assert verse?
    pop
    push "book"
    refute verse?
  end

  test "quote?" do
    push "quote"
    assert quote?
    pop
    push "quote2"
    assert quote?
    pop
    push "book"
    refute verse?
  end

  test "revise :book" do
    old_book = identity.book
    new_key = "new_" <> old_book.key
    new_book = revise(:book, key: new_key )
    assert identity.book.key == new_key
  end

  test "revise :book, multiple values" do
    old_book = identity.book
    new_key = "new_" <> old_book.key
    new_name = "new_" <> old_book.name
    new_book = revise(:book, key: new_key, name: new_name, blork: "duh" )
    assert identity.book.key == new_key
    assert identity.book.name == new_name
    assert_raise KeyError, fn -> identity.book.blork end
  end

  test "revise :chap" do
    old_chap = identity.chap
    new_key = "new_" <> old_chap.key
    new_chap = revise(:chap, key: new_key )
    assert identity.chap.key == new_key
  end

  test "revise :chap, multiple values" do
    old_chap = identity.chap
    new_key = "new_" <> old_chap.key
    new_n = old_chap.chap + 99
    new_chap = revise(:chap, key: new_key, chap: new_n, blork: "duh" )
    refute new_chap == old_chap
    assert identity.chap.key == new_key
    assert identity.chap.chap == new_n
    assert_raise KeyError, fn -> identity.chap.blork end
  end

  test "revise :verse" do
    old_vs = identity.verse
    new_book = "new_" <> old_vs.book
    revise(:verse, book: new_book )
    assert identity.verse.book == new_book
  end

  test "revise :verse, multiple values" do
    old_vs = identity.verse
    new_book = "new_" <> old_vs.book
    new_chap = old_vs.chap + 1
    revise(:verse, book: new_book, chap: new_chap, blork: "duh" )
    assert identity.verse.book == new_book
    assert identity.verse.chap == new_chap
    assert_raise KeyError, fn -> identity.verse.blork end
  end

  test "revise_text(\"book with text\")" do
    val = "book with text"
    old_text = identity.temp_s
    revise_text val
    assert identity.temp_s == old_text <> " " <> val
  end

  test "revise_text(\"<tag>\")" do
    val = "<tag>"
    old_text = identity.temp_s
    revise_text val
    assert identity.temp_s == old_text <> val
  end

  test "revise_text(:book)" do
    push :book
    val = "some text"
    ot = "<p>"
    ct = "</p>"
    clear_tags
    open_tag ot
    close_tag ct
    revise_text val
    text = identity.temp_s
    revise_text :book
    [new_ot, new_text, new_ct] = identity.book.info |> List.last
    assert new_text == text
    assert new_ot == ot
    assert new_ct == ct
    assert identity.temp_s == ""
    assert identity.open_tag == ""
    assert identity.close_tag == ""
  end

  test "book, get_text" do
    push "book"
    val = "some text"
    Bible.revise :book, info: val
    assert get_text == val
  end

  test "chap, get_text" do
    push "chap"
    val = "some text"
    Bible.revise :chap, info: val
    assert get_text == val
  end

  test "verse, get_text" do
    push "verse"
    val = "some text"
    Bible.revise :verse, info: val
    assert get_text == val
  end

  test "book, clear_text" do
    push "book"
    val = "some text"
    Bible.revise :book, info: val
    assert get_text == val
    clear_text
    assert get_text == []
  end

  test "chap, clear_text" do
    push "chap"
    val = "some text"
    Bible.revise :chap, info: val
    assert get_text == val
    clear_text
    assert get_text == []
  end

  test "verse, clear_text" do
    push "verse"
    val = "some text"
    Bible.revise :verse, info: val
    assert get_text == val
    clear_text
    assert get_text == []
  end

  test "open_tag" do
    p = ~s(<p sfm="ip">)
    open_tag p
    assert identity.open_tag == p
    q = "<q>"
    open_tag q
    assert identity.open_tag == p <> q
  end

  test "close_tag" do
    q = "</q>"
    p = "</p>"
    close_tag q
    assert identity.close_tag == q
    close_tag p
    assert identity.close_tag == q <> p
  end

end