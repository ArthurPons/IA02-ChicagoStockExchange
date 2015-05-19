/*******************
AFFICHAGE DU PLATEAU
********************/

% On d�coupe l'affichage en diff�rentes parties puis on construit un unique pr�dicat pour afficher le tout

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

affichePlateau([Marchandise,Bourse,Trader,Joueur1,Joueur2]):-write('Bourse:'),nl,afficheBourse(Bourse),nl,write('Plateau:'),nl, afficheMarchandise(Marchandise),nl,
	afficheQuantite(Marchandise),nl,afficheTrader(Trader),nl,nl,afficheJ1(Joueur1),nl,afficheJ2(Joueur2),nl.


/********************
GENERATION DU PLATEAU
*********************/

% On liste l'ensemble des ressources � notre disposition et on ira piocher dedans al�atoirement

init([ble,ble,ble,ble,ble,ble,mais,mais,mais,mais,
	  mais,mais,riz,riz,riz,riz,riz,riz,cacao,cacao,
	  cacao,cacao,cacao,cacao,cafe,cafe,cafe,cafe,
	  cafe,cafe,sucre,sucre,sucre,sucre,sucre,sucre]).

% Initialiser les Marchandises revient � initialiaser les piles qui revient � initialiser les jetons

% 9 piles � initialiser 

initMarchandise(Marchandise,[Pile1,Pile2,Pile3,Pile4,Pile5,Pile6,Pile7,Pile8,Pile9]):-
	initPile(Marchandise,Pile1,Marchandise2),
	initPile(Marchandise2,Pile2,Marchandise3),
	initPile(Marchandise3,Pile3,Marchandise4),
	initPile(Marchandise4,Pile4,Marchandise5),
	initPile(Marchandise5,Pile5,Marchandise6),
	initPile(Marchandise6,Pile6,Marchandise7),
	initPile(Marchandise7,Pile7,Marchandise8),
	initPile(Marchandise8,Pile8,Marchandise9),
	initPile(Marchandise9,Pile9,_).

% 4 jetons par pile � initialiser

initPile(Marchandise,[Jeton1,Jeton2,Jeton3,Jeton4],NewMarchandise):-
	initJeton(Marchandise,Jeton1,Marchandise2),
	initJeton(Marchandise2,Jeton2,Marchandise3),
	initJeton(Marchandise3,Jeton3,Marchandise4),
	initJeton(Marchandise4,Jeton4,NewMarchandise).

% Pr�dicat pour retirer l'�l�ment E d'une liste [T|Q]

remove([E|Q],E,Q):-!.
remove([T|Q],E,[T|R]):-remove(Q,E,R).

% Le pr�dicat initJeton g�n�re un nombre comprit entre 1 et la taille de la liste initialis�e plus haut
% Il incr�mente de 1 la longueur renvoy�e par le pr�dicat length car le pr�dicat random g�n�re un nombre al�atoire entre 1 et le deuxi�me argument-1 
% Il va ensuite r�cup�rer l'�l�ment qui se trouve dans la liste � la position correspondant au nombre al�atoire
% Finalement, il le supprime

initJeton(Marchandise,Jeton,NewMarchandise):-
	length(Marchandise,Longueur1),
	Longueur2 is Longueur1+1, 
	random(1,Longueur2,Rand),
	nth(Rand,Marchandise,Jeton),
	remove(Marchandise,Jeton,NewMarchandise).

% La bourse de d�part est toujours la m�me

initBourse([[ble,7],[riz,6],[cacao,6],[cafe,6],[sucre,6],[mais,6]]).

% Au d�part les joueurs n'ont aucun jeton dans leurs r�serves 

initJ1([]).
initJ2([]).

% La position de d�part du trader n'a aucune influence

initTrader(1).

/* PREDICAT PLATEAUDEPART(?PLATEAU) */ 

% On initialise l'ensemble du plateau en un seul pr�dicat

plateauDepart([M,B,T,J1,J2]):-
	init(I),
	initMarchandise(I,M),
	initTrader(T),
	initJ1(J1),
	initJ2(J2),
	initBourse(B).


/********************
DEROULEMENT D'UN COUP
*********************/

% Pr�dicat pour �changer un �l�ment E par un �l�ment E1 dans une liste [T|Q]
% N'est plus utilis�

