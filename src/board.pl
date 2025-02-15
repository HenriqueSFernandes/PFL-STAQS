% get_board(+BoardSize, -Board) 
% Creates a new board of size BoardSize
get_board(BoardSize, Board) :-
	length(Board, BoardSize),
	maplist(create_row(BoardSize), Board).

% create_row(+Size, -Row)
% Creates a new row of size Size
create_row(Size, Row) :-
	length(Row, Size),
	maplist(=(blank), Row).

% print_top_border(+Length)
% Prints the top border with T-shaped connectors
print_top_border(BoardSize) :-
  write('   '),
	write_special_char(top-left),
	InnerLength is BoardSize - 1,
	print_top_border_aux(InnerLength),
	write_special_char(horizontal),
	write_special_char(horizontal),
	write_special_char(top-right),
	nl.
	
% print_top_border_aux(+Length) 
% Auxiliary predicate to print the top border
print_top_border_aux(0).
print_top_border_aux(N) :-
	write_special_char(horizontal),
	write_special_char(horizontal),
	write_special_char(top-t),
	N1 is N - 1,
	print_top_border_aux(N1).


% print_bottom_border(+Length)
% Prints the bottom border with T-shaped connectors
print_bottom_border(BoardSize) :-
  write('   '),
	write_special_char(bottom-left),
	InnerLength is BoardSize - 1,
	print_bottom_border_aux(InnerLength),
	write_special_char(horizontal),
	write_special_char(horizontal),
	write_special_char(bottom-right),
	nl.

% print_bottom_border_aux(+Length)
% Auxiliary predicate to print the bottom border
print_bottom_border_aux(0).
print_bottom_border_aux(N) :-
	write_special_char(horizontal),
	write_special_char(horizontal),
	write_special_char(bottom-t),
	N1 is N - 1,
	print_bottom_border_aux(N1).

% print_row_separator(+Length)
% Prints a row separator with intersections
print_row_separator(BoardSize) :-
	write('   '),
	write_special_char(left-t),
	InnerLength is BoardSize - 1,
	print_row_separator_aux(InnerLength),
	write_special_char(horizontal),
	write_special_char(horizontal),
	write_special_char(right-t),
	nl.

% print_row_separator_aux(+Length)
% Auxiliary predicate to print the row separator
print_row_separator_aux(0).
print_row_separator_aux(N) :-
	write_special_char(horizontal),
	write_special_char(horizontal),
	write_special_char(intersection),
	N1 is N - 1,
	print_row_separator_aux(N1).

% print_row(+Row)
% Prints a row
print_row(Row) :-
	write_special_char(vertical),
	maplist(print_piece, Row),
	nl.

% print_rows(+Board)
% Prints all rows
print_rows(Board) :-
	length(Board, Length),
	print_rows_aux(Length, Board, Length).

% print_rows_aux(+N, +Board, +Total)
% Auxiliary predicate to print all rows
print_rows_aux(0, _, _).
print_rows_aux(1, [Row], _) :-
	write('1  '),
	print_row(Row).
print_rows_aux(N, [Row|Rest], Total) :-
	N < 10,
	write(N),
	write('  '),
	print_row(Row),
	print_row_separator(Total),
	N1 is N - 1,
	print_rows_aux(N1, Rest, Total).
print_rows_aux(N, [Row|Rest], Total) :-
	write(N),
	write(' '),
	print_row(Row),
	print_row_separator(Total),
	N1 is N - 1,
	print_rows_aux(N1, Rest, Total).

% print_piece(+Piece)
% Prints a piece. If it is blank, prints a gray 1, if it is a number, prints it in blue, if it is a negative number, prints it in red, if it is none, prints a space.
print_piece(blank) :- 
		write_colored(' 1', gray),
		write_special_char(vertical).

print_piece(none) :-
		write('  '), % Print empty piece
		write_special_char(vertical).

print_piece(N) :- 
		N > 9,
		write_colored(N, blue),
		write_special_char(vertical).

print_piece(N) :- 
		N > 0,
		write(' '),
		write_colored(N, blue),
		write_special_char(vertical).

print_piece(N) :-
		N < -9,
		abs(N, N1),
		write_colored(N1, red),
		write_special_char(vertical).

print_piece(N) :-
		N < 0,
		abs(N, N1),
		write(' '),
		write_colored(N1, red),
		write_special_char(vertical).

% print_bottom_coordinates(+Length)
% Prints the bottom (X) coordinates
print_bottom_coordinates(Length) :-
	write('  '),
	print_bottom_coordinates_aux(Length, 1),
	nl.

% print_bottom_coordinates_aux(+N, +N)
% Auxiliary predicate to print the bottom coordinates
print_bottom_coordinates_aux(0, _).
print_bottom_coordinates_aux(N, N) :-
	write('  '),
	write(N),
	N1 is N + 1.

print_bottom_coordinates_aux(N, M) :-
	write(' '),
	write(' '),
	write(M),
	M1 is M + 1,
	print_bottom_coordinates_aux(N, M1).

% print_board(+Board)
% Prints the entire board
print_board(Board) :-
    length(Board, Length),
    print_top_border(Length),  % Print the top border
		print_rows(Board),  
    print_bottom_border(Length),  % Print the bottom border
		print_bottom_coordinates(Length).  % Print the bottom coordinates

% get_piece(+Column, +Row, +Board, -Piece)
% Gets the piece at the specified row and column
get_piece(Column, Row, Board, Piece) :-
    reverse(Board, ReversedBoard),
    nth1(Row, ReversedBoard, BoardRow), 
    nth1(Column, BoardRow, Piece).

% set_piece(+Row, +Column, +Piece, +Board, -NewBoard)
% Sets the piece at the specified row and column
set_piece(Column, Row, Piece, Board, NewBoard) :-
    reverse(Board, ReversedBoard),
    nth1(Row, ReversedBoard, BoardRow),
    replace(BoardRow, Column, Piece, NewRow),
    replace(ReversedBoard, Row, NewRow, NewReversedBoard),
    reverse(NewReversedBoard, NewBoard).
