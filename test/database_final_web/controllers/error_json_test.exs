defmodule DatabaseFinalWeb.ErrorJSONTest do
  use DatabaseFinalWeb.ConnCase, async: true

  test "renders 404" do
    assert DatabaseFinalWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert DatabaseFinalWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
