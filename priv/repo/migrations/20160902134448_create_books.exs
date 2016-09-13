defmodule Worldenglishbible.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:book) do
      add :key,   :string
      add :name,  :string
      add :toc1,  :string
      add :toc2,  :string
      add :toc3,  :string
      add :mt,    :string
      add :info,  :text
    end

    create unique_index(:book, [:key])
  end
end
