% ANSI color codes
color_code(reset, '\033\[0m').
color_code(red, '\033\[31m').
color_code(green, '\033\[32m').
color_code(yellow, '\033\[33m').
color_code(blue, '\033\[34m').
color_code(magenta, '\033\[35m').
color_code(cyan, '\033\[36m').
color_code(white, '\033\[37m').
color_code(gray, '\033\[90m').
color_code(bold, '\033\[1m').

% Special characters
special_char(top-left, '\x250C\').
special_char(top-right, '\x2510\').
special_char(bottom-left, '\x2514\').
special_char(bottom-right, '\x2518\').
special_char(horizontal, '\x2500\').
special_char(vertical, '\x2502\').
special_char(intersection, '\x253C\').
special_char(top-t, '\x252C\').
special_char(bottom-t, '\x2534\').
special_char(left-t, '\x251C\').
special_char(right-t, '\x2524\').

% write_special_char(+Char) 
% Writes a special ANSI character
write_special_char(Char) :-
	special_char(Char, Code),
	write(Code).

% write_colored(+Text, +Color)
% Writes a text in a given color
write_colored(Text, Color) :-
	color_code(Color, Code),
	write(Code),
	write(Text),
	color_code(reset, ResetCode),
	write(ResetCode).

% Clears the screen
clear_screen :-
	write('\033\[2J\033\[H').

% Clears the buffer
clear_buffer :-
	repeat,
	get_char(C),
	C = '\n'.

% abs(+X, -Y)
% Y is the absolute value of X
abs(X, X) :- X >= 0, !.
abs(X, Y) :- X < 0, Y is -X.

% between(+Min, +Max, -Value)
% Value is between Min and Max
% Source: Fábio Sá
between(Min, Max, Min):- Min =< Max.
between(Min, Max, Value):-
    Min < Max,
    NextMin is Min + 1,
    between(NextMin, Max, Value).

% read_number(-X)
% Reads a number from the input
% Source: Fábio Sá
read_number(X):-
    read_number_aux(X, 0).
read_number_aux(X, Acc) :- 
    get_code(C),
    between(48, 57, C), !,
    Acc1 is 10 * Acc + (C - 48),
    read_number_aux(X, Acc1).
read_number_aux(X, X).

% get_number(+Min, +Max, +Context, -Value)
% Reads a number between Min and Max
% Source: Fábio Sá
get_number(Min, Max, Context, Value):-
    format('~a between ~d and ~d: ', [Context, Min, Max]),
    repeat,
    read_number(Value),
    between(Min, Max, Value), 
    !.

% replace(+List, +N, +Elem, -NewList)
% Replaces the N-th element of List with Elem
replace([_ | T], 1, Elem, [Elem | T]).
replace([H | T], N, Elem, [H | NewT]) :-
    N > 1,
    N1 is N - 1,
    replace(T, N1, Elem, NewT).
