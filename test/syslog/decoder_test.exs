defmodule Syslog.DecoderTest do
  use ExUnit.Case
  alias Kvasir.Syslog.Server

  setup do
    {:ok, server} = Kvasir.Application.start_server(port: 0)
    {:ok, decoder} = Kvasir.Application.start_decoder(producer: server)
    {:ok, consumer} = Kvasir.Consumer.start_link(decoder)
    {:ok, port} = Server.get_port(server)
    %{server: server, decoder: decoder, consumer: consumer, port: port}
  end

  test "producing an event", %{port: port} do
    syslog_msg =
      "<165>1 2003-08-24T12:14:15.000003Z 192.0.2.1 myproc 8710 - - %% It's time to make the do-nuts."

    send_msg(port, syslog_msg)

    syslog = %Kvasir.Syslog{
      app_name: "myproc",
      facility: :local4,
      hostname: "192.0.2.1",
      message: "%% It's time to make the do-nuts.",
      process_id: "8710",
      severity: :notice,
      timestamp: ~U[2003-08-24 12:14:15.000003Z]
    }

    assert_receive [^syslog]
  end

  test "producing an incorrect event", %{port: port} do
    syslog_msg = "<0>1 2023-01-01T00:00:00Z localhost kvasir 0.123.0"

    send_msg(port, syslog_msg)

    refute_receive _
  end

  defp send_msg(port, syslog_msg) do
    {:ok, socket} = :gen_udp.open(0)
    :gen_udp.send(socket, {127, 0, 0, 1}, port, syslog_msg)
    :gen_udp.close(socket)
  end
end
