%% name of module must match file name
%% Contribution: @realbudhead
-module(mod_offline_http_post).
-author("dev@codepond.org").

-behaviour(gen_mod).

-export([start/2, stop/1, create_message/1, create_message/3]).

-include("ejabberd.hrl").
-include("xmpp.hrl").
-include("logger.hrl").

start(_Host, _Opt) ->
        ?INFO_MSG("mod_offline_http_post loading", []),
        inets:start(),
        ?INFO_MSG("HTTP client started", []),
        ejabberd_hooks:add(offline_message_hook, _Host, ?MODULE, create_message, 1).

stop (_Host) ->
        ?INFO_MSG("stopping mod_offline_http_post", []),
        ejabberd_hooks:delete(offline_message_hook, _Host, ?MODULE, create_message, 1).

create_message({Action, Packet} = Acc) when (Packet#message.type == chat) and (Packet#message.body /= []) ->
        [{text, _, Body}] = Packet#message.body,
        post_offline_message(Packet#message.from, Packet#message.to, Body, "SubType", Packet#message.id),
        Acc.

create_message(_From, _To, Packet) when (Packet#message.type == chat) and (Packet#message.body /= []) ->
        Body = fxml:get_path_s(Packet, [{elem, list_to_binary("body")}, cdata]),
        MessageId = fxml:get_tag_attr_s(list_to_binary("id"), Packet),
        post_offline_message(_From, _To, Body, "SubType", MessageId),
        ok.

post_offline_message(From, To, Body, SubType, MessageId) ->
        Token = gen_mod:get_module_opt(To#jid.lserver, ?MODULE, auth_token, fun(S) -> iolist_to_binary(S) end, list_to_binary("")),
        PostUrl = gen_mod:get_module_opt(To#jid.lserver, ?MODULE, post_url, fun(S) -> iolist_to_binary(S) end, list_to_binary("")),
        AuthTokenKey = gen_mod:get_module_opt(To#jid.lserver, ?MODULE, auth_token_key, fun(S) -> iolist_to_binary(S) end, list_to_binary("access_token")),
        ToUser = To#jid.luser,
        FromUser = From#jid.luser,
        Vhost = To#jid.lserver,
        ?INFO_MSG("Posting From ~p To ~p Body ~p",[FromUser, ToUser, Body]),
        Data = string:join([binary_to_list(AuthTokenKey), binary_to_list(Token), "&to=", binary_to_list(ToUser), "&from=", binary_to_list(FromUser), "&vhost=", binary_to_list(Vhost), "&body=", binary_to_list(Body), "&messageId=", binary_to_li$
        Request = {binary_to_list(PostUrl), [{"Authorization", binary_to_list(Token)}], "application/x-www-form-urlencoded", Data},
        httpc:request(post, Request,[],[]),
        ?INFO_MSG("post request sent", []).
