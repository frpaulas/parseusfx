defmodule Worldenglishbible.Chapters do
  use Worldenglishbible.Web, :model
    schema "chapter" do
      field :key, :string # book + chap, eg GEN.1
      field :book, :string
      field :chap, :integer
      field :info, {:array, {:array, :string}}
      timestamps
    end
  def new() do
    %{  key: "",
        book: "",
        chap: 0,
        info: [""],
        breaks: []
    }
  end

  def revise(map, vals) do
    map 
    |> Enum.map(fn {k,v} ->
      {k, Keyword.get(vals, k, v)}
    end)
    |> Enum.into(%{})
  end
end