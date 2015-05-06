faussesMarchandises([[ma�s, riz, ble, ble],
[ble, ma�s, sucre, riz],
[cafe, sucre, cacao, riz],
[sucre, ma�s],
[cacao, ma�s, ble, sucre],
[],
[cafe, ble, sucre, cacao],
[ma�s, cacao,ble],
[riz,riz,cafe,cacao]]).

fausseBourse([[ble,7],[riz,6],[cacao,6],[cafe,6],[sucre,6],[mais,6]]).

afficheMarchandise([]).
afficheMarchandise([[]|Q]):-!, afficheMarchandise(Q),nl.
afficheMarchandise([[T|L]|Q]):-write(T), write('\t'),afficheMarchandise(Q). 

afficheQuantite([]).
afficheQuantite([[]|Q]):-!, afficheQuantite(Q),nl.
afficheQuantite([T|Q]):-length(T,N), write(N), write('\t'),afficheQuantite(Q). 

afficheTrader(1):-write('x'),!.
afficheTrader(N):-write('\t'),M is N-1, afficheTrader(M).

afficheBourse([]).
afficheBourse([[T|L]|Q]):-write(T),write(':\t'),write(L),nl,afficheBourse(Q).