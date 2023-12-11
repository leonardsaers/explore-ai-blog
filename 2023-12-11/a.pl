% Parsing the file
read_file_to_list(File, ListOfLists) :-
    open(File, read, Stream),
    read_lines(Stream, ListOfLists),
    close(Stream).

read_lines(Stream, []) :-
    at_end_of_stream(Stream).

read_lines(Stream, [Line_with_numbers|Rest]) :-
    \+ at_end_of_stream(Stream),
    read_line_to_codes(Stream, LineCodes),
    atom_codes(AtomLine, LineCodes),
    atom_chars(AtomLine, Line),
    maplist(atom_number_or_keep, Line, Line_with_numbers),
    read_lines(Stream, Rest).

atom_number_or_keep(Atom, Number) :-
    atom_number(Atom, Number), !.

atom_number_or_keep(Atom, Atom).

% Solving the problem
calc([],0).

calc([H|T],S):-
    calc_row(H,N),
    calc(T,S2),
    S is S2+N.    

calc_row(L,N) :-
    calc_row(L,undefined,undefined,N).

calc_row([],First,Last,N):-
    atom_concat(First, Last, S),
    atom_number(S,N).

calc_row([],First,undefined,N):-
    atom_concat(First, First, S),
    atom_number(S,N).

calc_row([H|T],undefined,undefined,N):-
    not(number(H)),
    calc_row(T,undefined,undefined,N).

calc_row([H|T],undefined,undefined,N):-
    number(H),
    calc_row(T,H,undefined,N).

calc_row([H|T],F,_,N):-
    number(H),
    calc_row(T,F,H,N).

calc_row([H|T],F,State,N):-
    not(number(H)),
    calc_row(T,F,State,N).
