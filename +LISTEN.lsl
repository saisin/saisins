//####################
//
//  CONTRO - +LISTEN
//
// ver.2.0[2015/7/19]
//####################

//■指定チャンネルで、指定コマンドをリッスンしたら実行する

integer LISTEN_CHANNEL=0;  //リッスンするチャンネル。(ローカルチャットなら0)
string RUN_COMMAND="スタート"; //この言葉をリッスンしたら実行する

//-----------------------------------------------
default{
    state_entry(){
        llListen(LISTEN_CHANNEL,"","",RUN_COMMAND);
    }
    listen(integer chnl,string name,key id,string msg){
		llMessageLinked(LINK_THIS,llGetLinkNumber(),"RUN","");
    }
}