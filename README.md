#Parserl

A small Erlang utility library that parses delimited text, including "qualified" text (i.e. - text identifiers of some sort are in use).  It supports multi-char delimiters and qualifiers, will evaluate escaped (doubled) qualifiers, optionally trim whitespace off the value and can handle newlines, etc. inside a qualified field.  Parserl is *not* responsible for reading a file or stream, so you'll need to wire that piece up on your own (though look at the examples section of this repo in the future for good implementation ideas) - just simply call Parserl from the Erlang server/app in which you're reading a file/stream and hand lines off to Parserl as they are ready.

#Credit

The company I work for - Terenine - deserves tons of credit for enabling me to work on this problem on-the-clock in addition to the late hours I've invested into it.

#How To Use

```erlang 
	% Parsing a string with comma delimiters and quote qualifiers
	TestString = "10,\"Some quoted Text\",plain text,\"Some \"\"escaped qualifiers\"\"\"".
	parserl:parse_string(TestString, ",", "\"").
    % ["10","Some quoted Text","plain text","Some \"escaped qualifiers\""]


	% Parsing a string with multi-char delimiters and qualifiers
	TestStringB = "10~~||Some \"quoted\" Text||~~plain text~~||Some ||||escaped qualifiers||||||".
	parserl:parse_string(TestString, "~~", "||").
    % ["10,\"10","Some \"quoted\" Text","plain text","Some ||escaped qualifiers||"]

	% Parsing a string where we want to preserve whitespace
    % Note that the last argument (the empty list) is replacing the normal
    % default three argument function call, allowing you to override
    % the options normally passed in.  (The default options are trim_left and trim_right.)
	TestStringC = " This, line, has, spaces, before, each, value".
	parserl:parse_string(TestStringC, ",","", []).
    % [" This"," line"," has"," spaces"," before"," each"," value"]
```

	
