is_digit(N) :- member(N,[0,1,2,3,4,5,6,7,8,9]).
is_lower(C) :- member(C,['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']).
is_upper(C) :- member(C,['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']).
is_alphabet(C) :- is_lower(C);is_upper(C).

%% Successor and Predecessor of a number
succ(1,0) :- !.
succ(N,N1) :- integer(N), integer(N1), !, N is N1+1.
succ(N,N1) :- var(N), integer(N1), !, N is N1+1.
succ(N,N1) :- integer(N), var(N1), !, N1 is N-1.

pred(0,1) :- !.
pred(N,N1) :- integer(N), integer(N1), !, N is N1-1.
pred(N,N1) :- var(N), integer(N1), !, N is N1-1.
pred(N,N1) :- integer(N), var(N1), !, N1 is N+1.

%% Calculating the number of members in a list
lengthof([],0) :- !.
lengthof([_|T],N) :- var(N), lengthof(T,N1), N is N1+1, !.
lengthof([_|T],N) :- N1 is N-1, lengthof(T,N1), !.

next_in_list(_,[],_) :- fail.
next_in_list(_,[_],_) :- fail.
next_in_list(X,[X,Y|_],Y).
next_in_list(X,[_|Rest],Y) :- next_in_list(X,Rest,Y).

next_alphabet(X,Y) :- findall(A,is_lower(A),L),next_in_list(X,L,Y);findall(B,is_upper(B),U),next_in_list(X,U,Y).

%% Remove an element of a List to get a new List
%% Remove and Insert are basically equivalent predicates
remove(_,[],[]) :- fail.
remove(X,[X|Rest],Rest).
remove(X,[Y|Rest],[Y|LRest]) :- remove(X,Rest,LRest).

%% Permutation of a list is a new List with the same elements in a different arrangement
permutation(L1,L2) :- ((var(L1),\+ var(L2)) -> permutation0(L2,L1)).
permutation(L1,L2) :- ((\+ var(L1), var(L2)) -> permutation0(L1,L2)).
permutation(L1,L2) :- lengthof(L1,N1),lengthof(L2,N2),N1=:=N2,permutation0(L1,L2).

permutation0([H|T],L2) :- permutation0(T,L3),remove(H,L2,L3).
permutation0([],[]).

%% Index of first occurance of X in a List
index_of(X,[X|_],0).
index_of(X,[_|Rest],I) :- index_of(X,Rest,I1), I is I1+1.

%% sorting algorithms w.r.t a Comparator
ordered([_],_).
ordered([X,Y|Rest],Comparator) :- Fcompare =.. [Comparator,X,Y],call(Fcompare),ordered([Y|Rest],Comparator).
%% Most inefficient sorting algorithm: O(n.n!).
sort(L1,L2,Comparator) :- permutation(L1,L2),ordered(L2,Comparator).

%% Insetion sort algorithm: O(n^2).
insert(X,[],[X],_).
%% Either of the following two inserts are at a time true
insert(X,[Y|Rest],[X,Y|Rest],Comparator) :- Fcompare =.. [Comparator,X,Y],call(Fcompare),!.
insert(X,[Y|Rest],[Y|Rest2],Comparator) :- insert(X,Rest,Rest2,Comparator).
isort([X],[X],_).
isort([X|Rest],L2,Comparator) :- isort(Rest,L3,Comparator),insert(X,L3,L2,Comparator).

%% Merge sort, one of the most efficient sorting algorithms: O(nlogn)?? or O(n^2logn)??
%% Since lists are used but not arrays copy_list has complexity O(n^2).
copy_list(L1,Start,End,L2) :- (nonvar(L1),lengthof(L1,N1),Start>=0,End=<N1) -> copy_list0(L1,Start,End,L2).

/** This is most inefficient to use index_of and recurssion to implement copy_list0
copy_list0(L1,Start,End,L2) :- Start<End,index_of(X,L1,Start),L2=[X|Rest],Start1 is Start+1,copy_list0(L1,Start1,End,Rest),!.
copy_list0(_,Start,End,L2) :- Start>=End,L2=[].
**/
%% Lets implement copy_list0 in a smarter way using append
copy_list0(L1,Start,End,L2) :- Start=<End,lengthof(L1,N1),lengthof(Ls,Start),N2 is N1-End,lengthof(Le,N2),
                               append(Ls,L2,Lp),append(Lp,Le,L1).

%% Lets implement split_at in a smarter way using append directly
%% split_at(L,L1,L2,At) :- lengthof(L,N),At<N,copy_list(L,0,At,L1),copy_list(L,At,N,L2).
split_at(L,L1,L2,At) :- lengthof(L,N),At<N,N1 is N-At,lengthof(L1,At),lengthof(L2,N1),append(L1,L2,L).

msort([X],[X],_) :- !.
msort(L,Ls,Comparator) :- nonvar(L) -> lengthof(L,N),//(N,2,At),split_at(L,L1,L2,At),
                                       msort(L1,Ls1,Comparator),msort(L2,Ls2,Comparator),
                                       merge(Ls1,Ls2,Ls,Comparator).

merge(L,[],L,_).
merge([X],[Y],[X,Y],Comparator) :- Fcompare =.. [Comparator,X,Y],call(Fcompare),!.
merge([X],[Y],[Y,X],Comparator) :- Fcompare =.. [Comparator,Y,X],call(Fcompare),!.
merge(L1,L2,Lm,Comparator) :- lengthof(L1,N1),I is N1-1,index_of(X,L1,I),index_of(Y,L2,0),
                              Fcompare =.. [Comparator,X,Y],call(Fcompare),append(L1,L2,Lm),!.
merge(L1,L2,Lm,Comparator) :- lengthof(L2,N2),I is N2-1,index_of(X,L2,I),index_of(Y,L1,0),
                              Fcompare =.. [Comparator,X,Y],call(Fcompare),append(L2,L1,Lm),!.
merge(L1,[X|Rest2],Lm,Comparator) :- insert(X,L1,NL1,Comparator),merge(NL1,Rest2,Lm,Comparator).
%% A cleaner implementation of Merge Sort can be found below
%% https://ycpcs.github.io/cs340-fall2014/lectures/lecture13.html

%% Quick Sort algorithm is taken from the following book
%% The Art of Prolog (Pg. No. 70): https://mitpress.mit.edu/9780262691635/the-art-of-prolog/
qsort([],[],_).
qsort([X|Rest],Ls,Comparator) :- partition(Rest,X,Littles,Bigs,Comparator),!,
                                 qsort(Littles,Lis,Comparator),qsort(Bigs,Bis,Comparator),
                                 append(Lis,[X|Bis],Ls).

partition([],_,[],[],_).
partition([X|Rest],Y,[X|Lis],Bis,Comparator) :- Fcompare =.. [Comparator,X,Y],call(Fcompare),
                                                partition(Rest,Y,Lis,Bis,Comparator).
partition([X|Rest],Y,Lis,[X|Bis],Comparator) :- Fcompare =.. [Comparator,Y,X],call(Fcompare),
                                                partition(Rest,Y,Lis,Bis,Comparator).
