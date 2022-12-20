defmodule Ptolemy.Controllers.Auth.LoginTest do
  use Ptolemy.Case
  use Plug.Test

  import Mox

  alias Ptolemy.Controllers.Auth.Login

  @opts Auth.init([])

  setup :verify_on_exit!
end
