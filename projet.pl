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

afficheTrader(_,Marchandise):-length(Marchandise,Longueur),Longueur=:=1,write('x'),!.
afficheTrader(1,_):-write('x'),!.
afficheTrader(N,_):-write('\t'),M is N-1, afficheTrader(M,_).

afficheBourse([]).
afficheBourse([[T|L]|Q]):-write(T),write(':\t'),write(L),nl,afficheBourse(Q).

afficheListe([]):-write('rien.').
afficheListe([T|[]]):-write(T), write('.').
afficheListe([T|Q]):-write(T), write(', '), afficheListe(Q).

afficheJ1(L):-write('La reserve du joueur 1 contient: '), afficheListe(L).
afficheJ2(L):-write('La reserve du joueur 2 contient: '), afficheListe(L).

affichePlateau([Marchandise,Bourse,PositionTrader,Joueur1,Joueur2]):-
    write('Bourse:'),nl,afficheBourse(Bourse),nl,
    write('Plateau:'),nl, afficheMarchandise(Marchandise),nl,
    afficheQuantite(Marchandise),nl,afficheTrader(PositionTrader,Marchandise),nl,nl,
    afficheJ1(Joueur1),nl,afficheJ2(Joueur2),nl.


/********************
GENERATION DU PLATEAU
*********************/

% On liste l'ensemble des ressources à notre disposition et on ira piocher dedans aléatoirement

init([ble,ble,ble,ble,ble,ble,mais,mais,mais,mais,mais,mais,
riz,riz,riz,riz,riz,riz,cacao,cacao,cacao,cacao,cacao,cacao,
cafe,cafe,cafe,cafe,cafe,cafe,sucre,sucre,sucre,sucre,sucre,sucre]).

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

plateauDepart([Marchandise,Bourse,PositionTrader,J1,J2]):-
    init(InitialList),
    initMarchandise(InitialList,Marchandise),
    initTrader(PositionTrader),
    initJ1(J1),
    initJ2(J2),
    initBourse(Bourse).


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
% Si on applique à une variable le modulo de cette même variable, celui-ci renvoit la variable et non 0

modulo(X, Y, Y):-Z is X mod Y, Z=:=0,!.
modulo(X,Y,Z):- Z is X mod Y,!.

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
%Si cette sous-liste est vide, alors elle est supprimé et la position du trader diminue de 1

supprimeMarchandisePrecedent(Marchandise,Deplacement,PositionTrader,NewMarchandise,NewPositionTrader):-
    length(Marchandise,Longueur),
    PositionTraderTemporaire is PositionTrader+Deplacement-1,
    modulo(PositionTraderTemporaire, Longueur, PositionTraderFuture),
    supprimeElement(Marchandise,PositionTraderFuture,MarchandiseBis),
    verifTraderP(PositionTrader,MarchandiseBis,NewPositionTrader,NewMarchandise).

% Idem mais pour la sous-liste suivante

supprimeMarchandiseSuivant(Marchandise,Deplacement,PositionTrader,NewMarchandise,NewPositionTrader):-
    length(Marchandise,Longueur),
    PositionTraderTemporaire is PositionTrader+Deplacement+1,
    modulo(PositionTraderTemporaire, Longueur, PositionTraderFuture),
    supprimeElement(Marchandise,PositionTraderFuture,NewMarchandise),
    verifTraderS(PositionTrader,NewMarchandise,NewPositionTrader).

% Prédicat executant une ou aucune fois le prédicat remove en fonction de nombre de liste vide à supprimer après que le coup ait été joué

remove2(L,E,L2):-remove(L,E,L2),!.
remove2(L,_,L).

% Prédicat qui vérifie si une liste vide est crée après suppression du premier élément de précédent, la supprime et déplace le trader de -1

verifTraderP(T,M,NT,NM):-remove(M,[],NM),NT is T-1.
verifTraderP(T,M,T,M).

% Prédicat qui vérifie si une liste vide est crée après suppression du premier élément de suivant quand suivant est en première position, la supprime et déplace le trader de -1

verifTraderS(T,M,NT):-length(M,Longueur),T=:=Longueur,remove(M,[],_), NT is T-1.
verifTraderS(T,_,T).

