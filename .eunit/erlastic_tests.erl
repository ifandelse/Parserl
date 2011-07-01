-module(erlastic_tests).
-include_lib("eunit/include/eunit.hrl").

parse_empty_unqualified_test() ->
    [[],[],[],[],[]] = erlastic:parse_string(",,,,", ",","").

parse_empty_unqualified_dual_compound_delimiter_test() ->
    [[],[],[],[],[],[]] = erlastic:parse_string("~$~$~$~$~$", "~$","").

parse_empty_unqualified_dual_compound_same_delimiter_test() ->
    [[],[],[],[],[],[]] = erlastic:parse_string(",,,,,,,,,,", ",,","").

parse_empty_unqualified_triple_compound_delimiter_test() ->
    [[],[],[],[],[],[]] = erlastic:parse_string("~$~~$~~$~~$~~$~", "~$~","").

parse_empty_unqualified_triple_compound_same_delimiter_test() ->
    [[],[],[],[],[],[]] = erlastic:parse_string(",,,,,,,,,,,,,,,", ",,,","").

parse_unqualified_string_test() ->
    ["10","11","12","13","14","15"] = erlastic:parse_string("10,11,12,13,14,15", ",", "").

parse_unqualified_string_with_compound_delimiter_test() ->
    ["Bugs","Bunny","Road","Runner",[],"10"] = erlastic:parse_string("Bugs~$Bunny~$Road~$Runner~$~$10", "~$", "").

parse_empty_qualified_compound_same_delimiter_test() ->
    [[],[],[],[],[],[]] = erlastic:parse_string("\"\",,\"\",,\"\",,\"\",,\"\",,\"\"", ",,","\"").

parse_empty_qualified_test() ->
    [[],[],[],[],[]] = erlastic:parse_string("\"\",\"\",\"\",\"\",\"\"", ",", "\"").

parse_qualified_string_test() ->
    ["10","11","12","13","14","15"] = erlastic:parse_string("\"10\",\"11\",\"12\",\"13\",\"14\",\"15\"", ",", "\"").

parse_qualified_string_with_escaped_qualifiers_in_field_test() ->
    ["Field 1","Field 2","Field with \"escaped qualifiers\""] = erlastic:parse_string("\"Field 1\",\"Field 2\",\"Field with \"\"escaped qualifiers\"\"\"", ",", "\"").

parse_qualified_string_with_escaped_qualifiers_and_nested_delims_test() ->
    ["Field 1","Field 2","Field with \",,escaped qualifiers,,\""] = erlastic:parse_string("\"Field 1\",\"Field 2\",\"Field with \"\",,escaped qualifiers,,\"\"\"", ",", "\"").

parse_qualified_string_with_escaped_qualifiers_and_nested_delimsB_test() ->
    ["Field 1","Field 2","\",,escaped qualifiers,,\""] = erlastic:parse_string("\"Field 1\",\"Field 2\",\"\"\",,escaped qualifiers,,\"\"\"", ",", "\"").

parse_qualified_string_with_escaped_qualifiers_and_nested_delimsC_test() ->
    ["Field 1","Field 2","Some \",,escaped qualifiers,,\" here"] = erlastic:parse_string("\"Field 1\",\"Field 2\",\"Some \"\",,escaped qualifiers,,\"\" here\"", ",", "\"").

parse_qualified_string_surrounded_by_empty_unqualifieds_test() ->
   [[],"Field 2","Some \",,escaped qualifiers,,\" here",[]] = erlastic:parse_string(",\"Field 2\",\"Some \"\",,escaped qualifiers,,\"\" here\",", ",", "\"").

parse_qualified_string_surrounded_by_empty_qualifieds_test() ->
    [[],"Field 2","Some \",,escaped qualifiers,,\" here",[]] = erlastic:parse_string("\"\",\"Field 2\",\"Some \"\",,escaped qualifiers,,\"\" here\",\"\"", ",", "\"").

parse_qualified_string_with_nested_delims_at_start_of_field_test() ->
    ["Field 1","Field 2",",,escaped qualifiers,, hi"] = erlastic:parse_string("\"Field 1\",\"Field 2\",\",,escaped qualifiers,, hi\"", ",", "\"").

parse_qualified_string_with_nested_delims_at_end_of_field_test() ->
    ["Field 1","Field 2","hi ,,escaped qualifiers,,"] = erlastic:parse_string("\"Field 1\",\"Field 2\",\"hi ,,escaped qualifiers,,\"", ",", "\"").

parse_qualified_string_with_nested_delims_as_entire_field_test() ->
    ["Field 1","Field 2",",,escaped qualifiers,,"] = erlastic:parse_string("\"Field 1\",\"Field 2\",\",,escaped qualifiers,,\"", ",", "\"").

parse_qualified_string_with_compound_delimiter_test() ->
    ["Bugs","Bunny","Road","Runner",[],"10"] = erlastic:parse_string("\"Bugs\"~$\"Bunny\"~$\"Road\"~$\"Runner\"~$~$10", "~$", "\"").

parse_qualified_string_with_compound_triple_delimiter_test() ->
    ["Bugs","Bunny","Road","Runner",[],"10"] = erlastic:parse_string("\"Bugs\"=:=\"Bunny\"=:=\"Road\"=:=\"Runner\"=:==:=10", "=:=", "\"").

parse_qualified_string_with_escaped_qualifiers_in_field_and_spaced_test() ->
    ["Field 1","Field 2","Field with \"escaped qualifiers\""] = erlastic:parse_string("\"Field 1\", \" Field 2\", \" Field with \"\"escaped qualifiers\"\"\"", ",", "\"").

parse_qualified_string_with_escaped_qualifiers_and_nested_delims_and_spaced_test() ->
    ["Field 1","Field 2","Field with \",,escaped qualifiers,,\""] = erlastic:parse_string("\"Field 1\", \" Field 2\", \" Field with \"\",,escaped qualifiers,,\"\"\"", ",", "\"").

parse_qualified_string_with_escaped_qualifiers_and_nested_delimsB_and_spaced_test() ->
    ["Field 1","Field 2","\",,escaped qualifiers,,\""] = erlastic:parse_string("\" Field 1\", \" Field 2\", \" \"\",,escaped qualifiers,,\"\"\"", ",", "\"").

parse_qualified_string_with_escaped_qualifiers_and_nested_delimsC_and_spaced_test() ->
    ["Field 1","Field 2","Some \",,escaped qualifiers,,\" here"] = erlastic:parse_string("\" Field 1 \", \" Field 2 \", \" Some \"\",,escaped qualifiers,,\"\" here\"", ",", "\"").

parse_qualified_string_surrounded_by_empty_unqualifieds_and_spaced_test() ->
   [[],"Field 2","Some \",,escaped qualifiers,,\" here",[]] = erlastic:parse_string(",\" Field 2\", \" Some \"\",,escaped qualifiers,,\"\" here\",", ",", "\"").
    
