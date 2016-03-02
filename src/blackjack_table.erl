-module(blackjack_table).
-compile(export_all).

-include("blackjack_records.hrl").

%% contains deck
start() ->
Decks = blackjack_deck:create_decks(lists:seq(1,4), []),
{blackjack_deck:shuffle(lists:seq(1,1000), Decks),"",""}.

dealer_twist(Cards, Dealer,  Player) -> 
  Card = hd(Cards),
   UpdatedDealer = blackjack_player:update_card(Dealer, Card, Dealer#player.balance),
   
   HandValue = blackjack_player:get_hand_value(UpdatedDealer#player.cards,0),
   AltValue = blackjack_player:get_alternate_hand_value(UpdatedDealer#player.cards,0),
   
   if HandValue > 16,AltValue > 16 -> UpdatedDealer;
      HandValue < 21, HandValue >= Player#player.handValue; AltValue < 21, AltValue >= Player#player.handValue -> UpdatedDealer;
	  true -> dealer_twist(tl(Cards),UpdatedDealer,  Player)
end.

player_stand(Player) -> 

HandValue = blackjack_player:get_hand_value(Player#player.cards,0),
AltValue = blackjack_player:get_alternate_hand_value(Player#player.cards,0),
if HandValue > 21,AltValue > 21 -> 
       UpdatedPlayer = Player#player{handValue=AltValue};
   HandValue > 21 -> 
       UpdatedPlayer = Player#player{handValue=AltValue};
   AltValue > 21 -> 
       UpdatedPlayer = Player#player{handValue=HandValue};
   HandValue > AltValue -> 
       UpdatedPlayer = Player#player{handValue=HandValue};
   AltValue > HandValue -> 
       UpdatedPlayer = Player#player{handValue=AltValue};
   true -> UpdatedPlayer = Player#player{handValue=HandValue}
  end.
  
  
process_result(Player, Dealer, Cards) ->  
  if Dealer#player.handValue > 21  -> 
      {reply, io:format("You win ~p winnings~nYour Cards~p~nDealer Cards ~p~nDealer went bust~n", [Player#player.balance*2, Player#player.cards, Dealer#player.cards]), {Cards, Dealer, Player}};
     Player#player.handValue > Dealer#player.handValue -> 
	  {reply, io:format("Your Cards~p~nDealer Cards ~p~nYou win ~p winnings, Dealer has ~p~n", [Player#player.cards,Dealer#player.cards,Player#player.balance*2, Dealer#player.handValue]), {Cards, Dealer, Player}};
     Dealer#player.handValue > Player#player.handValue -> 
	  {reply, io:format("Your Cards~p~nDealer Cards ~p~nDealer wins, has ~p~n", [Player#player.cards,Dealer#player.cards,Dealer#player.handValue]), {Cards, Dealer, Player}};
	 true ->  {reply, io:format("Tie,Your Cards~p~nDealer Cards ~p~nyour stake ~p returned~n", [Player#player.cards,Dealer#player.cards, Player#player.balance]), {Cards, Dealer, Player}}
  end.




