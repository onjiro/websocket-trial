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
//var json = JSON.stringify;
var server = ws.createServer({server: app});
var connections = [];

server.addListener("listening", function(){
  sys.log("Listening for connections.");
});

server.addListener("connection", function(conn){
    // 接続時にコネクションにロールとidを割り振る。
    // 最初に接続した人をHOSTとする。
    // TODO id の生成を何らかのハッシュ値的なものに変更
    connections.push(conn);
    conn.send( connections.length === 1 ? 
	       JSON.stringify({role: "HOST", id:"HOST"}):
	       JSON.stringify({role: "GUEST", id:"GUEST" + (connections.length - 1)})
	     );
    sys.log('connected! number = ' + connections.length);

    conn.addListener("message", function(message){
	if (conn === connections[0]) {
	    // HOSTからのメッセージはbroadcastする。
	    server.broadcast(message);
	    sys.log(message);
	} else {
	    // GUESTからのメッセージはHOSTのみに送信
	    connections[0].send(message);
	}
    });

    conn.addListener("close", function() {
	if (connections[0] === conn) {
	    // HOSTが切断したら全員切断する。
	    sys.log('HOST has disconnected!');
	    connections[0].send(JSON.stringify({action:"close", key:"HOST"}));
	    for (var i = 1; i < connections.length; i++) {
		connections[i].close();
	    }
	    connections = [];
	} else {
	    // GUESTが切断した場合はHOSTに切断した旨を送信。
	    for (var i = 0; i < connections.length; i++) {
		if (connections[i] === conn) {
		    connections[0].send(JSON.stringify({action:"close", key:"GUEST" + i}));
		    connections.splice(i, 1);
		}
	    }
	}
	sys.log('closed! number = ' + connections.length);
    });
    
});
 
server.addListener("close", function(conn){
    sys.log('closed');
    //server.broadcast("@BYE");
});
 
server.listen(3002);