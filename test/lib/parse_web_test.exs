ExUnit.start
defmodule ParseWebTest do
  import ParseWeb
  use ExUnit.Case
  
  @vs_text  "In the beginning, God <f caller=\"+\"> <fr>1:1 </fr> <ft>The Hebrew word rendered “God” is “אֱלֹהִ֑ים” (Elohim).</ft> </f> created the heavens and the earth. "
  @vs_tag "<v id=\"1\" bcv=\"GEN.1.1\" />"
  @vs_end_tag "<ve />"
  @vs [@vs_tag, @vs_text, @vs_end_tag]
  @vs_raw @vs_tag <> @vs_tag <> @vs_end_tag
  @vs_tup {99, @vs_raw}
  @c_tag "<c id=\"99\" />"

  setup_all do
    Bible.reset
  end

  test  "sanity" do
    assert true, "insane if fails"
    assert is_list(@vs)
  end

  test "get_chapter_number" do
    assert get_chapter_number(@c_tag) == 99
  end

  test "vs_text gets verse text", do: assert vs_text(@vs) ==  @vs_text
  test "vs_tag gets verse tag", do: assert vs_tag(@vs) == @vs_tag
  test "bcv_string returns bcv string", do: assert bcv_string(@vs_tag) == "GEN.1.1"
  test "vs_bcv returns {book, chapter, verse_number}" do
    assert vs_bcv(@vs) == {"GEN.1.1", "GEN", 1, 1}
  end

  test "map_vs returns proper map" do
    map = init_vs(@vs)
    assert map |> is_map
    assert map.book == "GEN"
    assert map.chap == 1
    assert map.vs_num == 1
    assert map.bcv == "GEN.1.1"
    assert map.para |> is_integer
  end

  test "simple tokenize" do
    assert tokenize("<p>") == ["<p>"]
    assert tokenize("</p> <p>") == ~w(</p> <p>)
  end

  test "tokenize more complex vss 1" do
    vs =  "<v id=\"6\" bcv=\"GEN.3.6\" />When testing<ve />"
    assert tokenize(vs) == ["<v id=\"6\" bcv=\"GEN.3.6\" />", "When", "testing", "<ve />"]
  end
  test "tokenize more complex vss 2" do
    vs =   "<v id=\"13\" bcv=\"GEN.3.13\" />“What done?” </p> <p>The woman” <ve />"
    assert tokenize(vs) == ["<v id=\"13\" bcv=\"GEN.3.13\" />", "“What", "done?”", "</p>", "<p>", "The", "woman”", "<ve />"]
  end


  test "parse_tag" do
    assert parse_tag(~s(<v id="16" bcv="2MA.2.16" />)) == [id: 16, bcv: "2MA.2.16"]
    assert parse_tag(~s(<p sfm="ip">)) == [sfm: "ip"]
  end

  test "attr_val" do
    assert attr_val(~s(id="16")) == {:id, 16}
    assert attr_val(~s(bcv="2MA.2.16")) == {:bcv, "2MA.2.16"}
  end

  test "interpret paragraph with attr" do
    ot = ~s(<p sfm="ip">)
    text = "some text\n"
    ct = "</p>"
    s = ot<>text<>ct
    tokens = tokenize(s)
    Bible.push "book"
    list = interpret tokens, []
    IO.puts ">>>>> TEST IDENTITY: #{inspect Bible.identity}"
    [new_ot, new_text, new_ct] = Bible.identity.book.info |> List.last
    assert new_ot == ot
    assert new_text == text
    assert new_ct == ct

  end
end