/*
exchange([E|Q],E,E1,[E1|Q]):-!.
exchange([T|Q],E,E1,[T|R]):-exchange(Q,E,E1,R).
*/

% Pr�dicat pour conna�tre le premier �l�ment de la sous liste (pile) pr�c�dent la position du trader apr�s que le coup ait �t� effectu� 
% Le modulo permet au pr�dicat de fonctionner avec des d�placements sup�rieur au nombre de pile

precedent(Marchandise,Deplacement,PositionTrader,ElementPrecedent):-length(Marchandise,Longueur), 
											 						PositionTraderTemporaire is PositionTrader+Deplacement-1, 
											 						PositionTraderFuture is PositionTraderTemporaire mod Longueur, 
											 						nth(PositionTraderFuture,Marchandise,[ElementPrecedent|_]).

% Idem mais pour la pile suivante

suivant(Marchandise,Deplacement,Trader,ElementSuivant):-length(Marchandise,Longueur), 
										   				PositionTraderTemporaire is Trader+Deplacement+1, 
										   				PositionTraderFuture is PositionTraderTemporaire mod Longueur, 
										   				nth(PositionTraderFuture,Marchandise,[ElementSuivant|_]).

% Pr�dicat pour v�rifier si les �l�ments contenus dans le coup sont bien ceux trouv�s par les pr�dicats precedent et suivant
% Le pr�dicat peut �tre vrai dans les deux cas suivants car l'�l�ment pr�c�dent peut �tre soit l'�l�ment conserv� soit l'�l�ment
% jet�. Idem pour l'�l�ment suivant 

verif([X,Y],[X,Y]).
verif([X,Y],[Y,X]).

/* PREDICAT COUPPOSSIBLE(+PLATEAU, ?COUP) */

% Le pr�dicat coupPossible utilise le pr�dicat member(E,L) qui v�rifie si l'�l�lement E se trouve dans la liste L 
% Il va d'abord v�rifier que le d�placement est conforme aux r�gles du jeu, c'est � dire s'il est compris entre 1 et 3
% Il va ensuite r�cup�rer les t�tes des sous-listes pr�c�dent et suivant la sous-liste sur laquelle le trader se trouve
% Finalement, il v�rifie que ces t�tes soient bien les m�mes que les �l�ments du coup � jouer

coupPossible([Marchandise,_,PositionTrader,_,_],[_,Deplacement,ElementGarde,ElementJete]):-member(Deplacement,[1,2,3]),
												 										   precedent(Marchandise,Deplacement,PositionTrader,ElementPrecedent),
												 										   suivant(Marchandise,Deplacement,PositionTrader,ElementSuivant),
												 										   verif([ElementGarde,ElementJete],[ElementPrecedent,ElementSuivant]),!.

% On d�coupe les changements en plusieurs pr�dicats

% Pr�dicat changeBourse modifiant la bourse en fonction du coup jou�
% Il parcourt la bourse jusqu'� ce qu'il trouve la sous-liste dont le premier �l�ment est �gal au deuxi�me
% renseign� dans le coup, c'est � dire celui qu'il faut jeter
% Conform�ment aux r�gles du jeu il va ensuite soustraire 1 � la valeur associ�e � cet �l�ment

changeBourse([[ElementJete,Valeur]|Queue],ElementJete,[[ElementJete,NewValeur]|Queue]):-NewValeur is Valeur-1,!.
changeBourse([Tete|Queue],ElementJete,[Tete|R]):-changeBourse(Queue,ElementJete,R).

% Pr�dicat permettant d'ajouter le premier �l�ment du coup dans la r�serve du joueur
% Il utilise le pr�dicat append(L1,L2,L3) qui concatene les listes L1 et L2 pour former la liste L3

changeJoueur(Joueur,ElementGarde,NewJoueur):-append(Joueur,[ElementGarde],NewJoueur).

% Pr�dicat qui d�place le trader du nombre de pile renseign� dans le coup

changeTrader(Marchandise,Trader,Deplacement,NewTrader):-length(Marchandise,Longueur), 
														NewTraderTemporaire is Trader+Deplacement, 
														NewTrader is NewTraderTemporaire mod Longueur.

% Pr�dicat permettant de supprimer la t�te de la i�me sous-liste et de renvoyer la liste modifi�e 