% Prédicat supprimant les premiers éléments des sous-listes précédent et suivant la position actuelle du trader puis
% supprimant toutes les sous-listes vides éventuellement crées

changeMarchandise(Marchandise,Deplacement,PositionTrader,NewMarchandise,NewPositionTrader):-
    supprimeMarchandisePrecedent(Marchandise,Deplacement,PositionTrader,MarchandiseBis,PositionTraderBis),
    supprimeMarchandiseSuivant(MarchandiseBis,Deplacement,PositionTraderBis,MarchandiseTer,NewPositionTrader),
    remove2(MarchandiseTer,[],NewMarchandise).

/* PREDICAT JOUERCOUP(+PlateauInitial,?Coup,?NouveauPlateau) */

% Le prédicat jouerCoup modifie dans l'ordre la bourse, le joueur, le plateau et enfin la marchandise

jouerCoup([Marchandise,Bourse,PositionTrader,Joueur1,Joueur2],[j1,Deplacement,ElementGarde,ElementJete],[NewMarchandise,NewBourse,NewPositionTrader2,NewJoueur1,Joueur2]):-
    changeBourse(Bourse,ElementJete,NewBourse),
    changeJoueur(Joueur1,ElementGarde,NewJoueur1),
    changeMarchandise(Marchandise,Deplacement,PositionTrader,NewMarchandise,NewPositionTrader),
    changeTrader(NewMarchandise,NewPositionTrader,Deplacement,NewPositionTrader2),
    !.
jouerCoup([Marchandise,Bourse,PositionTrader,Joueur1,Joueur2],[j2,Deplacement,ElementGarde,ElementJete],[NewMarchandise,NewBourse,NewPositionTrader2,Joueur1,NewJoueur2]):-
    changeBourse(Bourse,ElementJete,NewBourse),
    changeJoueur(Joueur2,ElementGarde,NewJoueur2),
    changeMarchandise(Marchandise,Deplacement,PositionTrader,NewMarchandise,NewPositionTrader),
    changeTrader(NewMarchandise,NewPositionTrader,Deplacement,NewPositionTrader2),
    !.

/*************************
INTELLIGENCE ARTIFICIELLE
**************************/


/* PREDICAT COUPSPOSSIBLES(+Plateau,+Joueur,?ListeCoupsPossibles) */

% Prédicat qui crée une liste des coups possible pour un etat donné*/

coupsPossibles(Plateau,Joueur,ListeCoup):-creerCoup(Joueur,Plateau,3,ListeCoup).

% Prédicat qui crée les deux coups possibles pour un déplacement donné, puis passe au déplacement inférieur

creerCoup(_,_,0,[]).
creerCoup(Joueur,[Marchandise,_,Position,_,_],Deplacement,[[Joueur,Deplacement,Precedent,Suivant]|[[Joueur,Deplacement,Suivant,Precedent]|Reste]]):-
    precedent(Marchandise,Deplacement,Position,Precedent),
    suivant(Marchandise,Deplacement,Position,Suivant),
    DeplacementTemp is Deplacement-1,
    creerCoup(Joueur,[Marchandise,_,Position,_,_],DeplacementTemp,Reste).


% Prédicat qui renvoit l'autre joueur que celui appelé

autreJ(j1,j2).
autreJ(j2,j1).

/*Application de l'algorithm minmax décomposé en 4 parties*/
 
% scoreMinmax permet de récuperer un score pour le minmax
% Les trois premiers sont utilisés pour calculer la parties max de l'algorithme, les trois dernier la partie min
% Le paramètre Joueur sert a connaitre le Joueur pour lequel l'algorithme minmax est appliqué
% Le dernier paramètre est le nombre de profondeur de l'algorithme, celui-ci est décrementé pour que le programme ne passe pas un temps élévé à appliquer l'algorithme car la complexité est élevée
% Le premier scoreMinmax est une condition d'arret sur ceux paramètre qui renvoie le score d'un coup

scoreMinmax([Joueur,_,ElementGarde,_],[_,Bourse,_,_,_],Joueur,Score,Bourse,0):-
    score([ElementGarde],Bourse,Score),!.

%Le deuxième est une condition d'arrêt si l'on arrive à une fin de partie qui renvoie le score du dernier coup

