:- use_module(library(lists)).
:- use_module(library(samsort)).
:- consult('utils.pl').
:- consult('board.pl').
:- consult('premade-game-states.pl').

% display_menu
% DIsplays the game menu with option for different game mode
display_menu :-
    nl,
    write_colored('=============================', cyan), nl,
    write_colored('         GAME MENU          ', cyan), nl, 
    write_colored('=============================', cyan), nl,
    write_colored('1. Player vs Player  ', green), nl, 
    write_colored('2. Player vs Easy Bot', green), nl, 
    write_colored('3. Player vs Hard Bot', green), nl, 
    write_colored('4. Bot vs Bot        ', green), nl, 
    write_colored('5. Puzzles           ', green), nl, 
    write_colored('6. Exit              ', red), nl, 
    nl.

% handle_level_choice(+Choice, -Level)
% Handles the game level choice.
handle_level_choice(1, 1).
handle_level_choice(2, 2).
handle_level_choice(3, 3).
handle_level_choice(4, 4).
handle_level_choice(5, 5) :-
	premade_game.

% handle_level_choice(+Choice)
% Handles the exit choice and terminates the program.
handle_level_choice(6, _) :-
	nl,
	write_colored('Exiting...', red),
	halt(0).

% Display the board size menu to the user
boardsize_menu :-
	nl,
	write_colored('=============================', cyan), nl,
	write_colored('       BOARD SIZE MENU       ', cyan), nl,
	write_colored('=============================', cyan), nl,
	write_colored('1. 5x5', green), nl,
	write_colored('2. 6x6', green), nl,
	write_colored('3. 7x7', green), nl,
	write_colored('4. 8x8', green), nl,
	write_colored('5. 9x9', green), nl,
	write_colored('6. 10x10', green), nl,
	write_colored('7. Exit', red), nl,
	nl.

% handle_boardsize_choice(+Choice, -BoardSize)
% Handles the board size choice and returns the board size accordingly.
handle_boardsize_choice(1, 5).
handle_boardsize_choice(2, 6).
handle_boardsize_choice(3, 7).
handle_boardsize_choice(4, 8).
handle_boardsize_choice(5, 9).
handle_boardsize_choice(6, 10).

% handle_boardsize_choice(+Choice)
% Handles the exit choice and terminates the program.
handle_boardsize_choice(7, _) :-
	nl,
	write_colored('Exiting...', red),
	halt(0).

% play
% Clears the screen, displays the menu, reads the user's choice, handles the choice,
% initializes the game state, and starts the game loop.
play :-
	clear_screen,
	display_menu,
	get_number(1, 6, 'Choose a game mode', Choice),	
	handle_level_choice(Choice, Level),
	boardsize_menu,
	get_number(1, 7, 'Choose a board size', BoardSizeChoice),
	handle_boardsize_choice(BoardSizeChoice, BoardSize),
	initial_state([BoardSize, Level], GameState),
	game_loop(GameState, 1).

% choose_move(+GameState, +Level, -Move)
% Determines the move based on the game state and player level.
% For Level 1, it gets a move from a human player.
choose_move(GameState, 1, Move) :-
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	choose_move_human(GameState, Move).

% For Level 2, it gets a move from a human player if Player is 1, otherwise from an easy bot.
choose_move(GameState, 2, Move) :-
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	Player = 1,
	choose_move_human(GameState, Move).

choose_move(GameState, 2, Move) :-
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	Player = 2,
	choose_move_easy(GameState, Move).

% For Level 3, it gets a move from a human player if Player is 1, otherwise from a hard bot.
choose_move(GameState, 3, Move) :-
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	Player = 1,
	choose_move_human(GameState, Move).
choose_move(GameState, 3, Move) :-
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	Player = 2,
	choose_move_hard(GameState, Move).

% For Level 4, it always gets a move from a hard bot.
choose_move(GameState, 4, Move) :-
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	choose_move_hard(GameState, Move).

