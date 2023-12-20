# Solving a simple code challenge with prolog using chat-gpt-3.5 as your assistant

Will chat-gpt-3.5 be able to assist in solving a simple coding challenge using the more rare programing language prolog?

Prolog is a language that I don't master my self. I only have a basic understanding of that language but can I use that basic understanding and work together with chat-gpt-3 and together solve a simple programming challenge.

I selected the [first task](https://adventofcode.com/2023/day/1) in advent of code for 2023 as the problem to solve. The problem consisted of two parts: (1) parsing a file of data and (2) solving the actual problem.
 
Chat-gpt managed fine with the first part: parsing a file with data to process.

The file consists of rows of strings, where every row needs processed in order to find the magic number. Advent of code gives this simple file to start with:

``` text
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
```

Chat-gpt almost manage to provide me with code that did process the file and create the two dimensional array needed to solve the actual challenge. I only had to do a small fix for the code to work. The resulting code after the adjustment looks like this:

``` prolog
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

```

Running the code in prolog could look like (given that the file to parse is named in2.txt)

``` cmd
?- read_file_to_list('in2.txt',L).
L = [[1, a, b, c, 2], [p, q, r, 3, s, t, u|...], [a, 1, b, 2, c, 3|...], [t, r, e, b, 7|...]] ;
```

Solving the actual problem turned out to be much harder for chat-gpt-3.5.

 * For each line the first and last number should be concatinated.
 * If there is only one number i a row, that that number should be concatinated with it self.
 * All the identified numbers should then be added and the answer to the challenge is the sum of all the numbers.

I tried to solve it my self with the limited knowledge of prolog that I possess. The following code does solve the challenge:

``` prolog
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

```

I wrote a state machine that solved the problem. There is a pattern that caught each state that exists and logic for how the goal state should look like. 

Running that code looks like:

``` cmd

?- read_file_to_list('in2.txt',L),calc(L,S).
L = [[1, a, b, c, 2], [p, q, r, 3, s, t, u|...], [a, 1, b, 2, c, 3|...], [t, r, e, b, 7|...]],
S = 142 ;


```

The sum for that file is 142.

Here is the conversation where I tried to let chat-gpt-3.5 solve the entire challenge:

> [me] - Hi. In prolog could you help me with a programming problem. The input is a two dimensional list representing rows with characters. As an example the list could look like [[a,2,g,e,4],[f,g,e,7,g,h]]. That list would then represent two rows with the following two strings a2ge4 and fge7gh.

> [ChatGPT-3.5] - Absolutely, I'd love to help! What specifically would you like to achieve with this two-dimensional list in Prolog? Are you looking to perform any particular operations or transformations on this data structure?

> [me] - For each row the first and last number should be concatenated, unless there are only one number in the row, then that single number should be concatenated with it self. Then all parsed number should be added to a sum. It's the sum that should be calculated.

> [ChatGPT-3.5] - Certainly! To achieve this in Prolog, you can write a predicate that processes each row, extracts the first and last numbers or single number in case there's only one, concatenates them, and then calculates the sum of these concatenated numbers across all rows.

> [ChatGPT-3.5] - Here's an example implementation:

```prolog
% Predicate to concatenate the first and last numbers or single number in a list
concatenateNumbers([], 0).
concatenateNumbers([X], Sum) :-
    number(X),
    Sum is X * 2.
concatenateNumbers([First|Rest], Sum) :-
    number(First),
    append(Middle, [Last], Rest),
    number(Last),
    atom_concat(First, Last, Concatenated),
    concatenateNumbers([Concatenated|Middle], NewSum),
    Sum is First + Last + NewSum.
concatenateNumbers([_|Rest], Sum) :-
    concatenateNumbers(Rest, Sum).

% Predicate to calculate the sum of concatenated numbers in a 2D list
calculateSum([], 0).
calculateSum([Row|Rest], TotalSum) :-
    concatenateNumbers(Row, RowSum),
    calculateSum(Rest, RestSum),
    TotalSum is RowSum + RestSum.
```

> [ChatGPT-3.5] - You can use the calculateSum/2 predicate by passing your 2D list as an argument to find the sum of the concatenated numbers. For example:

```promt
?- List = [[a,2,g,e,4],[f,g,e,7,g,h]],
   calculateSum(List, Sum).
```

> [ChatGPT-3.5] - This code should return the sum of the concatenated numbers according to the rules you specified for the given 2D list.

> [me] - Sorry, it gives the wrong answer. [a,2,g,e,4] should concatenate 2 and 4 to 24 and f,g,e,7,g,h should concatenate the number 7 with it self so that it results in the number 77. The sum should then be 101.

> [ChatGPT-3.5] - Ah, I see, my mistake! Let me adjust the Prolog code to correctly concatenate the numbers as specified:

```prolog
% Predicate to concatenate the first and last numbers or single number in a list
concatenateNumbers([], 0).
concatenateNumbers([X], X) :-
    number(X).
concatenateNumbers([First,Last], Concatenated) :-
    number(First),
    number(Last),
    atom_concat(First, Last, Concatenated).
concatenateNumbers([First|Rest], Sum) :-
    number(First),
    append(_, [Last], Rest),
    number(Last),
    atom_concat(First, Last, Concatenated),
    concatenateNumbers([Concatenated|Rest], Sum).
concatenateNumbers([_|Rest], Sum) :-
    concatenateNumbers(Rest, Sum).

% Predicate to calculate the sum of concatenated numbers in a 2D list
calculateSum([], 0).
calculateSum([Row|Rest], TotalSum) :-
    concatenateNumbers(Row, RowSum),
    calculateSum(Rest, RestSum),
    TotalSum is RowSum + RestSum.
```

> [ChatGPT-3.5] - Now you can use the calculateSum/2 predicate again with your list:

```promt
?- List = [[a,2,g,e,4],[f,g,e,7,g,h]],
   calculateSum(List, Sum).
```

> [ChatGPT-3.5] - This updated code should correctly compute the sum of concatenated numbers according to your specifications.

> [me] - I think that calculateSum could be part of a working solution but concatenateNumbers will not produce the correct numbers. Thanks for the help.

> [ChatGPT-3.5] - I see, let's refine the concatenateNumbers/2 predicate to ensure it correctly concatenates the first and last numbers or the single number in the manner you described. Here's an updated version:

```prolog
% Predicate to concatenate the first and last numbers or single number in a list
concatenateNumbers([], 0).
concatenateNumbers([X], X) :-
    number(X).
concatenateNumbers([First|Rest], Concatenated) :-
    number(First),
    append(Middle, [Last], Rest),
    number(Last),
    atom_concat(First, Last, Concatenated),
    concatenateNumbers([Concatenated|Middle], Concatenated).
concatenateNumbers([First|Rest], Sum) :-
    number(First),
    concatenateNumbers(Rest, Sum).
concatenateNumbers([_|Rest], Sum) :-
    concatenateNumbers(Rest, Sum).

% Predicate to calculate the sum of concatenated numbers in a 2D list
calculateSum([], 0).
calculateSum([Row|Rest], TotalSum) :-
    concatenateNumbers(Row, RowSum),
    calculateSum(Rest, RestSum),
    TotalSum is RowSum + RestSum.
```

> [ChatGPT-3.5] - This code should now correctly concatenate the numbers as described in your specification and calculate the sum of these concatenated numbers for each row in the 2D list when using the calculateSum/2 predicate. Feel free to test it with your example list or any other input!

> [me] - Thanks for this time.

> [ChatGPT-3.5] - You're welcome! If you have any more questions or need further assistance in the future, feel free to ask. Happy coding, and have a great day!


The assistance provided by chat-gpt-3.5 was really helpful. It managed the first part when ask to parse the indata file in a specific way but it did not manage to solve the actual programming problem. A more advanced GPT would probably solve the code challenge as well. But the level that chat-gpt-3.5 provides are greatly useful for guidance when solving a problem. You can break the challenge in smaller parts and let GPT help you with each part.