scoreMinmax([Joueur,_,ElementGarde,_],[Marchandise,Bourse,_,_,_],Joueur,Score,Bourse,_):-
    length(Marchandise,Longueur),Longueur<3,score([ElementGarde],Bourse,Score),!.

% Le troisième additionne le score d'un coup avec le score obtenu par la partie min de l'algorithme appliqué à ce coup

scoreMinmax([Joueur,_,ElementGarde,_],Plateau,Joueur,Score,Bourse,Iteration):-
    autreJ(Joueur,AutreJoueur),
    coupsPossibles(Plateau,AutreJoueur,NouvelleListeCoup),
    minmax(Plateau,NouvelleListeCoup,Joueur,ScoreTemp1,Bourse,_,Iteration),
    score([ElementGarde],Bourse,ScoreTemp2),
    Score is ScoreTemp1+ScoreTemp2.

% Le quatrième est une condition d'arret similaire au premier qui renvoit la valeur négative du score du coup

scoreMinmax([AutreJoueur,_,ElementGarde,_],[_,Bourse,_,_,_],Joueur,Score,Bourse,0):-
    Joueur\=AutreJoueur,score([ElementGarde],Bourse,ScoreTemp),Score is -ScoreTemp,!.

% Le cinquième est une condition d'arrêt si l'on arrive à une fin de partie qui renvoie la valeur négative du score du dernier coup

scoreMinmax([AutreJoueur,_,ElementGarde,_],[Marchandise,Bourse,_,_,_],Joueur,Score,Bourse,_):-
    Joueur\=AutreJoueur,length(Marchandise,Longueur),Longueur<3,score([ElementGarde],Bourse,ScoreTemp),Score is -ScoreTemp,!.

% Le cinquième soustrait le score obtenu par la partie max de l'algorithme appliqué à un coup par le score de ce coup

scoreMinmax([AutreJoueur,_,ElementGarde,_],Plateau,Joueur,Score,Bourse,Iteration):-
    Joueur\=AutreJoueur,
    coupsPossibles(Plateau,Joueur,NouvelleListeCoup),
    minmax(Plateau,NouvelleListeCoup,Joueur,ScoreTemp1,Bourse,_,Iteration),
    score([ElementGarde],Bourse,ScoreTemp2),
    Score is ScoreTemp1 - ScoreTemp2.

%Ce prédicat choisit un élément de la liste de coups possibles et renvoie sa valeur minmax

coupMinmax(Plateau,ListeCoup,Joueur,Score,Bourse,Coup,Iteration):-
    nth(_,ListeCoup,Coup),
    jouerCoup(Plateau,Coup,NouveauPlateau),
    scoreMinmax(Coup,NouveauPlateau,Joueur,Score,Bourse,Iteration).

%Ce prédicat permet d'appliquerla partie max de l'algorithme minmax en vérifiant que le score obtenu n'est pas plus petit qu'un des autres scores possibles

minmax(Plateau,[[Joueur,Deplacement,Prec,Suiv]|Reste],Joueur,Score,Bourse,Coup,Iteration):-
    Temp is Iteration-1,
    nth(_,[[Joueur,Deplacement,Prec,Suiv]|Reste],Coup),
    jouerCoup(Plateau,Coup,NouveauPlateau),
    scoreMinmax(Coup,NouveauPlateau,Joueur,Score,Bourse,Temp),
    \+plus_petit(Plateau,[[Joueur,Deplacement,Prec,Suiv]|Reste],Joueur,Score,Temp),!.

%Ce prédicat permet d'appliquerla partie min de l'algorithme minmax en vérifiant que le score obtenu n'est pas plus grand qu'un des autres scores possibles

minmax(Plateau,[[AutreJoueur,Deplacement,Prec,Suiv]|Reste],Joueur,Score,Bourse,Coup,Iteration):-
    Joueur\=AutreJoueur,nth(_,[[AutreJoueur,Deplacement,Prec,Suiv]|Reste],Coup),
    jouerCoup(Plateau,Coup,NouveauPlateau),
    scoreMinmax(Coup,NouveauPlateau,Joueur,Score,Bourse,Iteration),
    \+plus_grand(Plateau,[[AutreJoueur,Deplacement,Prec,Suiv]|Reste],Joueur,Score,Iteration),!.

% Permet de voir si un score est plus petit ou plus grand qu'un autre

