-module(erlastic).

-export([parse_string/3, parse_string/4]).       

parse_string(Line, Delimiter, Qualifier) ->
    parse_string(Line, Delimiter, Qualifier, [trim_left, trim_right]).

parse_string(Line, Delimiter, Qualifier, Options)->
    QualifierLen = string:len(Qualifier),
    DelimiterLen = string:len(Delimiter),
    Delims = lists:append([ line_start | sterling:find_all_positions(Line, Delimiter) ], [line_end]),
    Quals = sterling:find_all_positions(Line, Qualifier),
    ActualDelims = purge_false_delims(Delims, Quals),
    Fields = eval_escapes(
               remove_qualifiers(
                 parse_fields(
                   build_field_map(ActualDelims)
                   ,Line
                   ,DelimiterLen)
                 ,Qualifier
                 ,QualifierLen)
               ,Qualifier),
    apply_options(Fields, Options).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%        Use Delimiter Positions to build start, end coordinates for each field         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
build_field_map(Delims) ->
    build_field_map(Delims, []).

build_field_map([line_end | []], Accum) ->
    lists:reverse(Accum);
build_field_map([FieldStart | [FieldStop | _ ] = Rest], Accum) ->
    build_field_map(Rest, [ {FieldStart, FieldStop} | Accum ]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    Remove positions of delimiters that are legitimately inside a qualified field      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
purge_false_delims(Delims, []) ->
    Delims;
purge_false_delims(Delims, [_ | []]) ->
    purge_false_delims(Delims, []);
purge_false_delims(Delims, [QFirst | [ QSecond | []  ]]) ->
    NewDelims = lists:filter(fun(Elem) ->
                                     if
                                         Elem == line_start -> true;
                                         Elem == line_end -> true;
                                         true -> Elem < QFirst orelse Elem > QSecond
                                     end
                             end,
                             Delims),
    purge_false_delims(NewDelims, []);
purge_false_delims(Delims, [QFirst | [ QSecond | Quals ] ]) ->
    NewDelims = lists:filter(fun(Elem) ->
                                     if
                                         Elem == line_start -> true;
                                         Elem == line_end -> true;
                                         true -> Elem < QFirst orelse Elem > QSecond
                                     end
                             end,
                             Delims),
    purge_false_delims(NewDelims, Quals).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%      Use the Field Map to extract the actual data for each field from the string      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parse_fields(FieldMap, Line, DelimiterLen) ->
    parse_fields(FieldMap, Line, DelimiterLen, string:len(Line), []).

parse_fields(Accum) ->
    lists:reverse(Accum).

parse_fields([], _, _, _, Accum) ->
    lists:reverse(Accum);
parse_fields([{line_start, line_end} | _], _, _, _, Accum) ->
    parse_fields([ [] | Accum ]);
parse_fields([{line_start, 1} | Rest ], Line, DelimiterLen, Len, Accum) ->
    parse_fields(Rest, Line, DelimiterLen, Len, [ [] | Accum ]);
parse_fields([{line_start, FieldStop} | Rest ], Line, DelimiterLen, Len, Accum) ->
    parse_fields(Rest, Line, DelimiterLen, Len, [ string:sub_string(Line, 1, FieldStop - 1) | Accum ]);
parse_fields([{FieldStart, line_end} | _ ], _, _, Len, Accum) when FieldStart =:= Len ->
    parse_fields([ [] | Accum ]);
parse_fields([{FieldStart, line_end} | _ ], Line, DelimiterLen, _, Accum) ->
    parse_fields([ string:sub_string(Line, FieldStart + DelimiterLen) | Accum ]);
parse_fields([{Position, Position} | Rest ], Line, DelimiterLen, Len, Accum) ->
    parse_fields(Rest, Line, DelimiterLen, Len, [ [] | Accum ]);
parse_fields([{FieldStart, FieldStop} | Rest ], Line, DelimiterLen, Len, Accum) ->
    parse_fields(Rest, Line, DelimiterLen, Len, [ string:sub_string(Line, FieldStart + DelimiterLen, FieldStop - 1) | Accum ]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%         Remove leading and trailing qualifiers from the string if they exist          %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
remove_qualifiers(Fields, Qualifier, QLen) ->
    remove_qualifiers(Fields, [], Qualifier, QLen).

remove_qualifiers([], Accum, _, _) ->
    lists:reverse(Accum);
remove_qualifiers([First | Rest ], Accum, Qualifier, QLen)->
    Trimmed = string:strip(First, both),
    Start = string:substr(Trimmed, 1, QLen),
    if
        Start == Qualifier ->
            remove_qualifiers(Rest, [ string:sub_string(Trimmed, QLen + 1, string:len(Trimmed) - QLen) | Accum ], Qualifier, QLen);
        true ->
            remove_qualifiers(Rest, [ Trimmed | Accum ], Qualifier, QLen)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%               Evaluate (i.e - collapse) the escaped qualifier sequences               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eval_escapes(Fields, Qualifier)->
    eval_escapes(Fields, [], Qualifier).

eval_escapes([], Accum, _) ->
    lists:reverse(Accum);
eval_escapes([ Field | Rest ], Accum, Qualifier) ->
    TargetSeq = string:concat(Qualifier, Qualifier),
    TrimmedField = string:strip(Field, both),
    if
        TrimmedField == TargetSeq ->
            eval_escapes(Rest, [ sterling:gsubstitute_chars(TrimmedField, TargetSeq, "") | Accum ], Qualifier);
        true ->      
            eval_escapes(Rest, [ sterling:gsubstitute_chars(Field, TargetSeq, Qualifier) | Accum ], Qualifier)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%             Apply Parsing Options Before Returning Field List to Caller               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
apply_options(Fields, [])->
    Fields;
apply_options(Fields, [trim_left | Rest ]) ->
    apply_options(trim(Fields, left), Rest);
apply_options(Fields, [trim_right | Rest ]) ->
    apply_options(trim(Fields, right), Rest);
apply_options(Fields, [ _ | Rest ]) ->
    apply_options(Fields, Rest).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                    CLEANUP FUNCTIONS TO TRIM WHITESPACE IN FIELDS                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trim(Fields, Direction) ->
    trim(Fields, [], Direction).

trim([], Accum, _) ->
    lists:reverse(Accum);
trim([ Field | Rest ], Accum, Direction) ->
    NewAccum = [string:strip(Field, Direction) | Accum ],
    trim(Rest, NewAccum, Direction).
