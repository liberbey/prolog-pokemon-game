% ahmet emir kocaaga
% 2017400276
% yes
% yes


:-[pokemon_data].


%find pokemon evolution(+PokemonLevel, +Pokemon, -EvolvedPokemon) -1
find_pokemon_evolution(PokemonLevel, Pokemon, EvolvedPokemon):-
  pokemon_evolution(Pokemon, FirstEvolve, Y), %look for the first possible evolution
  Y =< PokemonLevel -> find_pokemon_evolution(PokemonLevel, FirstEvolve, EvolvedPokemon); %if it can evolve more, evolve
  EvolvedPokemon = Pokemon. %else assign the current pokemon to EvolvedPokemon


%pokemon_level_stats(+PokemonLevel, ?Pokemon, -PokemonHp, -PokemonAttack, -PokemonDefense) -2
pokemon_level_stats(PokemonLevel, Pokemon, PokemonHp, PokemonAttack, PokemonDefense):-
  pokemon_stats(Pokemon, _, X, Y, Z), %find the stats of pokemon
  PokemonHp is PokemonLevel * 2 + X, %make the necessary operations
  PokemonAttack is PokemonLevel + Y,
  PokemonDefense is PokemonLevel + Z.

%single_type_multiplier(?AttackerType, ?DefenderType, ?Multiplier) -3
single_type_multiplier(AttackerType, DefenderType, Multiplier):-
  pokemon_types(PokemonTypes), %list of the all pokemon types
  type_chart_attack(AttackerType, MultiList), %list of that AttackerTypes Multipliers
  multiplier_1(AttackerType, DefenderType, Multiplier, MultiList, PokemonTypes). %recursive predicate

multiplier_1(AttackerType, DefenderType, Multiplier, [Head|MList], [H|PokeList]):-
  DefenderType == H -> %checks the head of the list and if it is the same as DefenderType, Multiplier is Head of the MultiList
  Multiplier = Head;
  multiplier_1(AttackerType, DefenderType, Multiplier, MList, PokeList). %else, check the other elements

%type_multiplier(?AttackerType, +DefenderTypeList, ?Multiplier) -4

type_multiplier(AttackerType, DefenderTypeList, Multiplier):-
  type_multiplier_1(AttackerType, DefenderTypeList, Multiplier). %recursive predicate

type_multiplier_1(_, [], Mult) :- Mult is 1.0. %for ending the recursion

  type_multiplier_1(AttackerType, [X|Deflist], Multiplier):-
    single_type_multiplier(AttackerType, X, Mul1), %find the single_type_multiplier for head of the list
    type_multiplier_1(AttackerType, Deflist, ListMultiplier), %do it again for the other elements of the DefenderTypeList
    Multiplier is Mul1*ListMultiplier. %calculate the Multiplier


%pokemon_type_multiplier(?AttackerPokemon, ?DefenderPokemon, ?Multiplier) -5

pokemon_type_multiplier(AttackerPokemon, DefenderPokemon, Multiplier):-
  pokemon_stats(AttackerPokemon, AttackList, _, _, _), %types of AttackerPokemon
  pokemon_stats(DefenderPokemon, DefendList, _, _, _), %types of DefenderPokemon
  p_mul_1(AttackList, DefendList, Multiplier). %recursive predicate

p_mul_1([], _, Multi) :- Multi is 0. %for ending recursion

p_mul_1([HA|AList], DefList, Multi):-
  type_multiplier(HA, DefList, Multi1), %find each multiplier
  p_mul_1(AList, DefList, Multi2),
  Multi is max(Multi1, Multi2). %return the maximum

%pokemon_attack(+AttackerPokemon, +AttackerPokemonLevel, +DefenderPokemon,+DefenderPokemonLevel, -Damage) -6