% choose_move_human(+GameState, -Move)
% Prompts the human player to input the origin and destination coordinates for their move.
% If the origin coordinates are just outside the board, a new piece is inserted.
choose_move_human(GameState, Move) :-
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	length(Board, BoardSize),
	BoardSizePlusOne is BoardSize + 1,
	get_number(1, BoardSizePlusOne, 'Insert the origin X coordinate ((Board size + 1) to insert a new piece)',X1),
	get_number(1, BoardSizePlusOne, 'Insert the origin Y coordinate ((Board size + 1) again to insert a new piece)',Y1),
	get_number(1, BoardSize, 'Insert the destination X coordinate',X2),
	get_number(1, BoardSize, 'Insert the destination Y coordinate',Y2),
	Move = move(X1, Y1, X2, Y2).

% choose_move_easy(+GameState, -Move)
% Determines an easy move for the bot by selecting the first valid move.
choose_move_easy(GameState, Move) :-
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	valid_moves(GameState, [Move|_]).

% choose_move_hard(+GameState, -Move)
% Determines a hard move for the bot by evaluating the best move based on the current game state.
choose_move_hard(GameState, Move) :-
	valid_moves(GameState, ListOfMoves),
	get_score(GameState, ListOfMoves, ListOfMovesScore),
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	get_best_move(Player, ListOfMovesScore, Move).

% get_best_move(+Player, +ListOfMovesScore, -Move)
% Determines the best move for the player based on the move pontuations.
% For Player 1, it sorts the moves by pontuation in descending order and selects the best move.
get_best_move(1, ListOfMovesScore, Move) :-
	keysort(ListOfMovesScore, SortedMoves),
	reverse(SortedMoves, [_-Move|_]).

% For Player 2, it sorts the moves by pontuation in ascending order and selects the best move.
get_best_move(2, ListOfMovesScore, Move) :-
	keysort(ListOfMovesScore, SortedMoves),
	reverse(SortedMoves, [_-Move|_]).

% get_score(+GameState, +ListOfMoves, -ListOfPair(value-move))
% Given a list of moves, calculated the score for each move and pairs it with the move.
get_score(GameState, [], []).
get_score(GameState, [Move|Rest], [NewValue-Move|ListOfMovesScore]) :-
	move(GameState, Move, NewGameState),
	NewGameState = [NewBoard, Player, Level, Player1FreePieces, Player2FreePieces],
	value(NewGameState, Player, NewValue),
	get_score(GameState, Rest, ListOfMovesScore).

% value(+GameState, +Player, -Value)
% Calculates the value of the game state for the player.
value(GameState, 1, Value) :-
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	get_max_positive(Board, Value).

value(GameState, 2, Value) :-
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	get_min_negative(Board, MinNegative),
	Value is -MinNegative.

% game_loop(+GameState, +NoMoves)
% Main game loop that handles the game state and player turns.
game_loop(GameState, 0) :- 
	% If there are no more moves available...	
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	valid_moves([Board, 1, Level, Player1FreePieces, Player2FreePieces], ListOfMovesPlayer1),
	ListOfMovesPlayer1 = [],
	valid_moves([Board, 2, Level, Player1FreePieces, Player2FreePieces], ListOfMovesPlayer2),
	ListOfMovesPlayer2 = [],
	game_over(GameState, Winner),
	display_game(GameState),
	display_winner(Winner),
	play_again_menu,
	get_number(1, 2, 'Choose an option', Choice),
	handle_play_again_choice(Choice).

game_loop([Board, 1, Level, Player1FreePieces, Player2FreePieces], 0) :- 
	% If player 1 has no more moves, switch to player 2
	NewGameState = [Board, 2, Level, Player1FreePieces, Player2FreePieces],
	game_loop(NewGameState, 1).

game_loop([Board, 2, Level, Player1FreePieces, Player2FreePieces], 0) :- 
	% If player 2 has no more moves, switch to player 1
	NewGameState = [Board, 1, Level, Player1FreePieces, Player2FreePieces],
	game_loop(NewGameState, 1).

