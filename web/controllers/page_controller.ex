defmodule Worldenglishbible.PageController do
  use Worldenglishbible.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
