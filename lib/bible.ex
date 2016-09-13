defmodule Bible do
  import Worldenglishbible.Books
  import Worldenglishbible.Verses
  import Worldenglishbible.Chapters
  alias Worldenglishbible.Books
  alias Worldenglishbible.Verses
  alias Worldenglishbible.Chapters

  def start_link do
    Agent.start_link fn -> build end, name: __MODULE__
  end

  def identity(), do: Agent.get(__MODULE__, &(&1))
  def current(), do: Agent.get(__MODULE__, &(&1.paragraph))
  def next() do
    Agent.update(__MODULE__, fn map -> map |> Map.update!(:paragraph, &(&1 + 1)) end)
    identity.paragraph
  end

# THE STACK
  def push(s) do
    Agent.update(__MODULE__, fn map -> map |> Map.update!(:stack, &([s|&1]) ) end)
    _push(s)
  end

  def _push("book"),  do: Bible.revise :book, Map.to_list Books.new
  def _push("chap"),  do: Bible.revise :chap, Map.to_list Chapters.new
  def _push("verse"), do: Bible.revise :verse,   Map.to_list Verses.new
  def _push(_), do: :ok

  def pop() do
    popped = identity.stack |> hd
    Agent.update(__MODULE__, fn map -> map |> Map.update!(:stack, &(&1 |> Enum.drop(1)) ) end)
    popped
  end

  def top(), do: identity.stack |> hd

  def book?(), do: identity.stack |> hd == "book"

  def verse?(), do: identity.stack |> hd == "verse"

  def chap?(), do: identity.stack |> hd == "chap"

  def quote?(), do: identity.stack |> hd |> binary_part(0,5) == "quote"

# END OF STACK STUFF

  def update(atom, val) do
    Agent.update(__MODULE__, fn map -> map |> Map.update!(atom, fn(_)-> val end) end)
  end

  def revise_text(atom) when atom |> is_atom do
    IO.puts ">>>>> MAP: #{inspect identity[atom]}"
    new_map =
      identity[atom]
      |> Map.update!(:info, &([[identity.open_tag, identity.temp_s, identity.close_tag] | &1]))
    update(atom, new_map)
    IO.puts ">>>>> IDENTITY: #{inspect identity}"
    update(:temp_s, "")
    clear_tags
  end

  def revise_text(val) do 
    new_val = if val |> binary_part(0,1) == "<", do: val, else: " " <> val
    update(:temp_s, identity.temp_s <> new_val)
  end

  def open_tag(val),  do: update(:open_tag,  identity.open_tag  <> val)
  def close_tag(val) do 
    update(:close_tag, identity.close_tag <> val)
  end
  def clear_tags() do
    update(:open_tag,  "")
    update(:close_tag, "")
  end

  def revise(:book, vals) do
    update(:book, Books.revise(identity.book, vals))
    identity.book
  end

  def revise(:chap, vals) do
    update(:chap, Chapters.revise(identity.chap, vals))
    identity.chap
  end

  def revise(:verse, vals) do
    update(:verse, Verses.revise(identity.verse, vals))
    identity.verse
  end

#  def revise_text("book", val) do
#    Bible.revise(:book, info: identity.book.info <> val)
#  end
#  def revise_text("chap", val) do
#    Bible.revise(:chap, info: identity.chap.info <> val)
#  end
#  def revise_text("verse", val) do
#    Bible.revise(:vs, vs: identity.vs.vs <> val)
#  end

  def get_text(), do: get_text top
  def get_text(s) when s |> is_bitstring, do: identity[s |> String.to_atom].info
  def get_text(atom) when atom |> is_atom, do: identity[atom].info

#   def get_text("book"), do: identity.book.info
#   def get_text("chap"), do: identity.chap.info
#   def get_text("verse"), do: identity.vs.info

  def clear_text(), do: clear_text(top)
  def clear_text("book"), do: Bible.revise(:book, info: [])
  def clear_text("chap"), do: Bible.revise(:chap, info: [])
  def clear_text("verse"), do: Bible.revise(:verse, info: [])

  def reset() do
    update :paragraph, 0
    update :open_tag, ""
    update :close_tag, ""
    update :temp_s, ""
    update :stack, []
    update :verse, Verses.new
    update :book, Books.new
    update :chap, Chapters.new
  end

  def build do
    %{  paragraph: 0,
        open_tag: "", # temporary DOM element
        close_tag: "",
        temp_s: "", # temporary string
        stack: [],
        verse: Verses.new,
        book: Books.new,
        chap: Chapters.new
    }
  end

end