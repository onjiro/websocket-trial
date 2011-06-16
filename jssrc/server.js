var sys = require("sys"),
    ws  = require('websocket-server');
 
/**
 * web-server
 */
var express = require('express');
var app = express.createServer();
app.configure(function(){
});
 
/**
 * websocket-server
 */
var json = JSON.stringify;
var server = ws.createServer({server: app});
 
server.addListener("listening", function(){
  sys.log("Listening for connections.");
});
 
server.addListener("connection", function(conn){
    
    sys.log('Hello');
    server.broadcast("@HELLO");
 
    conn.addListener("message", function(message){
//	server.broadcast(message);
	conn.send(message);
    });
    
});
 
server.addListener("close", function(conn){
    //server.broadcast("@BYE");
});
 
server.listen(3002);