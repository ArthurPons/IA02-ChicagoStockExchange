/*******************
AFFICHAGE DU PLATEAU
********************/

% On découpe l'affichage en différentes parties puis on construit un unique prédicat pour afficher le tout

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

% On liste l'ensemble des ressources à notre disposition et on ira piocher dedans aléatoirement

init([ble,ble,ble,ble,ble,ble,mais,mais,mais,mais,
	  mais,mais,riz,riz,riz,riz,riz,riz,cacao,cacao,
	  cacao,cacao,cacao,cacao,cafe,cafe,cafe,cafe,
	  cafe,cafe,sucre,sucre,sucre,sucre,sucre,sucre]).

% Initialiser les Marchandises revient à initialiaser les piles qui revient à initialiser les jetons

% 9 piles à initialiser 

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

% 4 jetons par pile à initialiser

initPile(Marchandise,[Jeton1,Jeton2,Jeton3,Jeton4],NewMarchandise):-
	initJeton(Marchandise,Jeton1,Marchandise2),
	initJeton(Marchandise2,Jeton2,Marchandise3),
	initJeton(Marchandise3,Jeton3,Marchandise4),
	initJeton(Marchandise4,Jeton4,NewMarchandise).

% Prédicat pour retirer l'élément E d'une liste [T|Q]

remove([E|Q],E,Q):-!.
remove([T|Q],E,[T|R]):-remove(Q,E,R).

% Le prédicat initJeton génère un nombre comprit entre 1 et la taille de la liste initialisée plus haut
% Il incrémente de 1 la longueur renvoyée par le prédicat length car le prédicat random génère un nombre aléatoire entre 1 et le deuxième argument-1 
% Il va ensuite récupérer l'élément qui se trouve dans la liste à la position correspondant au nombre aléatoire
% Finalement, il le supprime

initJeton(Marchandise,Jeton,NewMarchandise):-
	length(Marchandise,Longueur1),
	Longueur2 is Longueur1+1, 
	random(1,Longueur2,Rand),
	nth(Rand,Marchandise,Jeton),
	remove(Marchandise,Jeton,NewMarchandise).

% La bourse de départ est toujours la même

initBourse([[ble,7],[riz,6],[cacao,6],[cafe,6],[sucre,6],[mais,6]]).

% Au départ les joueurs n'ont aucun jeton dans leurs réserves 

initJ1([]).
initJ2([]).

% La position de départ du trader n'a aucune influence

initTrader(1).

/* PREDICAT PLATEAUDEPART(?PLATEAU) */ 

% On initialise l'ensemble du plateau en un seul prédicat

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

% Prédicat pour échanger un élément E par un élément E1 dans une liste [T|Q]
% N'est plus utilisé

/*
exchange([E|Q],E,E1,[E1|Q]):-!.
exchange([T|Q],E,E1,[T|R]):-exchange(Q,E,E1,R).
*/

% Le modulo permet au prédicat de fonctionner avec des déplacements supérieur au nombre de pile

modulo(6,3,1).
modulo(X,Y,Z):- X > Y, Z is X mod Y,!.
modulo(X,_,X).

% Prédicat pour connaître le premier élément de la sous liste (pile) précédent la position du trader après que le coup ait été effectué 

precedent(Marchandise,Deplacement,PositionTrader,ElementPrecedent):-
	length(Marchandise,Longueur), 
	PositionTraderTemporaire is PositionTrader+Deplacement-1, 
	modulo(PositionTraderTemporaire, Longueur, PositionTraderFuture),
	nth(PositionTraderFuture,Marchandise,[ElementPrecedent|_]).

% Idem mais pour la pile suivante

suivant(Marchandise,Deplacement,Trader,ElementSuivant):-
	length(Marchandise,Longueur), 
	PositionTraderTemporaire is Trader+Deplacement+1, 
	modulo(PositionTraderTemporaire, Longueur, PositionTraderFuture), 
	nth(PositionTraderFuture,Marchandise,[ElementSuivant|_]).

% Prédicat pour vérifier si les éléments contenus dans le coup sont bien ceux trouvés par les prédicats precedent et suivant
% Le prédicat peut être vrai dans les deux cas suivants car l'élément précédent peut être soit l'élément conservé soit l'élément
% jeté. Idem pour l'élément suivant 

verif([X,Y],[X,Y]).
verif([X,Y],[Y,X]).

