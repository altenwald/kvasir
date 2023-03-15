defmodule Kvasir.Syslog do
  @moduledoc """
  Syslog structure for storing the message.
  """

  @type facility() ::
          :kernel
          | :user_level
          | :user
          | :mail
          | :daemon
          | :auth
          | :internal
          | :printer
          | :network
          | :uucp
          | :clock
          | :security
          | :ftp
          | :ntp
          | :audit
          | :alert
          | :note2
          | :local0
          | :local1
          | :local2
          | :local3
          | :local4
          | :local5
          | :local6
          | :local7

  @type severity() ::
          :emergency
          | :alert
          | :critical
          | :error
          | :warn
          | :warning
          | :notice
          | :info
          | :debug

  @type t() :: %__MODULE__{
          rfc: :rfc3164 | :rfc5424,
          facility: nil | facility(),
          severity: nil | severity(),
          version: nil | pos_integer(),
          hostname: nil | String.t(),
          ip_address: nil | String.t(),
          app_name: nil | String.t(),
          process_id: nil | String.t(),
          message_id: nil | String.t(),
          timestamp: nil | DateTime.t(),
          structured_data: %{String.t() => %{String.t() => String.t()}},
          message: nil | String.t()
        }

  defstruct rfc: :rfc5424,
            facility: nil,
            severity: nil,
            version: 1,
            hostname: nil,
            ip_address: nil,
            app_name: nil,
            process_id: nil,
            message_id: nil,
            timestamp: nil,
            structured_data: %{},
            message: nil

  def new(rfc \\ :rfc5424), do: %__MODULE__{rfc: rfc}

  @spec set_facility(t(), 0..23 | facility()) :: t()
  def set_facility(%__MODULE__{} = syslog, 0), do: %__MODULE__{syslog | facility: :kernel}
  def set_facility(%__MODULE__{} = syslog, :kernel), do: %__MODULE__{syslog | facility: :kernel}
  def set_facility(%__MODULE__{} = syslog, 1), do: %__MODULE__{syslog | facility: :user_level}
  def set_facility(%__MODULE__{} = syslog, :user), do: %__MODULE__{syslog | facility: :user_level}

  def set_facility(%__MODULE__{} = syslog, :user_level),
    do: %__MODULE__{syslog | facility: :user_level}

  def set_facility(%__MODULE__{} = syslog, 2), do: %__MODULE__{syslog | facility: :mail}
  def set_facility(%__MODULE__{} = syslog, :mail), do: %__MODULE__{syslog | facility: :mail}
  def set_facility(%__MODULE__{} = syslog, 3), do: %__MODULE__{syslog | facility: :daemon}
  def set_facility(%__MODULE__{} = syslog, :daemon), do: %__MODULE__{syslog | facility: :daemon}
  def set_facility(%__MODULE__{} = syslog, 4), do: %__MODULE__{syslog | facility: :auth}
  def set_facility(%__MODULE__{} = syslog, :auth), do: %__MODULE__{syslog | facility: :auth}
  def set_facility(%__MODULE__{} = syslog, 5), do: %__MODULE__{syslog | facility: :internal}

  def set_facility(%__MODULE__{} = syslog, :internal),
    do: %__MODULE__{syslog | facility: :internal}

  def set_facility(%__MODULE__{} = syslog, 6), do: %__MODULE__{syslog | facility: :printer}
  def set_facility(%__MODULE__{} = syslog, :printer), do: %__MODULE__{syslog | facility: :printer}
  def set_facility(%__MODULE__{} = syslog, 7), do: %__MODULE__{syslog | facility: :network}
  def set_facility(%__MODULE__{} = syslog, :network), do: %__MODULE__{syslog | facility: :network}
  def set_facility(%__MODULE__{} = syslog, 8), do: %__MODULE__{syslog | facility: :uucp}
  def set_facility(%__MODULE__{} = syslog, :uucp), do: %__MODULE__{syslog | facility: :uucp}
  def set_facility(%__MODULE__{} = syslog, 9), do: %__MODULE__{syslog | facility: :clock}
  def set_facility(%__MODULE__{} = syslog, :clock), do: %__MODULE__{syslog | facility: :clock}
  def set_facility(%__MODULE__{} = syslog, 10), do: %__MODULE__{syslog | facility: :security}

  def set_facility(%__MODULE__{} = syslog, :security),
    do: %__MODULE__{syslog | facility: :security}

  def set_facility(%__MODULE__{} = syslog, 11), do: %__MODULE__{syslog | facility: :ftp}
  def set_facility(%__MODULE__{} = syslog, :ftp), do: %__MODULE__{syslog | facility: :ftp}
  def set_facility(%__MODULE__{} = syslog, 12), do: %__MODULE__{syslog | facility: :ntp}
  def set_facility(%__MODULE__{} = syslog, :ntp), do: %__MODULE__{syslog | facility: :ntp}
  def set_facility(%__MODULE__{} = syslog, 13), do: %__MODULE__{syslog | facility: :audit}
  def set_facility(%__MODULE__{} = syslog, :audit), do: %__MODULE__{syslog | facility: :audit}
  def set_facility(%__MODULE__{} = syslog, 14), do: %__MODULE__{syslog | facility: :alert}
  def set_facility(%__MODULE__{} = syslog, :alert), do: %__MODULE__{syslog | facility: :alert}
  def set_facility(%__MODULE__{} = syslog, 15), do: %__MODULE__{syslog | facility: :note2}
  def set_facility(%__MODULE__{} = syslog, :note2), do: %__MODULE__{syslog | facility: :note2}
  def set_facility(%__MODULE__{} = syslog, 16), do: %__MODULE__{syslog | facility: :local0}
  def set_facility(%__MODULE__{} = syslog, :local0), do: %__MODULE__{syslog | facility: :local0}
  def set_facility(%__MODULE__{} = syslog, 17), do: %__MODULE__{syslog | facility: :local1}
  def set_facility(%__MODULE__{} = syslog, :local1), do: %__MODULE__{syslog | facility: :local1}
  def set_facility(%__MODULE__{} = syslog, 18), do: %__MODULE__{syslog | facility: :local2}
  def set_facility(%__MODULE__{} = syslog, :local2), do: %__MODULE__{syslog | facility: :local2}
  def set_facility(%__MODULE__{} = syslog, 19), do: %__MODULE__{syslog | facility: :local3}
  def set_facility(%__MODULE__{} = syslog, :local3), do: %__MODULE__{syslog | facility: :local3}
  def set_facility(%__MODULE__{} = syslog, 20), do: %__MODULE__{syslog | facility: :local4}
  def set_facility(%__MODULE__{} = syslog, :local4), do: %__MODULE__{syslog | facility: :local4}
  def set_facility(%__MODULE__{} = syslog, 21), do: %__MODULE__{syslog | facility: :local5}
  def set_facility(%__MODULE__{} = syslog, :local5), do: %__MODULE__{syslog | facility: :local5}
  def set_facility(%__MODULE__{} = syslog, 22), do: %__MODULE__{syslog | facility: :local6}
  def set_facility(%__MODULE__{} = syslog, :local6), do: %__MODULE__{syslog | facility: :local6}
  def set_facility(%__MODULE__{} = syslog, 23), do: %__MODULE__{syslog | facility: :local7}
  def set_facility(%__MODULE__{} = syslog, :local7), do: %__MODULE__{syslog | facility: :local7}

  def get_facility(:kernel), do: 0
  def get_facility(:user_level), do: 1
  def get_facility(:mail), do: 2
  def get_facility(:daemon), do: 3
  def get_facility(:auth), do: 4
  def get_facility(:internal), do: 5
  def get_facility(:printer), do: 6
  def get_facility(:network), do: 7
  def get_facility(:uucp), do: 8
  def get_facility(:clock), do: 9
  def get_facility(:security), do: 10
  def get_facility(:ftp), do: 11
  def get_facility(:ntp), do: 12
  def get_facility(:audit), do: 13
  def get_facility(:alert), do: 14
  def get_facility(:note2), do: 15
  def get_facility(:local0), do: 16
  def get_facility(:local1), do: 17
  def get_facility(:local2), do: 18
  def get_facility(:local3), do: 19
  def get_facility(:local4), do: 20
  def get_facility(:local5), do: 21
  def get_facility(:local6), do: 22
  def get_facility(:local7), do: 23

  @spec set_severity(t(), 0..7 | severity()) :: t()
  def set_severity(%__MODULE__{} = syslog, 0), do: %__MODULE__{syslog | severity: :emergency}

  def set_severity(%__MODULE__{} = syslog, :emergency),
    do: %__MODULE__{syslog | severity: :emergency}

  def set_severity(%__MODULE__{} = syslog, 1), do: %__MODULE__{syslog | severity: :alert}
  def set_severity(%__MODULE__{} = syslog, :alert), do: %__MODULE__{syslog | severity: :alert}
  def set_severity(%__MODULE__{} = syslog, 2), do: %__MODULE__{syslog | severity: :critical}

  def set_severity(%__MODULE__{} = syslog, :critical),
    do: %__MODULE__{syslog | severity: :critical}

  def set_severity(%__MODULE__{} = syslog, 3), do: %__MODULE__{syslog | severity: :error}
  def set_severity(%__MODULE__{} = syslog, :error), do: %__MODULE__{syslog | severity: :error}
  def set_severity(%__MODULE__{} = syslog, 4), do: %__MODULE__{syslog | severity: :warning}
  def set_severity(%__MODULE__{} = syslog, :warn), do: %__MODULE__{syslog | severity: :warning}
  def set_severity(%__MODULE__{} = syslog, :warning), do: %__MODULE__{syslog | severity: :warning}
  def set_severity(%__MODULE__{} = syslog, 5), do: %__MODULE__{syslog | severity: :notice}
  def set_severity(%__MODULE__{} = syslog, :notice), do: %__MODULE__{syslog | severity: :notice}
  def set_severity(%__MODULE__{} = syslog, 6), do: %__MODULE__{syslog | severity: :info}
  def set_severity(%__MODULE__{} = syslog, :info), do: %__MODULE__{syslog | severity: :info}
  def set_severity(%__MODULE__{} = syslog, 7), do: %__MODULE__{syslog | severity: :debug}
  def set_severity(%__MODULE__{} = syslog, :debug), do: %__MODULE__{syslog | severity: :debug}

  def get_severity(:emergency), do: 0
  def get_severity(:alert), do: 1
  def get_severity(:critical), do: 2
  def get_severity(:error), do: 3
  def get_severity(:warning), do: 4
  def get_severity(:notice), do: 5
  def get_severity(:info), do: 6
  def get_severity(:debug), do: 7

  def get_prival(%__MODULE__{facility: nil, severity: nil}), do: nil

  def get_prival(%__MODULE__{facility: facility, severity: severity}) do
    get_facility(facility) * 8 + get_severity(severity)
  end

  ~w[ version hostname ip_address app_name process_id message_id timestamp message ]a
  |> Enum.map(fn key ->
    fname = String.to_atom("set_#{to_string(key)}")

    @spec unquote(fname)(t(), term) :: t()
    @doc false
    def unquote(fname)(%__MODULE__{} = syslog, value) do
      %__MODULE__{syslog | unquote(key) => value}
    end
  end)

  def add_structured_data(%__MODULE__{structured_data: structured_data} = syslog, name, value) do
    %__MODULE__{syslog | structured_data: Map.put(structured_data, name, value)}
  end
end