supprimeElement([[_|R]|Queue],1,[R|Queue]):-!.
supprimeElement([Tete|Queue],PositionRelativeSousListe,[Tete|R]):-NewPositionRelativeSousListe is PositionRelativeSousListe-1, 
																	  supprimeMarchandise(Queue,NewPositionRelativeSousListe,R).

% Pr�dicat identifiant la position de la sous-liste pr�c�dent la position future du trader et supprimant son premier �l�ment

supprimeMarchandisePrecedent(Marchandise,Deplacement,PositionTrader,NewMarchandise):-length(Marchandise,Longueur), 
																					 PositionTraderTemporaire is PositionTrader+Deplacement-1, 
																					 PositionTraderFuture is PositionTraderTemporaire mod Longueur, 
																					 supprimeElement(Marchandise,PositionTraderFuture,NewMarchandise).

% Idem mais pour la sous-liste suivante

supprimeMarchandiseSuivant(Marchandise,Deplacement,PositionTrader,NewMarchandise):-length(Marchandise,Longueur), 
																				   PositionTraderTemporaire is PositionTrader+Deplacement+1, 
																				   PositionTraderFuture is PositionTraderTemporaire mod Longueur, 
																				   supprimeElement(Marchandise,PositionTraderFuture,NewMarchandise).

% Pr�dicat executant deux, une ou aucune fois le pr�dicat remove en fonction de nombre de liste vide � supprimer apr�s que le coup ait �t� jou�

remove2(L,E,L2):-remove(L,E,L1),remove(L1,E,L2),!.
remove2(L,E,L2):-remove(L,E,L2),!.
remove2(L,_,L).

supprimeMarchandise(Marchandise,Deplacement,PositionTrader,NewMarchandise):-supprimeMarchandisePrecedent(Marchandise,Deplacement,PositionTrader,MarchandiseBis),
																    		supprimeMarchandiseSuivant(MarchandiseBis,Deplacement,PositionTrader,MarchandiseTer),
																    		remove2(MarchandiseTer,[],NewMarchandise).

jouerCoup([Marchandise,Bourse,PositionTrader,Joueur1,Joueur2],
		  [j1,Deplacement,ElementGarde,ElementJete],
		  [NewMarchandise,NewBourse,NewPositionTrader,NewJoueur1,Joueur2]):-changeBourse(Bourse,ElementJete,NewBourse),
																			   changeJoueur(Joueur1,ElementGarde,NewJoueur1),
																			   changeTrader(Marchandise,PositionTrader,Deplacement,NewPositionTrader),
																			   supprimeMarchandise(Marchandise,Deplacement,PositionTrader,NewMarchandise),!.
jouerCoup([Marchandise,Bourse,PositionTrader,Joueur1,Joueur2],
		  [j2,Deplacement,ElementGarde,ElementJete],
		  [NewMarchandise,NewBourse,NewPositionTrader,Joueur1,NewJoueur2]):-changeBourse(Bourse,ElementJete,NewBourse),
																			   changeJoueur(Joueur2,ElementGarde,NewJoueur2),
																			   changeTrader(Marchandise,PositionTrader,Deplacement,NewPositionTrader),
																			   supprimeMarchandise(Marchandise,Deplacement,PositionTrader,NewMarchandise),!.


/************
DONNEES TESTS
*************/

fauxCoup([j1,2,riz,sucre]).
fauxPlateau([[[ma�s, riz, ble, ble],
[riz, ma�s, sucre, riz],
[mais, sucre, cacao, riz],
[sucre, ma�s, sucre, ma�s],
[cacao, ma�s, ble, sucre],
[riz, cafe, sucre, ble],
[cafe, ble, sucre, cacao],
[ma�s, cacao, cacao],
[riz,riz,cafe,cacao]],
[[ble,7],[riz,6],[cacao,6],[cafe,6],[sucre,6],[mais,6]],
1,[],[]]).
fausseBourse([[ble,7],[riz,6],[cacao,6],[cafe,6],[sucre,6],[mais,6]]).
fausseMarchandise([[ma�s, riz, ble, ble],
[riz, ma�s, sucre, riz],
[mais],
[sucre, ma�s, sucre, ma�s],
[cacao],
[riz, cafe, sucre, ble],
[cafe, ble, sucre, cacao],
[ma�s, cacao, cacao],
[riz,riz,cafe,cacao]]).