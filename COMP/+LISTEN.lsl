//##########################################
//
//  CONTRO - +LISTEN
//
// ver.2.1[2015/7/15]
//##########################################

//■リッスンで発動する。
integer LISTEN_CHANNEL=0;
string RUN_COMMAND="スタート";


default{
    state_entry(){
        llListen(LISTEN_CHANNEL,"","","");
    }
    listen(integer chnl,string name,key id,string msg){
        if(msg==RUN_COMMAND){
            llMessageLinked(LINK_THIS,llGetLinkNumber(),"RUN","");
        }
    }
}