/* PREDICAT COUPPOSSIBLE(+PLATEAU, ?COUP) */

% Le prédicat coupPossible utilise le prédicat member(E,L) qui vérifie si l'élélement E se trouve dans la liste L 
% Il va d'abord vérifier que le déplacement est conforme aux règles du jeu, c'est à dire s'il est compris entre 1 et 3
% Il va ensuite récupérer les têtes des sous-listes précédent et suivant la sous-liste sur laquelle le trader se trouve
% Finalement, il vérifie que ces têtes soient bien les mêmes que les éléments du coup à jouer

coupPossible([Marchandise,_,PositionTrader,_,_],[_,Deplacement,ElementGarde,ElementJete]):-
	member(Deplacement,[1,2,3]),
	precedent(Marchandise,Deplacement,PositionTrader,ElementPrecedent),
	suivant(Marchandise,Deplacement,PositionTrader,ElementSuivant),
	verif([ElementGarde,ElementJete],[ElementPrecedent,ElementSuivant]),!.

% On découpe les changements en plusieurs prédicats

% Prédicat changeBourse modifiant la bourse en fonction du coup joué
% Il parcourt la bourse jusqu'à ce qu'il trouve la sous-liste dont le premier élément est égal au deuxième
% renseigné dans le coup, c'est à dire celui qu'il faut jeter
% Conformément aux règles du jeu il va ensuite soustraire 1 à la valeur associée à cet élément

changeBourse([[ElementJete,Valeur]|Queue],ElementJete,[[ElementJete,NewValeur]|Queue]):-NewValeur is Valeur-1,!.
changeBourse([Tete|Queue],ElementJete,[Tete|R]):-changeBourse(Queue,ElementJete,R).

% Prédicat permettant d'ajouter le premier élément du coup dans la réserve du joueur
% Il utilise le prédicat append(L1,L2,L3) qui concatene les listes L1 et L2 pour former la liste L3

changeJoueur(Joueur,ElementGarde,NewJoueur):-append(Joueur,[ElementGarde],NewJoueur).

% Prédicat qui déplace le trader du nombre de pile renseigné dans le coup

changeTrader(Marchandise,Trader,Deplacement,NewTrader):-
	length(Marchandise,Longueur), 
	NewTraderTemporaire is Trader+Deplacement, 
	modulo(NewTraderTemporaire, Longueur, NewTrader).

% Prédicat permettant de supprimer la tête de la ième sous-liste et de renvoyer la liste modifiée 

supprimeElement([[_|R]|Queue],1,[R|Queue]):-!.
supprimeElement([Tete|Queue],PositionRelativeSousListe,[Tete|R]):-
	NewPositionRelativeSousListe is PositionRelativeSousListe-1, 
	supprimeElement(Queue,NewPositionRelativeSousListe,R).

% Prédicat identifiant la position de la sous-liste précédent la position future du trader et supprimant son premier élément

supprimeMarchandisePrecedent(Marchandise,Deplacement,PositionTrader,NewMarchandise,NewPositionTrader):-
	length(Marchandise,Longueur), 
	PositionTraderTemporaire is PositionTrader+Deplacement-1, 
	modulo(PositionTraderTemporaire, Longueur, PositionTraderFuture), 
	supprimeElement(Marchandise,PositionTraderFuture,NewMarchandise),
	verifTrader(PositionTrader,NewMarchandise,NewPositionTrader).

% Idem mais pour la sous-liste suivante

supprimeMarchandiseSuivant(Marchandise,Deplacement,PositionTrader,NewMarchandise):-
	length(Marchandise,Longueur), 
	PositionTraderTemporaire is PositionTrader+Deplacement+1, 
	modulo(PositionTraderTemporaire, Longueur, PositionTraderFuture),
	supprimeElement(Marchandise,PositionTraderFuture,NewMarchandise).

% Prédicat executant deux, une ou aucune fois le prédicat remove en fonction de nombre de liste vide à supprimer après que le coup ait été joué

remove2(L,E,L2):-remove(L,E,L1),remove(L1,E,L2),!.
remove2(L,E,L2):-remove(L,E,L2),!.
remove2(L,_,L).

verifTrader(T,M,NT):-remove(M,[],_),NT is T-1.
verifTrader(T,_,T).

% Prédicat supprimant les premiers éléments des sous-listes précédent et suivant la position actuelle du trader puis 
% supprimant toutes les sous-listes vides éventuellement crées

