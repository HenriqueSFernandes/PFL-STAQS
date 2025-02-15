:- consult('utils.pl').

premade_game :-
	clear_screen,
	premade_game_menu,
	get_number(1, 4, 'Choose a game state', Choice),
	handle_premade_game_choice(Choice).

premade_game_menu :-
    nl,
    write_colored('=============================', cyan), nl,
    write_colored('         Puzzle Menu         ', cyan), nl, 
    write_colored('=============================', cyan), nl,
    write_colored('1. Block opponent\'s stack  ', green), nl, 
    write_colored('2. Block all opponent\'s moves', green), nl, 
    write_colored('3. Tricky endgame', green), nl, 
    write_colored('4. Exit', red), nl, 
    nl.


handle_premade_game_choice(1) :-
	write('There is a move you can do that will block the opponent from winning. Can you find it?'), nl,
	GameState = [[[none,none,none,none,blank],
								[none,none,none,none,none],
								[-7,none,none,3,none],
                [blank,6,blank,-2,blank],
                [blank,none,2,blank,2]],
							1, 3, 0, 2],
	game_loop(GameState, 1),
	premade_game.

handle_premade_game_choice(2) :-
	write('There is a play you can do that will prevent your opponent from playing. Can you find it?'), nl,
	GameState = [[[-5,2,blank,blank,blank],
								[2,blank,blank,blank,blank],
                [blank,blank,blank,blank,none],
                [blank,none,4,blank,none],
                [-2,none,-2,blank,-4]], 
							1, 3, 1, 0],
	game_loop(GameState, 2),
	premade_game.

handle_premade_game_choice(3) :-
	write('Can you win this endgame?'), nl,
  GameState = [[[none,none,none,-5,blank],
								[none,none,none,blank,blank],
								[-2,5,blank,-4,none],
								[none,none,4,blank,none],
								[none,none,blank,blank,none]],
							1, 3, 2, 1],
	game_loop(GameState, 3),
	premade_game.

handle_premage_game_choice(4) :-
	nl,
	write_colored('Exiting...', red), nl,
	halt(0).


