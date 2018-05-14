@RestResource(urlMapping='/status/*')
global with sharing class Status  {


    @HttpPost
    global static String status(String thisChannel) {
        //Return the status of the current active game, if one exists
        TicTacToeHelper ttt = new TicTacToeHelper();
        String msg = ttt.GetStatusOfActiveGame(thisChannel);
        if(!msg.startsWith('No')){
            msg += ttt.GetNextPlayer(thisChannel);            
        }
        return msg;
    }
}