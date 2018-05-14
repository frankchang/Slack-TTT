# Slack-TTT
This project is for building the game of tic tac toe into Slack.  

For the project, I've decided to use Salesforce as the game processor and data store.  The Salesforce classes and metadata files are kept in the SFDC folder.  The "classes" folder contains all REST API logic classes as well as a TicTacToeHelper class.  The "object" folder contains the object metadata for the Salesforce object that houses the tic tac toe game data.

I'm also using AWS API Gateway with Lambda (Node.js) to handle requests between Slack and Salesforce.  The AWS "Serverless" folder contains the handler.js javascript logic file that controls how the calls received from Slack is processed and sent to Salesforce; and how responses from Salesforce is processed and sent back to Slack.  I did not include all of the libraries (node_modules) specified in the package.json file because they were too many to upload and they're pretty easy to get on your own.