plus_petit(Plateau,Lcoup,Joueur,Score,Iteration):-coupMinmax(Plateau,Lcoup,Joueur,ScoreTemp,_,_,Iteration),Score<ScoreTemp,!.
plus_grand(Plateau,Lcoup,Joueur,Score,Iteration):-coupMinmax(Plateau,Lcoup,Joueur,ScoreTemp,_,_,Iteration),Score>ScoreTemp,!.


/* PREDICAT MEILLEUR_COUP(+Plateau,+Joueur,?MeilleurCoup) */

%Ce prédicat permet d'obtenir le meilleur coups possibles grâce à l'algorithme minmax

meilleur_coup(Plateau,Joueur,Coup):-coupsPossibles(Plateau,Joueur,ListeCoups),minmax(Plateau,ListeCoups,Joueur,_,_,Coup,2).


/******************************************
DEROULEMENT D'UNE PARTIE ENTRE DEUX JOUEURS
*******************************************/

/*Permet de créer une partie entre deux joueurs*/

joueurJoueur:-debutJeu(P),jouer(j1,P).

debutJeu(P):-plateauDepart(P),affichePlateau(P).

% Appel de fin de partie

jouer(_,[Marchandise,Bourse,_,J1,J2]):-
    length(Marchandise,N),
    N=<2,
    write('La partie est finie.\n'),
    score(J1,Bourse,Score1),
    score(J2,Bourse,Score2),
    gagnant(Score1,Score2).

% Demande au joueur de jouer un coup

jouer(J,P):-
    write('Entrez le nombre de deplacement que vous voulez effectuer.\n'),
    read(D),
    write('Entrez l element à garder.\n'),
    read(Garde),
    write('Entrez l element à jeter.\n'),
    read(Jette),
    verifCoup([J,D,Garde,Jette],P).

% Predicat qui verifie si un coup est possible
% Si oui, on passe au coup du joueur suivant

verifCoup(C,P):-
    coupPossible(P,C),
    jouerCoup(P,C,NouveauPlateau),
    write('On passe au tour suivant.\n'),
    affichePlateau(NouveauPlateau),
    coupSuivant(C,NouveauPlateau).

% Sinon, le joueur entre un nouveau coup

verifCoup([J,_,_,_],P):-write('Coup impossible ! Redonnez votre coup!\n'),jouer(J,P).

% Appel le coup suivant

coupSuivant([j1,_,_,_],P):-jouer(j2,P).
coupSuivant([j2,_,_,_],P):-jouer(j1,P).

% Calcule le score final

score([],_,0).
score([T|Q],Bourse,S):-score(Q,Bourse,NS),scoreBourse(T,Bourse,R),S is NS+R.

% Trouve la valeur d'un élément dans la bourse

scoreBourse(E,[[E|[R]]|_],R):-!.
scoreBourse(E,[_|Q],R):-scoreBourse(E,Q,R).

% Trouve et affiche le gagnant

gagnant(Score1,Score2):-Score1>Score2, write('Le joueur 1 a gagné avec un score de '), write(Score1), write('et le score du joueur 2 est '), write(Score2),write(' !\n'),!.
gagnant(Score1,Score2):-Score1<Score2, write('Le joueur 2 a gagné avec un score de '), write(Score2), write('et le score du joueur 1 est '), write(Score1), write(' !\n'),!.
gagnant(Score1,_):-write('Egalite avec un score de '), write(Score1), write(' !\n'),!.


/****************************************************
DEROULEMENT D'UNE PARTIE ENTRE UN JOUEURS ET UN ORDI
****************************************************/

/*Permet de créer une partie entre un joueur et un ordi*/

% Début de partie si le joueur commence

joueurOrdiJ:-debutJeu(P),jouerJO(j1,P).

% Début de partie si l'ordi commence 

joueurOrdiO:- debutJeu(P),jouerJO(j2,P).

% Appel de fin de partie

jouerJO(_,[Marchandise,Bourse,_,J1,J2]):-
    length(Marchandise,N),
    N=<2,
    write('La partie est finie.\n'),
    score(J1,Bourse,Score1),
    score(J2,Bourse,Score2),
    gagnantJO(Score1,Score2).

% Demande au joueur de jouer un coup

