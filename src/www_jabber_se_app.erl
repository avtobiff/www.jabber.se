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

-module (www_jabber_se_app).
-export ([start/2, stop/0, stop/1, out/1, out/2, out/3]).
-behavior(application).

-include("include/config.hrl").
-include("include/utils.hrl").

-define(PORT, 8000).

start(_, _) ->
    % start jabber.se modules
    lists:foreach(fun(Module) -> Module:start() end, ?MODULES),

    % start yaws
    yaws_bundle:start().

stop(_) -> stop().
stop() ->
    yaws_bundle:stop().

out(Arg) ->
    RequestBridge = simple_bridge:make_request(yaws_request_bridge, Arg),
    ResponseBridge = simple_bridge:make_response(yaws_response_bridge, Arg),
    nitrogen:init_request(RequestBridge, ResponseBridge),
    nitrogen:run().

out(Arg, Module) -> out(Arg, Module, "").

out(Arg, Module, PathInfo) ->
    ?LOG_WARNING("Unhandled ~p ~p ~p", [Arg, Module, PathInfo]).