pokemon_attack(AttackerPokemon, AttackerPokemonLevel, DefenderPokemon,DefenderPokemonLevel, Damage):-
  pokemon_level_stats(AttackerPokemonLevel, AttackerPokemon, _, Attack, _), %attack point of the AttackerPokemon
  pokemon_level_stats(DefenderPokemonLevel, DefenderPokemon, _, _, Defend), %defend point of the DefenderPokemon
  pokemon_type_multiplier(AttackerPokemon, DefenderPokemon, Multiplier), %find the multiplier
  Damage is (0.5 * AttackerPokemonLevel *(Attack/Defend)*Multiplier) + 1. %calculate the damage

%pokemon_fight(+Pokemon1, +Pokemon1Level, +Pokemon2, +Pokemon2Level, -Pokemon1Hp, -Pokemon2Hp, -Rounds) -7

pokemon_fight(Pokemon1, Pokemon1Level, Pokemon2, Pokemon2Level, Pokemon1Hp, Pokemon2Hp, Rounds):-

  pokemon_attack(Pokemon1, Pokemon1Level, Pokemon2 ,Pokemon2Level, Damage1to2), %find the damage of first pokemon
  pokemon_attack(Pokemon2, Pokemon2Level, Pokemon1 ,Pokemon1Level, Damage2to1), %find the damage of second pokemon
  Rounds0 is 0, %inital value for the round
  pokemon_level_stats(Pokemon1Level, Pokemon1, Pokemon1Hp0, _,_), %initial value of Pokemon1Hp
  pokemon_level_stats(Pokemon2Level, Pokemon2, Pokemon2Hp0, _,_), %initial value of Pokemon2Hp
  pokemon_fight_r(Pokemon1, Pokemon1Level, Pokemon2, Pokemon2Level, Pokemon1Hp0, Pokemon2Hp0, Rounds, Rounds0, Pokemon1Hp, Pokemon2Hp, Damage1to2, Damage2to1). %recursive predicate

pokemon_fight_r(Pokemon1, Pokemon1Level, Pokemon2, Pokemon2Level, Pokemon1Hp0, Pokemon2Hp0, Rounds, Rounds0, Pokemon1Hp, Pokemon2Hp, Damage1to2, Damage2to1):-
  Pokemon1Hp0 =< 0 -> Rounds = Rounds0, Pokemon1Hp = Pokemon1Hp0, Pokemon2Hp = Pokemon2Hp0; %if any of the pokemons' hp =< 0, end fight
  Pokemon2Hp0 =< 0 -> Rounds = Rounds0, Pokemon1Hp = Pokemon1Hp0, Pokemon2Hp = Pokemon2Hp0;
  incr(Rounds0, Rounds1), %else, fight goes on, increment round, decrement the hp's of each pokemon
  decr(Pokemon1Hp0, Pokemon1Hp1, Damage2to1),
  decr(Pokemon2Hp0, Pokemon2Hp1, Damage1to2),
  pokemon_fight_r(Pokemon1, Pokemon1Level, Pokemon2, Pokemon2Level, Pokemon1Hp1, Pokemon2Hp1, Rounds, Rounds1, Pokemon1Hp, Pokemon2Hp, Damage1to2, Damage2to1). %recursive call

incr(X, X1) :- %incrementing predicate
  X1 is X+1.

decr(X, X1, Sub) :- %decrementing predicate
  X1 is X - Sub.

%pokemon_tournament(+PokemonTrainer1, +PokemonTrainer2, -WinnerTrainerList) -8

pokemon_tournament(PokemonTrainer1, PokemonTrainer2, WinnerTrainerList):-
  pokemon_trainer(PokemonTrainer1, Trainer1List, Trainer1Levels), %list of the pokemons and their levels of each trainer
  pokemon_trainer(PokemonTrainer2, Trainer2List, Trainer2Levels),
  tournament_r(PokemonTrainer1, PokemonTrainer2, Trainer1List, Trainer1Levels, Trainer2List, Trainer2Levels, [] ,WinnerTrainerList). %recursive predicate

