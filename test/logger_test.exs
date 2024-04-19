defmodule Kvasir.LoggerTest do
  use ExUnit.Case, async: false
  require Logger

  setup do
    {:ok, socket} = :gen_udp.open(0)
    {:ok, port} = :inet.port(socket)

    Application.put_env(:logger, Kvasir.Logger,
      host: "localhost",
      port: port
    )

    Logger.add_backend(Kvasir.Logger)
    on_exit(fn -> Logger.remove_backend(Kvasir.Logger) end)
    %{socket: socket, port: port}
  end

  test "log debug" do
    Logger.debug("hello world!")
    assert_receive {:udp, _, _, _, message}, 500

    message = to_string(message)

    assert message =~ ~r/^<143>1 /
    assert message =~ ~r/hello world!$/
  end

  test "log info and metadata" do
    Logger.metadata(lang: "en", type: "greeting")
    Logger.info("hello world!")
    assert_receive {:udp, _, _, _, message}, 500

    message = to_string(message)

    assert message =~ ~r/^<142>1 /
    assert message =~ ~r/lang="en"/
    assert message =~ ~r/type="greeting"/
    assert message =~ ~r/hello world!$/
  end

  test "log notice" do
    Logger.notice("hello world!")
    assert_receive {:udp, _, _, _, message}, 500

    message = to_string(message)

    assert message =~ ~r/^<141>1 /
    assert message =~ ~r/hello world!$/
  end

  test "log warn" do
    Logger.warning("hello world!")
    assert_receive {:udp, _, _, _, message}, 500

    message = to_string(message)

    assert message =~ ~r/^<140>1 /
    assert message =~ ~r/hello world!$/
  end

  test "log error" do
    Logger.error("hello world!")
    assert_receive {:udp, _, _, _, message}, 500

    message = to_string(message)

    assert message =~ ~r/^<139>1 /
    assert message =~ ~r/hello world!$/
  end
end