game_loop(GameState, NoMoves) :-
	% If there are still moves available...
	display_game(GameState),
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	% If the move is invalid, prompt the player to try again.
	choose_move(GameState, Level, Move),
    ( move(GameState, Move, NewGameState) ->
		valid_moves(NewGameState, ListOfMoves),
		length(ListOfMoves, MovesLeft), % verifies if next player still has moves
        game_loop(NewGameState, MovesLeft)
    ;   print('Invalid move. Please try again.\n'),
        game_loop(GameState, NoMoves)
    ).


% game_over(+GameState, -Winner) 
% Determines the winner of the game based on the game state, assuming the game has ended.
game_over(GameState, Winner) :-
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	get_winner(Board, Winner).

% get_winner(+Board, -Winner)
% Determines the winner of the game based on the board state.
get_winner(Board, Winner) :-
	get_all_positive(Board, PositiveValues),
	get_all_negative(Board, NegativeValues),
	samsort(PositiveValues, ReverseSortedPositive),
	reverse(ReverseSortedPositive, SortedPositive),
	samsort(NegativeValues, SortedNegative),
	compare_values(SortedPositive, SortedNegative, Winner).

% display_winner(+Winner)
% Displays the winner of the game.
display_winner(0) :-
	write_colored('The game ended in a tie!', yellow), nl.
	
display_winner(1) :-
	write_colored('Player ', yellow), write_colored('1', blue), write_colored(' wins!', yellow), nl.

display_winner(2) :-
	write_colored('Player ', yellow), write_colored('2', red), write_colored(' wins!', yellow), nl.

% compare_values(+SortedPositive, +SortedNegative, -Result)
% Compares the sorted positive and negative values one by one.
% Returns 1 if positive values are greater, -1 if negative values are greater, and 0 if they are tied.
compare_values([], [], 0).
compare_values([P|Ps], [], 1) :- P > 0.
compare_values([], [N|Ns], 2) :- N < 0.
compare_values([P|Ps], [N|Ns], 1) :-
	P > -N.
compare_values([P|Ps], [N|Ns], 2) :-
	P < -N.
compare_values([P|Ps], [N|Ns], Result) :-
	P =:= -N,
	compare_values(Ps, Ns, Result).

% get_all_positive(+Matrix, -PositiveValues)
% Gets all positive values from the matrix and places them in a list.
get_all_positive(Matrix, PositiveValues) :-
	findall(Value, (member(Row, Matrix), member(Value, Row), number(Value), Value > 0), PositiveValues).

% get_all_negative(+Matrix, -NegativeValues)
% Gets all negative values from the matrix and places them in a list.
get_all_negative(Matrix, NegativeValues) :-
	findall(Value, (member(Row, Matrix), member(Value, Row), number(Value), Value < 0), NegativeValues).

% get_max_positive(+Matrix, -MaxPositive)
% Gets the highest positive value from the matrix.
get_max_positive(Matrix, MaxPositive) :-
    get_max_positive(Matrix, -1000, MaxPositive).

get_max_positive([], Max, Max).
get_max_positive([Row|Rest], CurrentMax, Max) :-
    get_max_positive_row(Row, CurrentMax, RowMax),
    get_max_positive(Rest, RowMax, Max).

get_max_positive_row([], Max, Max).
get_max_positive_row([Value|Rest], CurrentMax, Max) :-
    number(Value), Value > 0,
    NewMax is max(Value, CurrentMax),
    get_max_positive_row(Rest, NewMax, Max).
get_max_positive_row([Value|Rest], CurrentMax, Max) :-
    (Value = blank; Value = none; number(Value), Value =< 0),
    get_max_positive_row(Rest, CurrentMax, Max).

% get_min_negative(+Matrix, -MinNegative) 
% Gets the lowest negative value from the matrix.
get_min_negative(Matrix, MinNegative) :-
    get_min_negative(Matrix, 1000, MinNegative).

