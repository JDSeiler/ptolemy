defmodule Ptolemy.Controllers.Auth.CreateTest do
  use Ptolemy.Case
  use Plug.Test

  import Mox

  alias Ptolemy.Controllers.Auth.Create

  @opts Create.init([])

  setup :verify_on_exit!
end
