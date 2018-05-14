'use strict';
const request = require('request-promise');
const https = require('https');
const AWS = require('aws-sdk');

module.exports.hello = (event, context, callback) => {

  //Only parse post method with data in body of post method.
  if(event.httpMethod == 'POST' && event.body){

    var responseURL = '';
    var apiTextCommand = '';
    var player1 = '';
    var player2 = '';
    var channelId = '';
    var channelName = '';
    var cell = '';
    var slackVars = (event.body).split('&');
    var keyArray = [];
    var valueArray = [];
    //Get all the variables passed in from Slack to API.
    for (var i = 0; i < slackVars.length; i++) {
      var pair = slackVars[i].split('=');
      keyArray[i] = decodeURIComponent(pair[0]);
      valueArray[i] = decodeURIComponent(pair[1]);
      //For now, we're only interested in the following data fields...
      switch(pair[0]) {
        case 'user_id':
          player1 = '<@'+decodeURIComponent(pair[1])+'>';
          break;
        case 'channel_id':
          channelId = '<#'+decodeURIComponent(pair[1])+'>';
          break;
        case 'channel_name':
          channelName = decodeURIComponent(pair[1]);
          break;
        case 'text':
        //Further break out the fields if the field is "text".
          var slackCommand = pair[1].split('+');
          apiTextCommand = decodeURIComponent(slackCommand[0]).toLowerCase();
          if(apiTextCommand == 'challenge'){
            /*If the first parameter is "challenge", then the second parameter
             must be the player to be challenged.*/
            player2 = decodeURIComponent(slackCommand[1]);
          } else if (apiTextCommand.toLowerCase() == 'move'){
            /*If the first parameter is "move", then the second parameter 
            must be the cell to move to.*/
            cell = decodeURIComponent(slackCommand[1]);
          } else{
            //do nothing
          }
          break;
        case 'response_url':
          responseURL = decodeURIComponent(pair[1]);
          break;
        default:
            //do nothing
      }
    }

    //Building the OAuth call to retrieve authorization token.
    var respondJson;
    var sfdcURL;
    var tokenRequestString = {
      "grant_type": "password",
      "client_id": "[ENTER THE CLIENT ID OF YOUR SFDC CONNECTED APP]",
      "client_secret": "[ENTER THE CLIENT SECRET OF YOUR SFDC CONNECTED APP]",
      "username": "[ENTER THE USERNAME OF YOUR SFDC USER]",
      "password": "[ENTER THE PASSWORD + SECURITY TOKEN OF YOUR SFDC USER]"
    }
    //Setting the parameters of the OAuth call.
    var tokenRequestOption = {
      method: 'POST',
      uri: 'https://frank-chang-splx201-dev-ed.my.salesforce.com/services/oauth2/token',
      form: tokenRequestString
    }   
    //Making the OAuth call to Salesforce. 
    request(tokenRequestOption)
    .then(function(response){
      var respondJson = JSON.parse(response);
      var gameplay = '';
      var sfdcRequest = '';
    
    /*Once we've completed the OAuth call, we need to determine which SFDC API to call, 
    and determine what values to pass to it.*/
      switch(apiTextCommand) {
        case 'accept':
            sfdcURL = 'https://frank-chang-splx201-dev-ed.my.salesforce.com/services/apexrest/accept';
            gameplay = {
              "channel" : channelId,
              "player" : player1
            }
            sfdcRequest = {
              "currentGame" : gameplay
            }
            break;
        case 'cancel':
            sfdcURL = 'https://frank-chang-splx201-dev-ed.my.salesforce.com/services/apexrest/cancel';
            gameplay = {
              "channel" : channelId,
              "player" : player1
            }
            sfdcRequest = {
              "currentGame" : gameplay
            }
            break;
         case 'challenge':
            sfdcURL = 'https://frank-chang-splx201-dev-ed.my.salesforce.com/services/apexrest/challenge';
            gameplay = {
              "channel" : channelId,
              "player1" : player1,
              "player2" : player2
            }
            sfdcRequest = {
              "newGame" : gameplay
            }
            break;
        case 'move':
            sfdcURL = 'https://frank-chang-splx201-dev-ed.my.salesforce.com/services/apexrest/move';
            gameplay = {
              "channel" : channelId,
              "player" : player1,
              "cell" : cell
            }
            sfdcRequest = {
              "myGame" : gameplay
            }
            break;
        case 'status':
            sfdcURL = 'https://frank-chang-splx201-dev-ed.my.salesforce.com/services/apexrest/status';
            sfdcRequest = {
              "thisChannel" : channelId
            }
            break;
        default:
            //do nothing
      }
      /*Set the parameters of the Salesforce API call, with the auth token from our previous 
      OAuth call.*/
      var myJSONRequest = JSON.stringify(sfdcRequest);
      var options = {
        method: 'POST',
        uri: sfdcURL,
        body: myJSONRequest,
        headers: {
          'Authorization': respondJson.token_type + ' ' + respondJson.access_token,
          'Content-Type': 'application/json'
        },
        JSON: true
      }
      //Make the Salesforce API call.
      request(options)
      .then(function(response2){
        //Perform some character replacements and clean up.
        var bodystr = {
          "response_type": "in_channel",
          "text": response2.replace(/(\\r)|(\\n)/g,"\n").replace(/(\")/g, "").replace(/(\\)/g, "\"").replace(/null/g, " - ")
        }
        //Builds the response for Slack.
        var options = {
          method: 'POST',
          uri: responseURL,
          body: JSON.stringify(bodystr)
        }
        //Sends the cleaned response from Salesforce to Slack.        
        request(options)
        .then(function(response){
    
          callback(null, JSON.parse(response));
    
        })
        .catch(function(err){
          console.log('Loading1 Params failure: ' + err);
          callback(null, response);
        })
      })
      .catch(function(err){
        console.log('Loading2 Params failure: ' + err);
          callback(null, err);
      })
    })
    .catch(function(err){
      console.log('Loading1 Params failure: ' + err);
        callback(null, response);
    })

    //Send reply back to Slack to let it know we've received the post.
    return callback( null, {
      statusCode: 200
    })
    /*
    //For debugging purposes
    return callback( null, {
      statusCode: 200,
      body: JSON.stringify({
        message: 'Go Serverless v1.0! Your function executed successfully!',
        apiTextCommand: '==> '+apiTextCommand,
        player1: '==> '+player1,
        player2: '==> '+player2,
        channelId: '==> '+channelId,
        cell: '==> '+cell,
        responseURL: '==> '+responseURL
      }),
    }) 
    */
  }
};
