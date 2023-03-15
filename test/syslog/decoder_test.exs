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

    {:ok, socket} = :gen_udp.open(0)
    :gen_udp.send(socket, {127, 0, 0, 1}, port, syslog_msg)
    :gen_udp.close(socket)

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
end
