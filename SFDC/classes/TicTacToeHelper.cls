public class TicTacToeHelper {

    /*This function returns True if it find the current channel's active game.
    It returns False if no active game is found.*/
    Public Boolean ActiveGameExist(String channel, String player1, String player2){
        List<Game__c> currentGame = new List<Game__c>();
        currentGame = GetListOfActiveGames(channel, player1, player2);

        if(currentGame.size() > 0){
            return True;
        }else{
            return False;
        }
    }

    /*This function builds a query to retrieve all active games for a given channel.
    The constraint is that there should only be one active game per channel, so the 
    returned list should only have zero or one record only*/
    Public List<Game__c> GetListOfActiveGames(String channel, String player1, String player2){
        List<Game__c> currentGame = new List<Game__c>();
        String query = 'SELECT Channel__c, Player1__c, Player2__c, Stage__c FROM Game__c WHERE Channel__C = :channel ';

        if(player1 != '' && player2 != ''){
            //If the channel and both players are passed in, do this...
            query += 'AND Player1__c = :player1 AND Player2__c = :player2 ';
        } else if (player1 != '' && player2 == ''){
            //If the channel and player1 are passed in, do the following...
            query += 'AND (Player1__c = :player1) ';
        } else if (player1 == '' && player2 != ''){
            //If the channel and player2 are passed in, do the following...
            query += 'AND (Player2__c = :player2) ';
        } else {
            //If Just the channel is passed in, do nothing else
        }
        query += 'AND (Stage__c = \'Challenged\' OR Stage__c = \'In Progress\')';
        system.debug('Query statement ==> ' + query);
        currentGame = database.query(query);
        return currentGame;
    }

    /*This function creates a new tictactoe game.*/
    Public Boolean CreateGame(String channel, String player1, String player2){
        Game__c currentGame = new Game__c();
        currentGame.Channel__c = channel;
        currentGame.Player1__c = player1;
        currentGame.Player2__c = player2;
        currentGame.Stage__c = 'Challenged';
        currentGame.A__c = ' ';
        currentGame.B__c = ' ';
        currentGame.C__c = ' ';
        currentGame.D__c = ' ';
        currentGame.E__c = ' ';
        currentGame.F__c = ' ';
        currentGame.G__c = ' ';
        currentGame.H__c = ' ';
        currentGame.I__c = ' ';
        insert currentGame;

        if(currentGame.ID != NULL){
            return True;
        }else{
            return False;
        }
    }

    /*This function draws the tictactoe board in it's most current state.*/
    Public String GetStatusOfActiveGame(String channel){
        List<Game__c> currentGame = [SELECT A__c, B__c, C__c, D__c, E__c, F__c, G__c, H__c, I__c, 
            Channel__c, Next__c, Player1__c, Player2__c, Stage__c FROM Game__c
        WHERE Channel__C = :channel AND (Stage__c = 'Challenged' OR Stage__c = 'In Progress') LIMIT 1];

        if(currentGame.size() > 0){
            String tttBoard = '| ' + currentGame[0].A__c + ' | ' + currentGame[0].B__c + ' | ' + currentGame[0].C__c + ' |' + '\n|---+---+---|\n' +
                              '| ' + currentGame[0].D__c + ' | ' + currentGame[0].E__c + ' | ' + currentGame[0].F__c + ' |' + '\n|---+---+---|\n' + 
                              '| ' + currentGame[0].G__c + ' | ' + currentGame[0].H__c + ' | ' + currentGame[0].I__c + ' |' + '\n';              
            //return tttBoard.replace('x', ':apple:').replace('o', ':tangerine:');
            return tttBoard;
        }else{
            return 'No current active game for this channel: ' + channel;
        }
    }

    /*This function returns the text message for the next player.*/
    Public String GetNextPlayer(String channel){
        String outPut = '';
        List<Game__c> currentGame = [SELECT A__c, B__c, C__c, D__c, E__c, F__c, G__c, H__c, I__c, 
            Channel__c, Next__c, Player1__c, Player2__c, Stage__c FROM Game__c
        WHERE Channel__C = :channel AND (Stage__c = 'Challenged' OR Stage__c = 'In Progress') LIMIT 1];

        if(currentGame.size() > 0){
            if(currentGame[0].Next__c == 'Player 1'){
                outPut = currentGame[0].Player1__c + ' - Your turn to make the next move!';
            }else{
                outPut = currentGame[0].Player2__c + ' - Your turn to make the next move!';
            }
        } else{
            outPut = '';
        }
        outPut += ' Type \"/ttt move [cell A through I]\"';
        return outPut;
    }

    /*This function cancels the current active game, if one exists.*/
    Public String CancelActiveGame(String channel, String player){
        Id activeGameID = FindActiveGame(channel, player);

        if(activeGameID != NULL){
            Game__c toDelete = new Game__c(Id = activeGameID);
            try {
                Delete toDelete;
                return 'Current Game has been Cancelled!';
            } catch (DmlException e) {
                System.debug('Delete error message ==> '+ e.getMessage());
                return e.getMessage();
            }
        } else {
            return 'Unable to find an active game to cancel!';
        }
    }

    /*This function finds and returns the current game's ID, if it exists...*/
    Public ID FindActiveGame(String channel, String player){
        List<Game__c> currentGame = new List<Game__c>();
        String query = 'SELECT Channel__c, Player1__c, Player2__c, Stage__c FROM Game__c WHERE Channel__C = :channel ';

        if(player != ''){

            query += 'AND (Player1__c = :player OR Player2__c = :player) ';
        }
        query += 'AND (Stage__c = \'Challenged\' OR Stage__c = \'In Progress\') LIMIT 1 ';
        system.debug('Query statement ==> ' + query);
        currentGame = database.query(query);
  
        if(currentGame.size() > 0){
            return currentGame[0].Id;
        } else{
            return NULL;
        }    
    }    

    /*This boolean function sets the current game's stage field to the 
    status passed in.*/
    Public Boolean SetGameStage(Id gameId, String gameStatus){
        Game__c thisGame = GetGameRecordFromId(gameId);

        if(thisGame != NULL){
            thisGame.Stage__c = gameStatus;
            Update thisGame;
            return True;
        } else{
            return False;
        }
    }

    /*This boolean function sets the game to the next player.*/
    Public Boolean SetGameTurn(Id gameId, String nextPlayer){
        Game__c thisGame = GetGameRecordFromId(gameId);

        if(thisGame != NULL){
            if(nextPlayer == 'Player 1'){
                thisGame.Next__c = 'Player 1';
            } else {
                thisGame.Next__c = 'Player 2';
            }
            Update thisGame;
            return True;
        } else{
            return False;
        }        
    }

    /*This function checks to see if the player is next to make a move.  If so,
    the game record Id is returned.*/
    Public Id IsMyMove(String channel, String player){
        List<Game__c> currentGameList = [SELECT Channel__c, Player1__c, Player2__c, Stage__c, Next__c 
                FROM Game__c WHERE Channel__c = :channel AND (Stage__c = 'In Progress' OR Stage__c = 'Challenged') LIMIT 1];
        system.debug('Function IsMyMove - currentGameList: '+currentGameList);

        if(currentGameList.size() == 1){
            Game__c thisGame = currentGameList[0];
            if(thisGame.Next__c == 'Player 1'){
                if(thisGame.Player1__c == player){
                    return thisGame.Id;
                } else {
                    return NULL;
                }
            } else{
                if(thisGame.Player2__c == player){
                    return thisGame.Id;
                } else {
                    return Null;
                }
            }
        } else {
            return Null;
        }
    }

    /*This boolean function returns True if the intended move is a valid move.  If
    so, the move is made with the player's marker, update the next person to move 
    and saves the Game record.*/
    Public Boolean IsValidMove(Id myGame, String player, String cell){
        Game__c currentGame = GetGameRecordFromId(myGame);

        if(currentGame.Id != NULL){
            //If an active game record is found
            //Sets the marker for the current player.
            String marker = '';
            String nextPlayer = '';
            if(currentGame.Next__c == 'Player 1'){
                marker = 'x';
                nextPlayer = 'Player 2';
            } else{
                marker = 'o';
                nextPlayer = 'Player 1';
            }
            if(IsCellOccupied(currentGame, cell)){
                //If the cell is currently occupied
                return False;
            } else{
                //If the cell is not in use
                SetCellAndUpdateNextPlayer(currentGame, cell, marker, nextPlayer);
                return True;
            }
        } else{
            return False;
        }
    }

    /*This function will check to see if the given cell is currently occupied with
    a marker.*/
    Public Boolean IsCellOccupied(Game__c thisGame, String cell){

        if(cell == 'A' || cell == 'a'){
            if(thisGame.A__c == Null || thisGame.A__c == ''){
                return False;
            } else{
                return True;
            }
        } else if(cell == 'B' || cell == 'b'){
            if(thisGame.B__c == Null || thisGame.B__c == ''){
                return False;
            } else{
                return True;
            }
        } else if(cell == 'C' || cell == 'c'){    
            if(thisGame.C__c == Null || thisGame.C__c == ''){
                return False;
            } else{
                return True;
            }
        } else if(cell == 'D' || cell == 'd'){
            if(thisGame.D__c == Null || thisGame.D__c == ''){
                return False;
            } else{
                return True;
            }
        } else if(cell == 'E' || cell == 'e'){    
            if(thisGame.E__c == Null || thisGame.E__c == ''){
                return False;
            } else{
                return True;
            }
        } else if(cell == 'F' || cell == 'f'){
            if(thisGame.F__c == Null || thisGame.F__c == ''){
                return False;
            } else{
                return True;
            }
        } else if(cell == 'G' || cell == 'g'){    
            if(thisGame.G__c == Null || thisGame.G__c == ''){
                return False;
            } else{
                return True;
            }
        } else if(cell == 'H' || cell == 'h'){
            if(thisGame.H__c == Null || thisGame.H__c == ''){
                return False;
            } else{
                return True;
            }
        } else if(cell == 'I' || cell == 'i'){   
            if(thisGame.I__c == Null || thisGame.I__c == ''){
                return False;
            } else{
                return True;
            } 
        } else {
            return True;
        }  
    }  

    /*This function updates the cell with the player's marker, and at the same time,
    will also update the next player field in the Game record*/
    Public Void SetCellAndUpdateNextPlayer(Game__c thisGame, String cell, String charToUse, String nextPlayer){

        if(cell == 'A' || cell == 'a'){
            thisGame.A__c = charToUse;
        } else if(cell == 'B' || cell == 'b'){
            thisGame.B__c = charToUse;
        } else if(cell == 'C' || cell == 'c'){    
            thisGame.C__c = charToUse;
        } else if(cell == 'D' || cell == 'd'){
            thisGame.D__c = charToUse;
        } else if(cell == 'E' || cell == 'e'){    
            thisGame.E__c = charToUse;
        } else if(cell == 'F' || cell == 'f'){
            thisGame.F__c = charToUse;
        } else if(cell == 'G' || cell == 'g'){    
            thisGame.G__c = charToUse;
        } else if(cell == 'H' || cell == 'h'){
            thisGame.H__c = charToUse;
        } else{
            thisGame.I__c = charToUse;
        }   
        thisGame.Next__c = nextPlayer;
        Update thisGame;
    }

    /*This function returns True if the game was won on the last move. Then, sets the 
    Stage field of the current game record to the winner.*/
    Public Boolean IsWonGame(Id gameId, String currentPlayer){
        //Tests Horizontal, Vertical, and Diagonal
        Game__c thisGame = GetGameRecordFromId(gameId);
        Boolean winGame = False;

        //Test Row1 for win
        if(IsThreeInARow(thisGame.A__c, thisGame.B__c, thisGame.C__c)){
            winGame = True;
        }
        //Test Row2 for win
        if(IsThreeInARow(thisGame.D__c, thisGame.E__c, thisGame.F__c)){
            winGame = True;
        }
        //Test Row3 for win
        if(IsThreeInARow(thisGame.G__c, thisGame.H__c, thisGame.I__c)){
            winGame = True;
        }
        //Test Col1 for win
        if(IsThreeInARow(thisGame.A__c, thisGame.D__c, thisGame.G__c)){
            winGame = True;
        }
        //Test Col2 for win
        if(IsThreeInARow(thisGame.B__c, thisGame.E__c, thisGame.H__c)){
            winGame = True;
        }
        //Test Col3 for win
        if(IsThreeInARow(thisGame.C__c, thisGame.F__c, thisGame.I__c)){
            winGame = True;
        }
        //Test Diagonal1 for win
        if(IsThreeInARow(thisGame.A__c, thisGame.E__c, thisGame.I__c)){
            winGame = True;
        }
        //Test Diagonal2 for win
        if(IsThreeInARow(thisGame.C__c, thisGame.E__c, thisGame.G__c)){
            winGame = True;
        }
        if(winGame){
            if(thisGame.Player1__c == currentPlayer){
                thisGame.Stage__c = 'Player 1 Won';
            } else{
                thisGame.Stage__c = 'Player 2 Won';                
            }
            Update thisGame;
        }
        return winGame;
    }

    /*This function checks if the three inputs are the same value*/
    Public Boolean IsThreeInARow(String cell1, String cell2, String cell3){

        if((cell1 == cell2) && (cell2 == cell3) && (cell1 != NULL) && (cell2 != NULL) && (cell3 != NULL)) {
            return True;
        } else{
            return False;
        }
    }

    /*This function checks to see if all the cells are filled and if so, is it a catz game*/
    Public Boolean IsCatzGame(Id gameId){
    //Check to see if all cells are filled.
        Game__c thisGame = GetGameRecordFromId(gameId);
        Boolean isFull = True;

        if(thisGame.A__c == Null || thisGame.A__c == ''){
            isFull = False;
        } else if(thisGame.B__c == Null || thisGame.B__c == ''){
            isFull = False;
        } else if(thisGame.C__c == Null || thisGame.C__c == ''){
            isFull = False;
        } else if(thisGame.D__c == Null || thisGame.D__c == ''){
            isFull = False;
        } else if(thisGame.E__c == Null || thisGame.E__c == ''){
            isFull = False;
        } else if(thisGame.F__c == Null || thisGame.F__c == ''){
            isFull = False;
        } else if(thisGame.G__c == Null || thisGame.G__c == ''){
            isFull = False;
        } else if(thisGame.H__c == Null || thisGame.H__c == ''){
            isFull = False;
        } else if(thisGame.I__c == Null || thisGame.I__c == ''){
            isFull = False;
        } else{
            //Do Nothing
        }
        //If so, set the game to completed
        if(isFull){
            Boolean setGametoDraw = SetGameStage(gameId, 'Draw');
        }
        return isFull;
    }

    /*This function returns the game record, including all the fields using the record id.*/
    Public Game__c GetGameRecordFromId(Id gameId){
        List<Game__c> thisGame = [SELECT Channel__c, Player1__c, Player2__c, Stage__c, Next__c,
            A__c, B__c, C__c, D__c, E__c, F__c, G__c, H__c, I__c 
            FROM Game__c WHERE Id = :gameId];

        if(thisGame.size() > 0 ){
            return thisGame[0];
        } else{
            return NULL;            
        }
    }

    Public String encodeJsonString(String fieldName, String fieldValue){
        String holder = '';
        
        if(fieldValue == NULL || fieldValue == ''){
            holder = '""';
        } else{
            holder = fieldValue;
        }
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeStringField(fieldName, holder);
        gen.writeEndObject();
        return gen.getAsString();
    }
}