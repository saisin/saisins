//##########################################
//
//  CONTRO - +TIMER
//
// ver.2.1[2015/7/15]
//##########################################

//■一定時間ごとに発動する。
float time=30;//ここを調整して下さい。


default{
    state_entry(){
        llSetTimerEvent(time);
    }
    timer(){
        llMessageLinked(LINK_THIS,llGetLinkNumber(),"RUN","");
    }
}