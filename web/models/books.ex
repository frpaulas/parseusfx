defmodule Worldenglishbible.Books do
  use Worldenglishbible.Web, :model
    schema "book" do
      field :key,   :string
      field :name,  :string
      field :toc1,  :string
      field :toc2,  :string
      field :toc3,  :string
      field :mt,    :string
      field :info,  {:array, {:array, :string}}
      field :char_set, :string
      timestamps
  end

  def new() do
    %{  key: "",
        name: "",
        toc1: "",
        toc2: "",
        toc3: "",
        mt: "",
        info: [],
        char_set: "utf-8"}
  end

  def revise(map, vals) do
    map 
    |> Enum.map(fn {k,v} ->
      {k, Keyword.get(vals, k, v)}
    end)
    |> Enum.into(%{})
  end
end