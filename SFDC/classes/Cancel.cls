@RestResource(urlMapping='/cancel/*')
global with sharing class Cancel  {

    @HttpPost
    global static String cancel(activeGame currentGame) {
        //See if an active game exists in this channel
        TicTacToeHelper bb = new TicTacToeHelper();
        String activeGameCancelled = bb.CancelActiveGame(currentGame.channel, currentGame.player);
        return activeGameCancelled;
    }

    //Define the input variables for this REST API
    global class activeGame
    {
        global String channel;
        global String player;
    }
}