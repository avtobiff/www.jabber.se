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

-module(action_jquery_attr).
-export([render_action/1]).

-include("include/ui.hrl").

render_action(#disable{
        target = Target}) ->
    #jquery_attr{
        target = Target,
        key = disabled,
        value = disabled};

render_action(#enable{
        target = Target}) ->
    #jquery_cast{
        target = Target,
        cast = removeAttr,
        arg = disabled};

render_action(#jquery_attr{
        anchor = Anchor,
        target = Target,
        key = Key,
        value = Value}) ->
    KeyS = atom_to_list(Key),
    ValueS = atom_to_list(Value),
    wf:f("objs('~s', '~s').attr('~s', '~s');", [Target, Anchor, KeyS, ValueS]).


