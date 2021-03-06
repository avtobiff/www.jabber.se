%
%    Jabber.se Web Application
%    Copyright (C) 2010 Jonas Ådahl
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU Affero General Public License as
%    published by the Free Software Foundation, either version 3 of the
%    License, or (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU Affero General Public License for more details.
%
%    You should have received a copy of the GNU Affero General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%

-module(db_tests).

-include_lib("eunit/include/eunit.hrl").
-include("include/db/db.hrl").

init() ->
    db_controller:start().

close(_) ->
    db_controller:stop().

start_stop_test() ->
    %?assert(init() =:= ok),
    ?debugMsg("Initiated"),

    %?assert(close(ok) =:= ok),
    ?debugMsg("Closed"),

    ok.

db_test_() ->
    Tests =
    [
        fun test_new_and_delete_doc/0,
        fun test_save_read_post/0,
        fun test_edit_post/0,
        fun test_drafts/0
    ],
    {setup, fun init/0, fun close/1, {inorder, Tests}}.

test_new_and_delete_doc() ->
    NewId = case db_post:new_post() of
        #db_post{
            id = Id,
            state = draft,
            title = [],
            tags = [],
            authors = [],
            body = ""} ->
            ?assert(is_binary(Id)),
            Id;
        _ ->
            ?assert(false)
    end,

    {Entries} = db_controller:delete_doc_by_id(NewId),
    ?assert(lists:nth(1, Entries) =:= {<<"_deleted">>, true}).

ensure_deleted(Id) ->
    try
        {Entries} = db_controller:delete_doc_by_id(Id),
        ?assert(lists:nth(1, Entries) =:= {<<"_deleted">>, true})
    catch
        error:not_found ->
            ok;
        error:Error ->
            ?debugFmt("Error caught: '~p'", [Error]),
            ?assert(false)
    end.

test_save_read_post() ->
    OriginalPost = #db_post{
        id = <<"test_post">>,
        state = public,
        title = <<"test title">>,
        tags = [<<"foo">>, <<"bar">>],
        authors = [<<"Tester">>],
        body = <<"Testing various things.">>},

    ensure_deleted("test_post"),

    {Entries} = db_post:save_post(OriginalPost),
    ?assert(is_list(Entries)),

    NewPost = db_post:get_post("test_post"),

    ?assertEqual(OriginalPost, NewPost),

    ensure_deleted("test_post"),

    ok.

test_edit_post() ->
    OriginalPost = #db_post{
        id = <<"test_post">>,
        state = public,
        title = <<"test title">>,
        tags = [<<"foo">>, <<"bar">>],
        authors = [<<"Tester">>],
        body = <<"Testing various things.">>},

    ExpectedPost = OriginalPost#db_post{
        tags = [<<"foo">>, <<"baz">>],
        body = <<"Testing changes.">>
    },

    ensure_deleted("test_post"),

    % create initial post
    {Entries} = db_post:save_post(OriginalPost),
    ?assert(is_list(Entries)),

    db_post:set_body("Testing changes.", test_post),

    db_post:push_tag("baz", test_post),

    db_post:pop_tag("bar", test_post),

    NewPost = db_post:get_post(test_post),

    ?assertEqual(NewPost, ExpectedPost),

    ok.

test_drafts() ->
    Drafts = [
        #db_post{
            id = <<"test_post1">>,
            timestamp = 42,
            state = draft,
            title = <<"test title1">>,
            tags = [<<"foo">>, <<"bar">>],
            authors = [<<"Tester">>],
            body = <<"Testing various things #1.">>},
        #db_post{
            id = <<"test_post0">>,
            timestamp = 41,
            state = draft,
            title = <<"test title0">>,
            tags = [<<"foo">>, <<"bar">>],
            authors = [<<"Tester">>],
            body = <<"Testing various things #0.">>},
        #db_post{
            id = <<"test_post2">>,
            state = draft,
            title = <<"test title2">>,
            tags = [<<"foo">>, <<"bar">>],
            authors = [<<"retseT">>],
            body = <<"Testing various things #2.">>}
    ],

    ensure_deleted("test_post0"),
    ensure_deleted("test_post1"),
    ensure_deleted("test_post2"),

    [db_post:save_post(Post) || Post <- Drafts],

    Posts = db_post:get_drafts_by("Tester"),

    ?assertEqual(Posts, lists:sublist(Drafts, 2)),

    ensure_deleted("test_post0"),
    ensure_deleted("test_post1"),
    ensure_deleted("test_post2"),

    ok.