changeMarchandise(Marchandise,Deplacement,PositionTrader,NewMarchandise,NewPositionTrader):-
	supprimeMarchandisePrecedent(Marchandise,Deplacement,PositionTrader,MarchandiseBis,NewPositionTrader),
	supprimeMarchandiseSuivant(MarchandiseBis,Deplacement,PositionTrader,MarchandiseTer),
	remove2(MarchandiseTer,[],NewMarchandise).

/* PREDICAT JOUERCOUP(+PlateauInitial,?Coup,?NouveauPlateau) */

% Le prédicat jouerCoup modifie dans l'ordre, la bourse, le joueur et le plateau

jouerCoup([Marchandise,Bourse,PositionTrader,Joueur1,Joueur2],
		  [j1,Deplacement,ElementGarde,ElementJete],
		  [NewMarchandise,NewBourse,NewPositionTrader2,NewJoueur1,Joueur2]):-
				changeBourse(Bourse,ElementJete,NewBourse),
				changeJoueur(Joueur1,ElementGarde,NewJoueur1),
				changeMarchandise(Marchandise,Deplacement,PositionTrader,NewMarchandise,NewPositionTrader),
				changeTrader(NewMarchandise,NewPositionTrader,Deplacement,NewPositionTrader2),
				!.
jouerCoup([Marchandise,Bourse,PositionTrader,Joueur1,Joueur2],
		  [j2,Deplacement,ElementGarde,ElementJete],
		  [NewMarchandise,NewBourse,NewPositionTrader2,Joueur1,NewJoueur2]):-
				changeBourse(Bourse,ElementJete,NewBourse),
				changeJoueur(Joueur2,ElementGarde,NewJoueur2),
				changeMarchandise(Marchandise,Deplacement,PositionTrader,NewMarchandise,NewPositionTrader),
				changeTrader(NewMarchandise,NewPositionTrader,Deplacement,NewPositionTrader2),
				!.

				
				
joueurJoueur(P):-debutJeu(P),jouer(j1,P).

debutJeu(P):-plateauDepart(P),affichePlateau(P).

jouer(_,[Marchandise,B,_,J1,J2]):-length(Marchandise,N), N=<2, write('La partie est finie.'), score(J1,B,S1), score(J2,B,S2), gagnant(S1,S2).
jouer(J,P):-write('Entrez le déplacement, l élément à garder et celui à jeter\n'),read(D),read(Garde),read(Jette),verifCoup([J,D,Garde,Jette],P).

verifCoup(C,P):-coupPossible(P,C), jouerCoup(P,C,NP),write('On passe au tour suivant\n'),affichePlateau(NP),coupSuivant(C,NP).
verifCoup([J,_,_,_],P):-write('Coup impossible ! Redonnez votre coup!\n'),jouer(J,P).

coupSuivant([j1,_,_,_],P):-jouer(j2,P).
coupSuivant([j2,_,_,_],P):-jouer(j1,P).

score([],_,0).
score([T|Q],B,S):-score(Q,B,NS),scoreBourse(T,B,R),S is NS+R.

scoreBourse(E,[[E|[R]]|_],R).
scoreBourse(E,[T|Q],R):-scoreBourse(E,Q,R).

gagnant(S1,S2):-S1>S2, write('Le joueur 1 a gagné avec un score de '), write(S1), write(' !\n'),!.
gagnant(S1,S2):-S1<S2, write('Le joueur 2 a gagné avec un score de '), write(S2), write(' !\n'),!.
gagnant(S1,S2):-write('Egalité avec un score de '), write(S1), write(' !\n'),!.

/************
DONNEES TESTS
*************/

fauxCoup([j1,3,riz,riz]).
fauxPlateau([[[mais, riz, ble],
[riz, cafe],
[mais, sucre]],
[[ble,7],[riz,6],[cacao,6],[cafe,6],[sucre,6],[mais,6]],
3,[],[]]).
fausseBourse([[ble,7],[riz,6],[cacao,6],[cafe,6],[sucre,6],[mais,3]]).
fauxJoueur([ble,mais,ble,riz]).
fausseMarchandise([[mais, riz, ble, ble],
[riz, mais, sucre, riz],
[mais],
[sucre, mais, sucre, mais],
[cacao],
[riz, cafe, sucre, ble],
[cafe, ble, sucre, cacao],
[mais, cacao, cacao],
[riz,riz,cafe,cacao]]).
