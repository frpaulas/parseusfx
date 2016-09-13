require IEx
defmodule ParseWeb do
  import Bible

  # astrix: &#42;
  # start of david: &#x2721;
  # dagger: &#8224;
  # dbl dagger: &#8225;
  # section: &sect
  # paragraph: &para
  # parallel: &parallel;
  # chi rho: &#9767;
  @nt_markers ~w( &#9767; &#8224; &#42; &#8225; &sect; &parallel; &para;)
  @ot_markers ~w( &#x2721; &#8224; &#8225; &sect; &parallel; &para;)

  def file_to_list_tags do
    File.read!("data/eng-web_usfx.xml") |> list_tags
    
  end

  def list_tags(s) do
    s
      |> tokenize
      |> Enum.reduce({%{}, %{}}, fn(token, {words, tags})->
        if token |> binary_part(0,1) == "<" do
          tag = token |> String.split |> hd
          {words, tags |> Map.update(tag, 0, &(&1 + 1))}  
        else
          {words |> Map.update(token, 0, &(&1 + 1)), tags}  
        end
  
      end)
  end

  def list_books do
    {:ok, doc} = File.read("data/eng-web_usfx.xml")
    doc
      |> String.replace(~r/\n/, "")
      |> String.replace(~r/\s\s+/, " ") # only single spaces!
      |> String.split(~r/<book.*book>/U, [include_captures: true, trim: true])
      |> Enum.reject(&(&1 == " "))
  end

  def list_chapters(book) do
    book
      |> String.split(~r/<c.*>/U, [include_captures: true, trim: true])
      |> Enum.drop(1) # first has book meta data
      |> Enum.drop_every(2) # every other one is the chapter tag
  end

  def get_chapter_number(chap) do
    chap
    |> String.split(~r/\d+/, [include_captures: true, trim: true]) 
    |> Enum.filter(&(Regex.match?(~r/\d+/, &1)))
    |> hd
    |> String.to_integer
  end

  def list_raw_vss(text) do
    text
      |> String.split(~r/<v.*<ve \/>/U, [include_captures: true, trim: true])
      |> Enum.reject(&(&1 == " "))
      |> Enum.map( &( String.strip(&1) ) )
      |> list_raw_vss([])
  end

  def list_raw_vss([], list), do: Enum.reverse list
  def list_raw_vss([h|t], list) do
    p = 
      h 
      |> String.split(~r/<v.*ve\s?\/>/U, [include_captures: true, trim: true])
      |> Enum.reject( &(&1 |> String.match?(~r/<p>|<\/p>/)) )
      |> Enum.reject( &(&1 == " "))
    list_raw_vss(t, [{next, p}|list])
  end

  def list_of_vss(list) do
    list
    |> String.split(~r/<v.* <ve \/>/U, [include_captures: true, trim: true])
    |> Enum.reject(&(&1 == " "))
    |> Enum.map( &( String.strip(&1) ) )
  end
#   def list_of_vss([], list), do: list
#   def list_of_vss([{p_num, vss}|t], list) do
#     new_vss = 
#       vss
#       |> Enum.map( &(&1 |> String.split(~r/<v.*>/U, [include_captures: true, trim: true])) )
#     list_of_vss t, [{p_num,new_vss}|list]
#   end

  def list_of_vs_maps(list), do: list_of_vs_maps(list, [])
    
  def list_of_vs_maps([], list), do: list
  def list_of_vs_maps([h|t], list) do
    chap_list = h |> tokenize |> interpret({"", []})
    list_of_vs_maps( t, chap_list ++ list)
  end

  def interpret([], list) do
    list
  end

  def interpret([h|t], list) when h |> binary_part(0,4) == "<?xml" do 
    interpret t, list
  end

  def interpret(["<add>"|t], list) do
    revise_text("<span class='add'>")
    interpret t, list
  end
  def interpret(["</add>"|t], list) do
    revise_text("</span>")
    interpret t, list
  end

  def interpret([h|t], list) when h |> binary_part(0,3) == "<b " do
    revise_text("<br />")
    interpret t, list
  end

  def interpret(["<bk>"|t], list) do
    revise_text("<span class='bk'>")
    interpret t, list
  end
  def interpret(["</bk>"|t], list) do
    revise_text("</span>")
    interpret t, list
  end

  def interpret([h|t], list) when h |> binary_part(0,6) == "<book " do
    push :book
    init_book
    interpret t, list
  end

  # put both book & verse maps into list & sort it out later
  def interpret(["</book>"| t], list) do
    interpret t, [get_text | list]
  end

  def interpret([h|t], list) when h |> binary_part(0,2) == "<c" do
    # start of chapter, may have intro text
    if chap?, do: pop
    push :chap
    revise :chap, chap: parse_tag(h)[:id]
    interpret t, list
  end

  def interpret(["<cl>"|t], list) do
    revise_text("<span class='cl'>")
    interpret t, list
  end
  def interpret(["</cl>"|t], list) do
    revise_text("</span>")
    interpret t, list
  end

  def interpret([h|t], list) when h |> binary_part(0,3) == "<cp" do
    # alternative chapter id, alternative chapter id
    interpret t, list
  end

  def interpret(["<d>"|t], list) do
    # intro text to a psalm, goes with verses THAT FOLLOW
    # what now?
    revise_text("<p class='d'>")
    interpret t, list
  end
  def interpret(["</d>"|t], list) do
    revise_text("</p>")
    interpret t, list
  end

  def interpret([h|t], list) when h |> binary_part(0,2) == "<f" do
    # footnote, always part of a book, verse, or intro text 
    # but require a boatload of code
    interpret t, list
  end
  def interpret(["</f>"|t], list) do
    # end of footnote, do something smart
    interpret t, list
  end

  def interpret(["<fl>"|t], list) do
    revise_text("<span class='fl'>")
    interpret t, list
  end
  def interpret(["</fl>"|t], list) do
    revise_text("</span>")
    interpret t, list
  end

  def interpret(["<fq>"|t], list) do
    revise_text("<span class='fq'>")
    interpret t, list
  end
  def interpret(["</fq>"|t], list) do
    revise_text("</span>")
    interpret t, list
  end
  def interpret(["<fqa>"|t], list) do
    revise_text("<span class='fqa'>")
    interpret t, list
  end
  def interpret(["</fqa>"|t], list) do
    revise_text("</span>")
    interpret t, list
  end

  def interpret(["<fr>"|t], list) do
    revise_text("<span class='fr'>")
    interpret t, list
  end
  def interpret(["</fr>"|t], list) do
    revise_text("</span>")
    interpret t, list
  end

  def interpret(["<ft>"|t], list) do
    revise_text("<span class='ft'>")
    interpret t, list
  end
  def interpret(["</ft>"|t], list) do
    revise_text("</span>")
    interpret t, list
  end

  def interpret(["<h>"|t], list) do
    # words following go into books.name
    interpret t, {"", list}
  end
  def interpret(["</h>"|t], {h_string,list}) do
    revise :book, name: h_string
    interpret t, list
  end

  def interpret([h|t], list) when h |> binary_part(0,4) == "<id " do
    attrs = parse_tag(h)
    revise :book, id: attrs[:id]
    interpret t, {"", list}
  end
  def interpret(["</id>"|t], {_, list}) do
    interpret t, list
  end

  def interpret([h|t], list) when h |> binary_part(0,5) == "<ide " do
    attrs = parse_tag(h)
    revise :book, char_set: attrs[:charset]
    interpret t, list
  end

  def interpret(["<languageCode>"|t], list) do
    # skip, and the following word
    [_|new_tail] = t
    interpret new_tail, list
  end
  def interpret(["</languageCode>"|t], list) do
    interpret t, list
  end

  def interpret([h|t], list) when h |> binary_part(0,3) == "<p " do
    next
    open_tag(h |> String.replace("sfm", "class"))
    interpret t, list
  end

# paragraphs may start before or after vss
  def interpret(["<p>"|t], list) do
    next
    open_tag("<p>")
    interpret t, list
  end
    
  def interpret(["</p>"|t], list) do
    close_tag "</p>"
    IO.puts "\n>>>>> CLOSE P TAG: #{inspect Bible.identity}\n"
    interpret t, list
  end

# quotes could start before or after vss
  def interpret([h|t], list) when h |> binary_part(0,3) == "<q " do
    push :quote2
    interpret t, list
  end

  def interpret(["<q>" | t], list) do
    push :quote
    interpret t, list
  end

  def interpret(["</q>" | t], list) do
    revise_text("</q>")
    interpret t, list
  end

# <qs>Selah.</qs> only
  def interpret(["<qs>"|t], list) do
    revise_text("<div class='qs'>")
    interpret t, list

  end
  def interpret(["</qs>"|t], list) do
    revise_text("</div>")
    interpret t, list
  end

  def interpret([h | t], list) when h |> binary_part(0,5) == "<ref " do
    attr = parse_tag(h)
    # may have to transform tgt value to html ref
    revise_text "<a href=\"#{attr[:tgt]}\">"
    interpret t, list
  end
  def interpret(["</ref>"|t], list) do
    revise_text "</a>"
    interpret t, list
  end

  def interpret(["<s>"|t], list) do
    # goes with a chapter
    revise_text "<div class=\"s\"">
    interpret t, list
  end
  def interpret(["</s>"|t], list) do
    revise_text "</s>"
    interpret t, list
  end

  def interpret([h | t], list) when h |> binary_part(0,5) == "<toc " do
#    attr = parse_tag h
#    field = "toc" <> attr[:level] |> String.to_atom
#    revise book:, field => 
  end

  def interpret([h | t], list) when h |> binary_part(0,6) == "<usfx " do

  end

  def interpret([h|t], list) when h |> binary_part(0,3) == "<v " do
    # don't forget to do something smart with book or chapter here
    init_vs h # do this first
    push :verse
    interpret t, list
  end

  def interpret("quote", [h|t], list) do
    
  end

  def interpret("quote2", [h|t], list) do
    
  end

  def interpret(["<ve />"|t], list) do
    interpret t, [get_text | list]
  end

# words of Jesus
  def interpret(["<wj>"|t], list) do
    revise_text "<span class=\"wj\">">
    interpret t, list
  end
  def interpret(["</wj>"|t], list) do
    revise_text "</span>">
    interpret t, list
  end

  def interpret([h | t], list) when h |> binary_part(0,3) == "<x " do
    # cross ref.
    # both xref & fnotes need to keep track of how many per chapter
  end

  def interpret(["<xo>"|t], list) do
    
  end
  def interpret(["</xo>"|t], list) do
    
  end

  def interpret(["<xt>"|t], list) do
    
  end
  def interpret(["</xt>"|t], list) do
    
  end

  def interpret([h|t], list) do
    revise_text(h)
    interpret t, list
  end

  def interpret([h|t], {temp_string, list}) do
    new_string = temp_string <> " " <> h
    interpret t, {new_string, list}
  end



#  def revise_text(old_text, s) when s |> binary_part(0,1) == "<" do
#    old_text <> s
#  end
#  def revise_text(old_text, s), do: old_text <> " " <> s
#
  def init_book do
    revise :book, [
      key: "",
      name: "",
      toc1: "",
      toc2: "",
      toc3: "",
      mt: "",
      info: ""
    ]
  end

  def init_vs(vs) do
    {bcv, book, chap, vs_num} = vs_bcv(vs)
    revise :verse, [
      book: book,
      chap: chap,
      vs_num: vs_num,
      bcv: bcv,
      para: current,
      info: [],
      breaks: []
    ]
  end

#  def init_vs_text("quote"), do: "<div class=\"q\">"

  def parse_tag(tag) do
    tag 
    |> String.split(~r/\s|\/|>/, trim: true)
    |> Enum.drop(1) # ignore first token
    |> Enum.reject(&(&1 == "/>")) # ignore tag closing
    |> Enum.map( &( attr_val(&1) ) )
  end

  def attr_val(s) do
    [attr, val_string] = s |> String.replace("\"", "") |> String.split("=")
    val = if val_string |> String.match?(~r/[a-zA-Z]/) do
        val_string
      else
        val_string |> String.to_integer
      end 
    {attr |> String.to_atom, val}
  end

  def vs_text([_vtag, vtext, _vend_tag]), do: vtext
  def vs_tag([vtag, _vtext, _vend_tag]), do: vtag
  def vs_bcv([vtag, _vtext, _vend_tag]) do
    bcv = vtag |> bcv_string
    [b,c,v] = bcv |> String.split(".")
    {bcv, b, String.to_integer(c), String.to_integer(v)}
  end
  def bcv_string(s) do
    s
    |> String.split
    |> Enum.filter(&( Regex.match?(~r/bcv/, &1)))
    |> hd
    |> String.split(~r/\"/, include_captures: false, trim: true)
    |> List.last
  end

  def tokenize(s) do
    s 
    |> String.split(~r/<.*>|\s/U, [include_captures: true, trim: true])
    |> Enum.map( &( String.strip &1) )
    |> Enum.reject( &(&1 == "") )
  end

  def load do
    web_map = %{}
    list_books
    |> Enum.filter( &( Regex.match?(~r/^<book/, &1) ) )
    |> Enum.each(fn(book)->
      book
      |> list_chapters
      |> Enum.each(fn(chapter)->
        chapter # it's a string
        |> list_of_vss
        |> list_of_vs_maps
        |> Enum.each(fn(vs)->
          IO.puts vs.bcv
          web_map |> Map.put_new(vs.bcv, vs)
        end)
      end)
    end)
  end

end