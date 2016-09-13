defmodule Worldenglishbible.Repo.Migrations.AddCharSetToBook do
  use Ecto.Migration

  def change do
    alter table(:book) do
      add :char_set, :string
    end
  end
end
