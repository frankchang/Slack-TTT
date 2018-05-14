@RestResource(urlMapping='/move/*')
global with sharing class Move  {

    @HttpPost
    global static String move(thisGame myGame) {
        //Makes a move in the current game, if one exists.
        TicTacToeHelper ttt = new TicTacToeHelper();
        ID myMove = ttt.IsMyMove(myGame.channel, myGame.player);
        if(myMove != Null){
            //Validate if the cell to go into is a valid cell to move to
            Boolean validMove = ttt.IsValidMove(myMove, myGame.player, myGame.cell);
            if(validMove){
                String msg = ttt.GetStatusOfActiveGame(myGame.channel);
                if(ttt.IsWonGame(myMove, myGame.player )){
                    msg += '\n\n:tada:Congratulations ' + myGame.player + ' won the game!';
                } else if(ttt.IsCatzGame(myMove)){
                    msg += '\n\nIt\'s a catz Game!';
                } else{
                    msg += '\n'+ttt.GetNextPlayer(myGame.channel);
                }
                return msg;
            } else{
               return myGame.player+' - Invalid move! Please enter a valid move!'; 
            }
        } else{
            return myGame.player+' - You do not have a move to make!';
        }    
    }

    global class thisGame
    {
        global String channel;
        global String player;
        global String cell;
    }
}