# Copyright (c) 2015 Andi Pieper

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


defmodule Couch.UUIDs do
  # implmentation without the server stuff, which is a bit overdone, me thinks.

  # use GenServer

  # @start_retry 200
  # @max_retry 10000

  #ä return a random uuid
  def random() do
    List.to_string :hackney_bstr.to_hex(:crypto.rand_bytes(16))
  end

  def utc_random do
    utc_suffix(:hackney_bstr.to_hex(:crypto.rand_bytes(9)))
  end

  def utc_suffix(suffix) do
    now = {_, _, micro} = :erlang.timestamp()
    nowish = :calendar.now_to_universal_time(now)
    nowsecs = :calendar.datetime_to_gregorian_seconds(nowish)
    then = :calendar.datetime_to_gregorian_seconds({{1970, 1, 1}, {0, 0, 0}})
    prefix = :io_lib.format('~14.16.0b', [(nowsecs - then) * 1000000 + micro])
    List.to_string(prefix ++ suffix)
  end    

  def get_uuids(_server, count) do
    add_uuids([], count)
  end

  defp add_uuids(acc, count)  when length(acc) >= count do
    acc
  end
  defp add_uuids(acc, count) do
    add_uuids [utc_random | acc], count
  end


  # def start_link() do
  #   GenServer.start_link({:local, __MODULE__}, __MODULE__, [], [])
  # end


  # def get_uuids(server, count) do
  #   GenServer.call(__MODULE__, {:get_uuids, server, count})
  # end

  # # server callbacks
  # def init do
  #   :process_flag(:trap_exit, true)
  #   :ets.new(:couchbeam_uuids, [:named_table, :public, {:keypos, 2}])
  #   {ok, %{}}
  # end

  # def handle_call(:get_uuids, server, count}, _from, state) do
  #   {:ok, uuids} = do_get_uuids(server, count, [], :ets.lookup(:couchbeam_uuids, server.url))
  #   {:reply, uuids, state}
  # end

  # def handle_cast(_msg, state) do
  #   {:noreply, state}
  # end

  # def handle_info(_info, itate) do
  #   {:noreply, State}
  # end

  # def terminate(_reason, _state) do
  #   :ok
  # end

  # def code_change(_oldVsn, state, _Eetra) do
  #   {:ok, state}
  # end


  # # private stuff
  # defp do_get_uuids(_server, count, acc, _) when length(acc) >= count do
  #   {:ok, acc}
  # end
  # defp do_get_uuids(server, count, acc, []) do
  #   {:ok, server_uuids} = get_new_uuids(server)
  #   do_get_uuids(server, count, acc, [server_uuids])
  # end
  # defp do_get_uuids(server, count, acc, )

end