get_min_negative([], Min, Min).
get_min_negative([Row|Rest], CurrentMin, Min) :-
    get_min_negative_row(Row, CurrentMin, RowMin),
    get_min_negative(Rest, RowMin, Min).

get_min_negative_row([], Min, Min).
get_min_negative_row([Value|Rest], CurrentMin, Min) :-
    number(Value), Value < 0,
    NewMin is min(Value, CurrentMin),
    get_min_negative_row(Rest, NewMin, Min).
get_min_negative_row([Value|Rest], CurrentMin, Min) :-
    (Value = blank; Value = none; number(Value), Value >= 0),
    get_min_negative_row(Rest, CurrentMin, Min).


% initial_state(+GameConfig, -GameState)
% Initializes the game state based on the game configuration.
% GameConfig = [BoardSize, Level], where level is 1 for player vs player, 2 for player vs easy bot, 3 for player vs hard bot, 4 for bot vs bot
% GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces]
initial_state(GameConfig, GameState) :-
		GameConfig = [BoardSize, Level],
		get_board(BoardSize, Board),
		GameState = [Board, 1, Level, 4, 4].

% display_game(+GameState)
% Displays the game state to the user.
display_game(GameState) :-
		GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
		print_board(Board),
		write_colored('Player 1 has ', blue), write_colored(Player1FreePieces, blue), write_colored(' free piece(s)', blue), nl,
		write_colored('Player 2 has ', red), write_colored(Player2FreePieces, red), write_colored(' free piece(s)', red), nl,
		write_colored('Player ', green), write_colored(Player, green), write_colored(' turn', green), nl.

% valid_move(+GameState, +Move)
% Checks if a move is valid based on the game state.

% If the player wishes to place a free piece:
valid_move(GameState, move(X1, Y1, X2, Y2)) :- 
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	length(Board, BoardSize),
	BoardSizePlusOne is BoardSize + 1,
	X1 == BoardSizePlusOne,
	Y1 == BoardSizePlusOne,
	Player == 1,
	Player1FreePieces > 0,
	get_piece(X2, Y2, Board, Piece),
	Piece == blank.
valid_move(GameState, move(X1, Y1, X2, Y2)) :-
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	length(Board, BoardSize),
	BoardSizePlusOne is BoardSize + 1,
	X1 == BoardSizePlusOne,
	Y1 == BoardSizePlusOne,
	Player == 2,
	Player2FreePieces > 0,
	get_piece(X2, Y2, Board, Piece),
	Piece == blank.

% If the player wishes to move a stack:
valid_move(GameState, move(X1, Y1, X2, Y2)) :-
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	adjacent(X1, Y1, X2, Y2),
	X1 \== 0,
	Y1 \== 0,
	Player == 1,
	get_piece(X1, Y1, Board, Piece),
	Piece \== blank,
	Piece \== none,
	Piece > 0,
	get_piece(X2, Y2, Board, Piece2),
	Piece2 == blank.
valid_move(GameState, move(X1, Y1, X2, Y2)) :-
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	adjacent(X1, Y1, X2, Y2),
	X1 \== 0,
	Y1 \== 0,
	Player == 2,
	get_piece(X1, Y1, Board, Piece),
	Piece \== blank,	
	Piece \== none,
	Piece < 0,
	get_piece(X2, Y2, Board, Piece2),
	Piece2 == blank.

% move(+GameState, +Move, -NewGameState)
% Executes a move and returns the new game state.
% Move = (X1, Y1, X2, Y2)
move(GameState, move(X1, Y1, X2, Y2), NewGameState) :-
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	length(Board, BoardSize),
	BoardSizePlusOne is BoardSize + 1,
	X1 == BoardSizePlusOne,
	Y1 == BoardSizePlusOne,
	Move = move(X1, Y1, X2, Y2),
	valid_move(GameState, Move),
	Player == 1,
	set_piece(X2, Y2, 2, Board, NewBoard),
	NewPlayer1FreePieces is Player1FreePieces - 1,
	NewGameState = [NewBoard, 2, Level, NewPlayer1FreePieces, Player2FreePieces].
