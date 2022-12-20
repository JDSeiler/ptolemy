defmodule Ptolemy.Controllers.Auth.VerifyTest do
  use Ptolemy.Case
  use Plug.Test

  import Mox

  alias Ptolemy.Controllers.Auth.Verify

  @opts Verify.init([])

  setup :verify_on_exit!
end
