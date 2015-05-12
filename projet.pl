afficheMarchandise([]).
afficheMarchandise([[]|Q]):-!, afficheMarchandise(Q).
afficheMarchandise([[T|L]|Q]):-write(T), write('\t'),afficheMarchandise(Q). 

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

affichePlateau(M,B,T,J1,J2):-write('Bourse:'),nl,afficheBourse(B),nl,write('Plateau:'),nl, afficheMarchandise(M),nl,
	afficheQuantite(M),nl,afficheTrader(T),nl,nl,afficheJ1(J1),nl,afficheJ2(J2).




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
	initPile(March9,P9,March10).


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

plateauDepart(M,B,T,J1,J2):-init(I),initMarchandise(I,M),initTraider(T),initJ1(J1),initJ2(J2),initBourse(B).
