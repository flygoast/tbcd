%%%
%%% Copyright (c) 2015, Gu Feng <flygoast@126.com>
%%%
%%% All rights reserved.
%%%
%%% Redistribution and use in source and binary forms, with or without
%%% modification, are permitted provided that the following conditions
%%% are met:
%%% 1. Redistributions of source code must retain the above copyright
%%%    notice, this list of conditions and the following disclaimer.
%%% 2. Redistributions in binary form must reproduce the above copyright
%%%    notice, this list of conditions and the following disclaimer in the
%%%    documentation and/or other materials provided with the distribution.
%%%
%%% THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
%%% ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%%% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%%% ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
%%% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
%%% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
%%% OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
%%% HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
%%% LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
%%% OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
%%% SUCH DAMAGE.
%%%
-module(tbcd_acl).
-author('flygoast@126.com').


-export([acl_start/0,
         acl_allow/1,
         acl_add/1,
         acl_del/1,
         acl_real_del/1]).


-record(acl, {ip = undefined, status = undefined}).


acl_start() ->
    case mnesia:create_table(acl,
                             [{disc_copies, [node()]},
                              {attributes, record_info(fields, acl)}]) of
    {aborted, Reason} ->
        case Reason of
        {already_exists, _} ->
            ok;
        _ ->
            lager:alert("create table 'acl' failed: ~p", [Reason]),
            erlang:error(create_table_error)
        end;
    {atomic, ok} ->
        ok
    end,

    ok.


acl_allow(IP) ->
    case mnesia:dirty_read(acl, IP) of
    [] ->
        no;
    [#acl{status = undefined}] ->
        no;
    [#acl{status = used}] ->
        yes
    end.


acl_add(IP) ->
    mnesia:dirty_write(acl, #acl{ip = IP, status = used}).


acl_del(IP) ->
    mnesia:dirty_write(acl, #acl{ip = IP, status = undefined}).


acl_real_del(IP) ->
    mnesia:dirty_delete(acl, IP).
