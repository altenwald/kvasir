defmodule Kvasir.Syslog.EncodeTest do
  use ExUnit.Case
  alias Kvasir.Syslog

  describe "rfc3164 examples" do
    test "5.4. example 1" do
      assert to_string(%Syslog{
               app_name: "su",
               facility: :auth,
               hostname: "mymachine",
               message: "'su root' failed for lonvick on /dev/pts/8",
               rfc: :rfc3164,
               severity: :critical,
               timestamp: ~U[2023-01-11 22:14:15Z]
             }) == "<34>Jan 11 22:14:15 mymachine su: 'su root' failed for lonvick on /dev/pts/8"
    end

    test "5.4. example 2" do
      assert to_string(%Syslog{
               message: "Use the BFG!",
               rfc: :rfc3164
             }) == "Use the BFG!"
    end

    test "5.4. example 3" do
      assert to_string(%Syslog{
               app_name: "myproc",
               facility: :local4,
               hostname: "mymachine",
               message:
                 "%% It's time to make the do-nuts.  %%  Ingredients: Mix=OK, " <>
                   "Jelly=OK #Devices: Mixer=OK, Jelly_Injector=OK, Frier=OK # " <>
                   "Transport: Conveyer1=OK, Conveyer2=OK # %%",
               process_id: "10",
               rfc: :rfc3164,
               severity: :notice,
               timestamp: ~U[1987-02-24 05:34:00Z]
             }) ==
               "<165>1987 Feb 24 05:34:00 mymachine myproc[10]: %% It's " <>
                 "time to make the do-nuts.  %%  Ingredients: Mix=OK, Jelly=OK #" <>
                 "Devices: Mixer=OK, Jelly_Injector=OK, Frier=OK # Transport: " <>
                 "Conveyer1=OK, Conveyer2=OK # %%"
    end

    test "5.4. example 4" do
      assert to_string(%Syslog{
               app_name: "sched",
               facility: :kernel,
               hostname: "scapegoat.dmz.example.org",
               ip_address: "10.1.2.3",
               message: "That's All Folks!",
               process_id: "0",
               rfc: :rfc3164,
               severity: :emergency,
               timestamp: ~U[1990-03-22 16:52:01Z]
             }) ==
               "<0>1990 Mar 22 16:52:01 scapegoat.dmz.example.org 10.1.2.3 " <>
                 "sched[0]: That's All Folks!"
    end

    test "simple messages" do
      assert to_string(%Syslog{rfc: :rfc3164, facility: :kernel, severity: :debug, timestamp: ~U[1990-04-22 00:00:00Z], message: "Hello world!"}) == "<7>1990 Apr 22 00:00:00 Hello world!"
      assert to_string(%Syslog{rfc: :rfc3164, facility: :local1, severity: :info, timestamp: ~U[1990-05-22 00:00:00Z], message: "Hello world!"}) == "<142>1990 May 22 00:00:00 Hello world!"
      assert to_string(%Syslog{rfc: :rfc3164, facility: :local2, severity: :notice, timestamp: ~U[1990-06-22 00:00:00Z], message: "Hello world!"}) == "<149>1990 Jun 22 00:00:00 Hello world!"
      assert to_string(%Syslog{rfc: :rfc3164, facility: :local3, severity: :warning, timestamp: ~U[1990-07-22 00:00:00Z], message: "Hello world!"}) == "<156>1990 Jul 22 00:00:00 Hello world!"
      assert to_string(%Syslog{rfc: :rfc3164, facility: :local4, severity: :error, timestamp: ~U[1990-08-22 00:00:00Z], message: "Hello world!"}) == "<163>1990 Aug 22 00:00:00 Hello world!"
      assert to_string(%Syslog{rfc: :rfc3164, facility: :local5, severity: :critical, timestamp: ~U[1990-09-22 00:00:00Z], message: "Hello world!"}) == "<170>1990 Sep 22 00:00:00 Hello world!"
      assert to_string(%Syslog{rfc: :rfc3164, facility: :local6, severity: :alert, timestamp: ~U[1990-10-22 00:00:00Z], message: "Hello world!"}) == "<177>1990 Oct 22 00:00:00 Hello world!"
      assert to_string(%Syslog{rfc: :rfc3164, facility: :local7, severity: :emergency, timestamp: ~U[1990-11-22 00:00:00Z], message: "Hello world!"}) == "<184>1990 Nov 22 00:00:00 Hello world!"
    end

    test "message with structured data" do
      data = [metadata: [pid: 1234, app: "kvasir"]]
      assert to_string(%Syslog{rfc: :rfc3164, facility: :kernel, severity: :emergency, timestamp: ~U[1990-12-22 00:00:00Z], message: "Hello world!", structured_data: data}) == "<0>1990 Dec 22 00:00:00 [metadata pid=\"1234\" app=\"kvasir\"] Hello world!"
    end
  end

  describe "rfc5424 examples" do
    test "6.5. example 1" do
      assert to_string(%Syslog{
               app_name: "su",
               facility: :auth,
               hostname: "mymachine.example.com",
               message: "'su root' failed for lonvick on /dev/pts/8",
               message_id: "ID47",
               severity: :critical,
               timestamp: ~U[2003-04-11 22:14:15.003Z]
             }) ==
               "<34>1 2003-04-11T22:14:15.003Z mymachine.example.com su - ID47 - " <>
                 "'su root' failed for lonvick on /dev/pts/8"
    end

    test "6.5. example 2" do
      assert to_string(%Syslog{
               app_name: "myproc",
               facility: :local4,
               hostname: "192.0.2.1",
               message: "%% It's time to make the do-nuts.",
               process_id: "8710",
               severity: :notice,
               timestamp: ~U[2003-08-24 12:14:15.000003Z]
             }) ==
               "<165>1 2003-08-24T12:14:15.000003Z 192.0.2.1 myproc 8710 - - %% It's time to make the do-nuts."
    end

    test "6.5. example 3" do
      assert to_string(%Syslog{
               app_name: "evntslog",
               facility: :local4,
               hostname: "mymachine.example.com",
               message: "An application event log entry...",
               message_id: "ID47",
               severity: :notice,
               structured_data: %{
                 "exampleSDID@32473" => %{
                   "eventID" => "1011",
                   "eventSource" => "Application",
                   "iut" => "3"
                 }
               },
               timestamp: ~U[2003-10-11 22:14:15.003Z]
             }) ==
               "<165>1 2003-10-11T22:14:15.003Z mymachine.example.com evntslog - ID47 " <>
                 ~s|[exampleSDID@32473 eventID="1011" eventSource="Application" iut="3"]| <>
                 " An application event log entry..."
    end

    test "6.5. example 4" do
      assert to_string(%Syslog{
               app_name: "evntslog",
               facility: :local4,
               hostname: "mymachine.example.com",
               message_id: "ID47",
               severity: :notice,
               structured_data: %{
                 "examplePriority@32473" => %{"class" => "high"},
                 "exampleSDID@32473" => %{
                   "eventID" => "1011",
                   "eventSource" => "Application",
                   "iut" => "3"
                 }
               },
               timestamp: ~U[2003-10-11 22:14:15.003Z]
             }) ==
               "<165>1 2003-10-11T22:14:15.003Z mymachine.example.com evntslog - " <>
                 "ID47 [examplePriority@32473 class=\"high\"]" <>
                 "[exampleSDID@32473 eventID=\"1011\" eventSource=\"Application\" iut=\"3\"]"
    end

    test "simple message" do
      assert to_string(%Syslog{rfc: :rfc5424, facility: :user_level, severity: :info, message: "Hello world!"}) == "<14>1 - - - - - - Hello world!"
    end
  end
end