jouerJO(j1,P):-
    write('Entrez le nombre de deplacement que vous voulez effectuer.\n'),
    read(D),
    write('Entrez l element a garder.\n'),
    read(Garde),
    write('Entrez l element a jeter.\n'),
    read(Jette),
    verifCoupJO([j1,D,Garde,Jette],P).

% Fait jouer le meilleur coup à l'ordi

jouerJO(j2,P):-
    meilleur_coup(P,j2,C),
    write('L ordi joue le coup '),
    write(C),
    write('.\n'),
    verifCoupJO(C,P).

% Même utilité que verifCoup

verifCoupJO(C,P):-
    coupPossible(P,C),
    jouerCoup(P,C,NouveauPlateau),
    write('On passe au tour suivant.\n'),
    affichePlateau(NouveauPlateau),
    coupSuivantJO(C,NouveauPlateau).

verifCoupJO([J,_,_,_],P):-write('Coup impossible ! Redonnez votre coup!\n'),jouerJO(J,P).

% Idem que coupSuivant

coupSuivantJO([j1,_,_,_],P):-jouerJO(j2,P).
coupSuivantJO([j2,_,_,_],P):-jouerJO(j1,P).

% Idem que gagnant

gagnantJO(Score1,Score2):-Score1>Score2, write('Le joueur a gagne avec un score de '), write(Score1), write(', le score de l ordi est '), write(Score2), write(' !\n'),!.
gagnantJO(Score1,Score2):-Score1<Score2, write('L ordi a gagne avec un score de '), write(Score2),write(', le score du joueur est '), write(Score2), write(' !\n'),!.
gagnantJO(Score1,_):-write('Egalite avec un score de '), write(Score1), write(' !\n'),!.


/****************************************
DEROULEMENT D'UNE PARTIE ENTRE DEUX ORDIS
****************************************/

/*Permet de créer une partie entre deux ordi*/

ordiOrdi:-debutJeu(P),jouerO(j1,P).

% Appel de fin de partie

jouerO(_,[Marchandise,Bourse,_,J1,J2]):-
    length(Marchandise,N),
    N=<2,
    write('La partie est finie.\n'),
    score(J1,Bourse,Score1),
    score(J2,Bourse,Score2),
    gagnantO(Score1,Score2).

% Fait jouer le meilleur coup à l'ordi

jouerO(J,P):-
    affichePlateau(P),
    meilleur_coup(P,J,C),
    write('L ordi joue le coup '),
    write(C),
    write('.\n'),
    appliqueCoup(C,P).

% Applique le coup et passe au tour suivant

appliqueCoup(C,P):-
    jouerCoup(P,C,NouveauPlateau),
    write('On passe au tour suivant.\n'),
    affichePlateau(NouveauPlateau),
    coupSuivantO(C,NouveauPlateau).

% Idem que coup suivant

coupSuivantO([j1,_,_,_],P):-jouerO(j2,P).
coupSuivantO([j2,_,_,_],P):-jouerO(j1,P).

% Idem que gagant

gagnantO(Score1,Score2):-Score1>Score2, write('L ordi1 a gagne avec un score de '), write(Score1), write(', le score de l ordi2 est '), write(Score2), write(' !\n'),!.
gagnantO(Score1,Score2):-Score1<Score2, write('L ordi2 a gagne avec un score de '), write(Score2),write(', le score de l ordi1 est '), write(Score2), write(' !\n'),!.
gagnantO(Score1,_):-write('Egalite avec un score de '), write(Score1), write(' !\n'),!.


/***
MENU
***/

/*Menu de départ du jeu*/

menu:-write('Choisissez le type de partie.\n1-Joueur VS Joueur\n2-Joueur VS Ordi\n3-Ordi VS Ordi\n'), read(Choix), choixPartie(Choix).

choixPartie(1):-joueurJoueur.
choixPartie(2):-write("Qui commence?\n1-Joueur\n2-Ordi\n"),read(Choix),commence(Choix).
choixPartie(3):-ordiOrdi.
choixPartie(_):-write("Entrez invalide, veuillez recommencer !\n"), menu.

commence(1):-joueurOrdiJ.
commence(2):-joueurOrdiO.
commence(_):-write("Entrez invalide, veuillez recommencer !\n"), choixPartie(2).
