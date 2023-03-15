defmodule Kvasir.Syslog.Encode do
  alias Kvasir.Syslog
  require Logger

  defimpl String.Chars, for: Syslog do
    defp get_prival(syslog) do
      if prival = Syslog.get_prival(syslog), do: "<#{prival}>", else: ""
    end

    defp get_timestamp(nil), do: ""

    defp get_timestamp(ts) do
      day = String.pad_leading(Kernel.to_string(ts.day), 2, " ")

      time =
        DateTime.to_time(ts)
        |> Time.truncate(:second)

      year = ts.year

      case Date.utc_today().year do
        ^year -> "#{month(ts.month)} #{day} #{time} "
        _ -> "#{year} #{month(ts.month)} #{day} #{time} "
      end
    end

    defp get_message(syslog) do
      case structured_data(syslog.structured_data) do
        "-" -> syslog.message
        structured_data -> "#{structured_data} #{syslog.message}"
      end
    end

    defp get_hostname(syslog) do
      case {syslog.hostname, syslog.ip_address} do
        {nil, nil} -> ""
        {hostname, nil} -> "#{hostname} "
        {hostname, ip_address} -> "#{hostname} #{ip_address} "
      end
    end

    defp get_app_name(syslog) do
      case {syslog.app_name, syslog.process_id} do
        {nil, nil} -> ""
        {app_name, nil} -> "#{app_name}: "
        {app_name, pid} -> "#{app_name}[#{pid}]: "
      end
    end

    def to_string(%Syslog{rfc: :rfc3164, timestamp: ts} = syslog) do
      Enum.join([
        get_prival(syslog),
        get_timestamp(ts),
        get_hostname(syslog),
        get_app_name(syslog),
        get_message(syslog)
      ])
    end

    def to_string(%Syslog{rfc: :rfc5424} = syslog) do
      prival = Syslog.get_prival(syslog)
      timestamp = timestamp(syslog.timestamp)

      "<#{prival}>#{syslog.version} #{timestamp || "-"} #{syslog.hostname || "-"} " <>
        "#{syslog.app_name || "-"} #{syslog.process_id || "-"} #{syslog.message_id || "-"} " <>
        "#{structured_data(syslog.structured_data)}#{maybe_message(syslog.message)}"
    end

    defp timestamp(nil), do: nil

    defp timestamp(ts) do
      Kernel.to_string(ts)
      |> String.split(" ")
      |> Enum.join("T")
    end

    defp maybe_message(nil), do: ""
    defp maybe_message(message), do: " " <> message

    defp structured_data(map) when map_size(map) == 0, do: "-"

    defp structured_data(structured_data) do
      Enum.map_join(structured_data, fn {id, params} ->
        "[#{id} #{params(params)}]"
      end)
    end

    defp params(params) do
      Enum.map_join(params, " ", fn {key, value} ->
        "#{key}=\"#{escape(value)}\""
      end)
    end

    defp escape(value) do
      value
      |> String.replace("\\", "\\\\")
      |> String.replace("\"", "\\\"")
      |> String.replace("]", "\\]")
    end

    defp month(1), do: "Jan"
    defp month(2), do: "Feb"
    defp month(3), do: "Mar"
    defp month(4), do: "Apr"
    defp month(5), do: "May"
    defp month(6), do: "Jun"
    defp month(7), do: "Jul"
    defp month(8), do: "Aug"
    defp month(9), do: "Sep"
    defp month(10), do: "Oct"
    defp month(11), do: "Nov"
    defp month(12), do: "Dec"
  end
end