tournament_r(PokemonTrainer1, PokemonTrainer2, [HofFirst|FirstPokes], [HofL1|Levels1], [HofSec|SecPokes], [HofL2|Levels2], WList, WinnerTrainerList):-
  find_pokemon_evolution(HofL1, HofFirst, EvolvedPokemon1), %evolve the first pokemon of each trainer
  find_pokemon_evolution(HofL2, HofSec, EvolvedPokemon2),
  pokemon_fight(EvolvedPokemon1, HofL1, EvolvedPokemon2, HofL2, Pokemon1Hp, Pokemon2Hp, _), %let them fight
  list_adder(PokemonTrainer1, PokemonTrainer2, Pokemon1Hp, Pokemon2Hp, WList, WListNew), %add the winner to the winnerlist
  tournament_r(PokemonTrainer1, PokemonTrainer2, FirstPokes, Levels1, SecPokes, Levels2, WListNew, WinnerTrainerList). %recursive call

tournament_r(_, _, [], [], [], [], WList, WList). %end of recursion


list_adder(PokemonTrainer1, PokemonTrainer2, Pokemon1Hp, Pokemon2Hp, WList, WListNew):- %adds the winner trainer to the winner trainer list
  Pokemon2Hp =< Pokemon1Hp -> append(WList,[PokemonTrainer1], WListNew);
  append(WList,[PokemonTrainer2], WListNew).

%best_pokemon(+EnemyPokemon, +LevelCap, -RemainingHP, -BestPokemon) -9

best_pokemon(EnemyPokemon, LevelCap, RemainingHP, BestPokemon):-
  findall(Pokemon, pokemon_stats(Pokemon,_,_,_,_), PokeList), %list of all pokemons
  best_p_r(EnemyPokemon, LevelCap, RemainingHP, BestPokemon, PokeList, _, -1000.0, _). %recursive predicate

best_p_r(EnemyPokemon, LevelCap, RemainingHP, BestPokemon, [H|RestList], ThisRemain, MaxRemain, MaxPoke):-
  pokemon_fight(EnemyPokemon, LevelCap, H, LevelCap, _, ThisRemain, _), %take the head of the pokemon list and make a fight with enemy pokemon
  ThisRemain > MaxRemain -> MaxRemain1 = ThisRemain, %if it is better then the max pokemon, make it he new max
  MaxPoke1 = H,
  best_p_r(EnemyPokemon, LevelCap, RemainingHP, BestPokemon, RestList, _, MaxRemain1, MaxPoke1); %recursion with new maxes
  best_p_r(EnemyPokemon, LevelCap, RemainingHP, BestPokemon, RestList, _, MaxRemain, MaxPoke). %recursion with old maxes

best_p_r(_, _, RemainingHP, BestPokemon, [], _, MaxRemain, MaxPoke):- %last part of recursion that returns the remaining hp and best pokemon
  RemainingHP is MaxRemain,
  BestPokemon = MaxPoke.


%best_pokemon_team(+OpponentTrainer, -PokemonTeam) -10

best_pokemon_team(OpponentTrainer, PokemonTeam):-
  pokemon_trainer(OpponentTrainer, PokeList, LevelList), %find the pokemon list and their levels of the OpponentTrainer
  best_p_t_r(PokeList, LevelList, _, PokemonTeam). %recursive predicate

best_p_t_r([HPoke|RestPoke],[HLev|RestLev], MyTeam, PokemonTeam):-
  best_pokemon(HPoke, HLev, _, BestPokemon), %find the best pokemon against the head of the list
  append(MyTeam, [BestPokemon], NMyTeam), %append it to my team
  (best_p_t_r(RestPoke, RestLev, NMyTeam, PokemonTeam),!). %recursive call

best_p_t_r([], [], NMyTeam, PokemonTeam):- %end of recursion, returns pokemon team
  (PokemonTeam = NMyTeam, !).


