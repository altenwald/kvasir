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
               timestamp: ~U[2023-10-11 22:14:15Z]
             }) == "<34>Oct 11 22:14:15 mymachine su: 'su root' failed for lonvick on /dev/pts/8"
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
               timestamp: ~U[1987-08-24 05:34:00Z]
             }) ==
               "<165>1987 Aug 24 05:34:00 mymachine myproc[10]: %% It's " <>
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
               timestamp: ~U[1990-10-22 16:52:01Z]
             }) ==
               "<0>1990 Oct 22 16:52:01 scapegoat.dmz.example.org 10.1.2.3 " <>
                 "sched[0]: That's All Folks!"
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
               timestamp: ~U[2003-10-11 22:14:15.003Z]
             }) ==
               "<34>1 2003-10-11T22:14:15.003Z mymachine.example.com su - ID47 - " <>
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
  end
end
