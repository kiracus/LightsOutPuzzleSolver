% lights out puzzle solver in prolog
% print solutions one by one if given puzzle in form of lights_out(<size>, X).

lights_out(N, Flip_row_1) :-
  build(noflip, N, Flip_row_0),         % row 0 flips: all noflip
  generate_flip_row_1(N, Flip_row_1),   % generate one possible case of row 0 flips
  generate_recur(N,                     % total row numbers
                 1,                     % start from row 1
                 Flip_row_0,
                 Flip_row_1,
                 LastRowColor),         % determine color of the last row
  validate(LastRowColor).               % test color of the last row.


% generate_recur/5, generates the colors of the last row
generate_recur(N, N, PrevFlip, CurrFlip, LastRowColor) :-
  generate_colors(N, PrevFlip, CurrFlip, 0, [], LastRowColor).

generate_recur(N, Index, PrevFlip, CurrFlip, LastRowColor) :-
  Index < N,
  generate_colors(N, PrevFlip, CurrFlip, 0, [], CurrColorAfterFlip),
  generate_flips(CurrColorAfterFlip, NextFlip),
  NewIndex is Index + 1,
  generate_recur(N, NewIndex, CurrFlip, NextFlip, LastRowColor).


% validate/1, verify the list only contains 'red'
validate([]).
validate([red | T]) :- validate(T).


% ----- Helper functions -----
% build_list/3, build a List of same Items repeating N times
build(Item, N, List) :-
  length(List, N),
  maplist(=(Item), List).


% generate_flip_row_1/2, generate all possible flipping combinations of row 1
generate_flip_row_1(0, []).
generate_flip_row_1(N, [flip | T]) :-
  New_len is N-1,
  New_len >= 0,
  generate_flip_row_1(New_len, T).

generate_flip_row_1(N, [noflip | T]) :-
  New_len is N-1,
  New_len >= 0,
  generate_flip_row_1(New_len, T).


% For recursion:
% Step 1. generate_colors/6, generate color of row X
% based on flips of the previous row and the current row,
% if neighbor and itself flipped odd times in total red, else blue

% different cases
% at index 0
% H _ _ _
% X Y _ _
generate_colors(N, [H | Tail], [X, Y | Tail2], 0, [], Colors) :-
  count_flip([H, X, Y], FlipTime),
  color(FlipTime, CurrColor),
  generate_colors(N, Tail, [X, Y | Tail2], 1, [CurrColor], Colors).

% at any middle index
% _ _ H _ _  and next call will be _ _ _ T _
% _ X Y Z _                        _ _ Y Z _
generate_colors(N, [H | Tail], [X, Y, Z| Tail2], Index, Acc, Colors) :-
  Index \= N - 1,  % not the last tile of this row
  count_flip([H, X, Y, Z], FlipTime),
  color(FlipTime, CurrColor),
  NewIdx is Index + 1,
  append(Acc, [CurrColor], NewAcc),
  generate_colors(N, Tail, [Y, Z | Tail2], NewIdx, NewAcc, Colors).

% at index N-1, end of a row, so result is set
% _ _ _ H
% _ _ X Y
generate_colors(N, [H | []], [X, Y | []], Index, Acc, Res) :-
  Index is N - 1,
  count_flip([H, X, Y], FlipTime),
  color(FlipTime, Color),
  append(Acc, [Color], Res).  % append the color of the last tile to Acc

% at the only index (N = 1), only append one color
generate_colors(1, [H], [X], 0, Acc, Res) :-
  count_flip([H, X], FlipTime),
  color(FlipTime, Color),
  append(Acc, [Color], Res).


% count_flip/2, count how many times of 'flip' in a list
count_flip(List, Count) :-
  count_flip(List, 0, Count).

count_flip([], Res, Res).

count_flip([flip | Tail], Acc, Res) :-
  NewAcc is Acc + 1,
  count_flip(Tail, NewAcc, Res).

count_flip([noflip | Tail], Acc, Res) :-
  count_flip(Tail, Acc, Res).


% color/2, determine color based on times of flips
even(N):- mod(N,2) =:= 0.
color(Times, blue) :- even(Times).
color(Times, red) :- \+ even(Times).


% Step 2: generate_flips/2
% generate flips of a row depending on color of the previous row
generate_flips([], []).
generate_flips([blue | T1], [flip | T2]) :- generate_flips(T1, T2).
generate_flips([red | T1], [noflip | T2]) :- generate_flips(T1, T2).


% ----- Test -----
test :-
  lights_out(1, [flip]),
  lights_out(3, [flip, noflip, flip]),
  \+ lights_out(3, [noflip, flip, noflip]),
  lights_out(4, [noflip, flip, flip, noflip]),
  lights_out(4, [flip, noflip, noflip, flip]).

test1 :-
  lights_out(1, [flip]).

test2 :-
  lights_out(2, [flip, flip]).

test3 :-
  lights_out(3, [flip, noflip, flip]),
  \+ lights_out(3, [noflip, flip, noflip]).
