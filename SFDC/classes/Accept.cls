@RestResource(urlMapping='/accept/*')
global with sharing class Accept  {

    @HttpPost
    global static String accept(activeGame currentGame) {
        //Accept an invitation to play a game
        TicTacToeHelper ttt = new TicTacToeHelper();
        List<Game__c> activeGameList = ttt.GetListOfActiveGames(currentGame.channel, '', currentGame.player);

        if(activeGameList.size() > 0){
            if(activeGameList[0].Stage__c == 'Challenged'){
                //update game record
                Boolean isGameUpdated = ttt.SetGameStage(activeGameList[0].Id, 'In Progress');
                if(isGameUpdated){
                    isGameUpdated = ttt.SetGameTurn(activeGameList[0].Id, 'Player 2');
                    if(isGameUpdated){
                        //return status
                        String board = ttt.GetStatusOfActiveGame(currentGame.channel);
                        board += '\n'+currentGame.player+', it\'s your turn!';
                        board += ' Type \"/ttt move [cell A through I]\"';
                        return board;
                    } else{
                        return '[SetGameTurn Error]: Unable to accept challenge at this time.  Please try again later.';
                    }
                } else{
                    return '[SetGameStage Error]: Unable to accept challenge at this time.  Please try again later.';
                }
            } else{
                return 'You can not accept a challenge (again) for an active game!';
            }
        } else{
            //return error
            return 'Error locating an active game!';
        }
    }
    
    //Define the input variables for this REST API
    global class activeGame
    {
        global String channel;
        global String player;
    }
}