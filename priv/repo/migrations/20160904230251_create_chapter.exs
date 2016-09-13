defmodule Worldenglishbible.Repo.Migrations.CreateChapter do
  use Ecto.Migration

  def change do
    create table(:chapter) do
      add :book, :string
      add :chap, :integer
      add :key, :string # book + chap, eg GEN.1
      add :info, :text
    end

    create unique_index(:chapter, [:key])
  end
end