%pokemon_types(+TypeList, +InitialPokemonList, -PokemonList) -11

pokemon_types(TypeList, InitialPokemonList, PokemonList):-
  findall(Pokemon, (member(Pokemon, InitialPokemonList), pokemon_types_2(TypeList, Pokemon)), PokemonList). %finds all the pokemons that is member of InitialPokemonList and has one of the desired TypeList

pokemon_types_2([H|TypeListTail], Pokemon):- %finds out if the pokemon has a type that is in the TypeList
  pokemon_stats(Pokemon, PokemonTypeList,_,_,_),
  ((member(H, PokemonTypeList), !); pokemon_types_2(TypeListTail, Pokemon)). %if not found, recursive call

%generate_pokemon_team(+LikedTypes, +DislikedTypes, +Criterion, +Count, -PokemonTeam) -12

generate_pokemon_team(LikedTypes, DislikedTypes, Criterion, Count, PokemonTeam):-
  findall(Pokemon, pokemon_stats(Pokemon, _, _, _, _), Pokes), %list of all pokemons
  pokemon_types(LikedTypes, Pokes, LikeList), %list of liked types
  pokemon_types(DislikedTypes, Pokes, DislikeList), %list of disliked types
  findall([Pokemon, HP, Attack, Defense], (pokemon_stats(Pokemon, _, HP, Attack, Defense),member(Pokemon, LikeList), \+member(Pokemon, DislikeList)), PokeList), %finds all pokemons that is member of LikeList and not member of DislikeList
  lastSort(Criterion, PokeList, PokemonTeam1, Count), %sorts and cuts the list with given criterion and count
  PokemonTeam = PokemonTeam1. %assign the pokemon team

lastSort(Criterion, PokeList, PokemonTeam1, Count):- %first, predsort the list according to given criterion, then takes the first count elements of list with findall and nth1, then returns
  Criterion = 'a' -> predsort(criteriaA, PokeList, NewList),
  findall([Pokemon, HP, Attack, Defense], (nth1(I,NewList,[Pokemon, HP, Attack, Defense]), I =< Count, member([Pokemon, HP, Attack, Defense], NewList)), LastList),
  PokemonTeam1 = LastList;
  Criterion = 'h' -> predsort(criteriaH, PokeList, NewList),
  findall([Pokemon, HP, Attack, Defense], (nth1(I,NewList,[Pokemon, HP, Attack, Defense]), I =< Count, member([Pokemon, HP, Attack, Defense], NewList)), LastList),
  PokemonTeam1 = LastList;
  Criterion = 'd' -> predsort(criteriaD, PokeList, NewList),
  findall([Pokemon, HP, Attack, Defense], (nth1(I,NewList,[Pokemon, HP, Attack, Defense]), I =< Count, member([Pokemon, HP, Attack, Defense], NewList)), LastList),
  PokemonTeam1 = LastList.


%criterias for predsort, sort the list of lists in descending order of their 3rd elements, if two elements are equal, dont change the order
%taken the predsort+criteria idea from stackoverflow
criteriaA(R,[_,_,A1,_],[_,_,A2,_]) :-
  A1=\=A2, !, compare(R,A2,A1).
criteriaA(R,E1,E2) :-
  compare(R,E1,E2).

%criterias for predsort, sort the list of lists in descending order of their 2nd elements, if two elements are equal, dont change the order
criteriaH(R,[_,H1,_,_],[_,H2,_,_]) :-
  H1=\=H2, !, compare(R,H2,H1).
criteriaH(R,E1,E2) :-
  compare(R,E1,E2).

%criterias for predsort, sort the list of lists in descending order of their 4th elements, if two elements are equal, dont change the order
criteriaD(R,[_,_,_,D1],[_,_,_,D2]) :-
  D1=\=D2, !, compare(R,D2,D1).
criteriaD(R,E1,E2) :-
  compare(R,E1,E2).