move(GameState, move(X1, Y1, X2, Y2), NewGameState) :-
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	length(Board, BoardSize),
	BoardSizePlusOne is BoardSize + 1,
	X1 == BoardSizePlusOne,
	Y1 == BoardSizePlusOne,
	Move = move(X1, Y1, X2, Y2),
	valid_move(GameState, Move),
	Player == 2,
	set_piece(X2, Y2, -2, Board, NewBoard),
	NewPlayer2FreePieces is Player2FreePieces - 1,
	NewGameState = [NewBoard, 1, Level, Player1FreePieces, NewPlayer2FreePieces].

move(GameState, move(X1, Y1, X2, Y2), NewGameState) :-
	Move = move(X1, Y1, X2, Y2),
	valid_move(GameState, Move),
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	Player == 1,
	get_piece(X1, Y1, Board, Piece),
	NewPiece is Piece + 1,
	set_piece(X1, Y1, none, Board, NewBoard),
	set_piece(X2, Y2, NewPiece, NewBoard, NewBoard2),
	NewGameState = [NewBoard2, 2, Level, Player1FreePieces, Player2FreePieces].
move(GameState, move(X1, Y1, X2, Y2), NewGameState) :-
	Move = move(X1, Y1, X2, Y2),
	valid_move(GameState, Move),
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	Player == 2,
	get_piece(X1, Y1, Board, Piece),
	NewPiece is Piece - 1,
	set_piece(X1, Y1, none, Board, NewBoard),
	set_piece(X2, Y2, NewPiece, NewBoard, NewBoard2),
	NewGameState = [NewBoard2, 1, Level, Player1FreePieces, Player2FreePieces].

% valid_moves(+GameState, -ListOfMoves) 
% Returns a list of all valid moves for the current player.
valid_moves(GameState, ListOfMoves) :-
	GameState = [Board, Player, Level, Player1FreePieces, Player2FreePieces],
	length(Board, BoardSize),
	BoardSizePlusOne is BoardSize + 1,
	findall(move(BoardSizePlusOne,BoardSizePlusOne,X2,Y2), (
	between(1, BoardSize, X2), 
	between(1, BoardSize, Y2),
	valid_move(GameState, move(BoardSizePlusOne,BoardSizePlusOne,X2,Y2))
	), ListOfMoves1),

	findall(move(X1,Y1,X2,Y2), (
	between(1, BoardSize, X1), 
	between(1, BoardSize, Y1),
	between(1, BoardSize, X2), 
	between(1, BoardSize, Y2),
	valid_move(GameState, move(X1,Y1,X2,Y2))
	), ListOfMoves2),

	append(ListOfMoves1, ListOfMoves2, ListOfMoves).

% adjacent(+X1, +Y1, +X2, +Y2) 
% Checks if two coordinates are adjacent.
adjacent(X1, Y1, X2, Y2) :-
	(X1 + 1 =:= X2, Y1 =:= Y2).
adjacent(X1, Y1, X2, Y2) :-
  (X1 - 1 =:= X2, Y1 =:= Y2).
adjacent(X1, Y1, X2, Y2) :-
  (X1 =:= X2, Y1 + 1 =:= Y2).
adjacent(X1, Y1, X2, Y2) :-
  (X1 =:= X2, Y1 - 1 =:= Y2).

% play again
play_again_menu :-
		nl,
		write_colored('=============================', cyan), nl,
		write_colored('       PLAY AGAIN MENU       ', cyan), nl,
		write_colored('=============================', cyan), nl,
		write_colored('1. Yes', green), nl,
		write_colored('2. No', red), nl,
		nl.

% handle_play_again_choice(+Choice)
% Handles the play again choice and either starts a new game or terminates the program.
handle_play_again_choice(1) :-
	play.
handle_play_again_choice(2) :-
	nl,
	write_colored('Exiting...', red),
	halt(0).

