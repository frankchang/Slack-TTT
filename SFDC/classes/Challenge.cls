@RestResource(urlMapping='/challenge/*')
global with sharing class Challenge  {

    @HttpPost
    global static String create(tttGame newGame) {
        //See if an active game exists in this channel
        TicTacToeHelper bb = new TicTacToeHelper();
        Boolean activeGame = bb.ActiveGameExist(newGame.channel, '', '');
        String msg = '';
        if(activeGame){
            //If there is an active game in this channel, tell them so.
            msg = 'Active Game In Progress.... Please Try Again Later.\n';
        }else{
            //If no active game exists, create a new one using the parameters passed in
            String challengedPlayer = newGame.player2.substringBefore('|')+'>';
            Boolean startGame = bb.CreateGame(newGame.channel, newGame.player1, challengedPlayer);
            msg = 'Game On! '+challengedPlayer+ ' are you ready to play some Tic Tac Toe?\n\n';
            msg += 'Type \"/ttt Accept\" to accept '+newGame.player1+'\'s challenge!'; 
        }
            return msg;
    }

    //Define the input variables for this REST API
    global class tttGame
    {
        global String channel;
        global String player1;
        global String player2;
    }
}