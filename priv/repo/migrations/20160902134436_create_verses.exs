defmodule Worldenglishbible.Repo.Migrations.CreateVerses do
  use Ecto.Migration

  def change do
    create table(:verse) do
      add :book,    :string
      add :chap,    :integer
      add :vs_num,  :integer
      add :bcv,    :string
      add :para,    :integer
      add :vs,      :text
    end

    create unique_index(:verse, [:bcv])
    create unique_index(:verse, [:chap])
    create unique_index(:verse, [:para])
  end
end
