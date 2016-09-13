defmodule Worldenglishbible.Verses do
  use Worldenglishbible.Web, :model
    schema "verse" do
      field :book,    :string
      field :chap,    :integer
      field :vs_num,  :integer
      field :bcv,     :string
      field :para,    :integer
      field :info,    {:array, {:array, :string}}
      timestamps
  end
  def new() do
    %{  book: "",
        chap: 0,
        vs_num: 0,
        bcv: "",
        para: 0,
        info: [],
        breaks: []}
  end

  def revise(map, vals) do
    map 
    |> Enum.map(fn {k,v} ->
      {k, Keyword.get(vals, k, v)}
    end)
    |> Enum.into(%{})
  end
end