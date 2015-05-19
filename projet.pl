afficheMarchandise([]).
afficheMarchandise([[]|Q]):-!, afficheMarchandise(Q).
afficheMarchandise([[T|_]|Q]):-write(T), write('\t'),afficheMarchandise(Q). 

afficheQuantite([]).
afficheQuantite([[]|Q]):-!, afficheQuantite(Q).
afficheQuantite([T|Q]):-length(T,N), write(N), write('\t'),afficheQuantite(Q). 

afficheTrader(1):-write('x'),!.
afficheTrader(N):-write('\t'),M is N-1, afficheTrader(M).

afficheBourse([]).
afficheBourse([[T|L]|Q]):-write(T),write(':\t'),write(L),nl,afficheBourse(Q).

afficheListe([]):-write('rien.').
afficheListe([T|[]]):-write(T), write('.').
afficheListe([T|Q]):-write(T), write(', '), afficheListe(Q).

afficheJ1(L):-write('La reserve du joueur 1 contient: '), afficheListe(L).
afficheJ2(L):-write('La reserve du joueur 2 contient: '), afficheListe(L).

affichePlateau([M,B,T,J1,J2]):-write('Bourse:'),nl,afficheBourse(B),nl,write('Plateau:'),nl, afficheMarchandise(M),nl,
	afficheQuantite(M),nl,afficheTrader(T),nl,nl,afficheJ1(J1),nl,afficheJ2(J2),nl.




init([ble,ble,ble,ble,ble,ble,mais,mais,mais,mais,mais,mais,riz,riz,riz,riz,riz,riz,cacao,cacao,cacao,cacao,cacao,cacao,cafe,cafe,cafe,cafe,cafe,cafe,sucre,sucre,sucre,sucre,sucre,sucre]).

initMarchandise(March,[P1,P2,P3,P4,P5,P6,P7,P8,P9]):-
	initPile(March,P1,March2),
	initPile(March2,P2,March3),
	initPile(March3,P3,March4),
	initPile(March4,P4,March5),
	initPile(March5,P5,March6),
	initPile(March6,P6,March7),
	initPile(March7,P7,March8),
	initPile(March8,P8,March9),
	initPile(March9,P9,_).

initPile(March,[J1,J2,J3,J4], NMarch):-
	initJeton(March,J1,March2),
	initJeton(March2,J2,March3),
	initJeton(March3,J3,March4),
	initJeton(March4,J4,NMarch).

initJeton(March,J,NMarch):-
length(March,N),M is N+1, random(1,M,Rand),nth(Rand,March,J),remove(March,J,NMarch).

initBourse([[ble,7],[riz,6],[cacao,6],[cafe,6],[sucre,6],[mais,6]]).

initJ1([]).
initJ2([]).
initTraider(1).

remove([E|Q],E,Q):-!.
remove([T|Q],E,[T|R]):-remove(Q,E,R).
remove2(L,E,L2):-remove(L,E,L1),remove(L1,E,L2),!.
remove2(L,E,L2):-remove(L,E,L2),!.
remove2(L,_,L).
exchange([E|Q],E,E1,[E1|Q]):-!.
exchange([T|Q],E,E1,[T|R]):-exchange(Q,E,E1,R).

plateauDepart([M,B,T,J1,J2]):-init(I),initMarchandise(I,M),initTraider(T),initJ1(J1),initJ2(J2),initBourse(B).







precedent(March,Ncoup,Traider,P):-length(March,M), P1 is Traider+Ncoup-1, P2 is P1 mod M, nth(P2,March,[P|_]).
suivant(March,Ncoup,Traider,S):-length(March,M), P1 is Traider+Ncoup+1, P2 is P1 mod M, nth(P2,March,[S|_]).
verif([X,Y],[X,Y]).
verif([X,Y],[Y,X]).
coupPossible([M,_,T,_,_],[_,Ncoup,A1,A2]):-member(Ncoup,[1,2,3]),precedent(M,Ncoup,T,P),suivant(M,Ncoup,T,S),verif([A1,A2],[P,S]),!.


changeBourse([[A,N]|Q],A,[[A,M]|Q]):-M is N-1,!.
changeBourse([T|Q],A,[T|R]):-changeBourse(Q,A,R).
changeJoueur(J,A,NJ):-append(J,[A],NJ).
changeTrader(T,N,NT):-NT is T+N.
supprimeMarch([[_|R]|Q],1,[R|Q]):-!.
supprimeMarch([T|Q],N,[T|R]):-M is N-1, supprimeMarch(Q,M,R).
changeMarchP(March,Ncoup,Traider,M2):-length(March,Long), P1 is Traider+Ncoup-1, P2 is P1 mod Long, supprimeMarch(March,P2,M2).
changeMarchS(March,Ncoup,Traider,M2):-length(March,Long), P1 is Traider+Ncoup+1, P2 is P1 mod Long, supprimeMarch(March,P2,M2).
changeMarch(March,Ncoup,Trader,M2):-changeMarchP(March,Ncoup,Trader,Mbis),changeMarchS(Mbis,Ncoup,Trader,Mter),remove2(Mter,[],M2).
jouerCoup([M,B,T,J1,J2],[j1,Ncoup,A1,A2],[NM,NB,NT,NJ1,J2]):-changeBourse(B,A2,NB),changeJoueur(J1,A1,NJ1),changeTrader(T,Ncoup,NT),changeMarch(M,Ncoup,T,NM),!.
jouerCoup([M,B,T,J1,J2],[j2,Ncoup,A1,A2],[NM,NB,NT,J1,NJ2]):-changeBourse(B,A2,NB),changeJoueur(J2,A1,NJ2),changeTrader(T,Ncoup,NT),changeMarch(M,Ncoup,T,NM),!.









fauxCoup([j2,2,sucre,riz]).
fauxPlateau([[[maïs, riz, ble, ble],
[riz, maïs, sucre, riz],
[mais, sucre, cacao, riz],
[sucre, maïs, sucre, maïs],
[cacao, maïs, ble, sucre],
[riz, cafe, sucre, ble],
[cafe, ble, sucre, cacao],
[maïs, cacao, cacao],
[riz,riz,cafe,cacao]],
[[ble,7],[riz,6],[cacao,6],[cafe,6],[sucre,6],[mais,6]],
1,[],[]]).
fausseBourse([[ble,7],[riz,6],[cacao,6],[cafe,6],[sucre,6],[mais,6]]).
fausseMarchandise([[maïs, riz, ble, ble],
[riz, maïs, sucre, riz],
[mais],
[sucre, maïs, sucre, maïs],
[cacao],
[riz, cafe, sucre, ble],
[cafe, ble, sucre, cacao],
[maïs, cacao, cacao],
[riz,riz,cafe,cacao]]).