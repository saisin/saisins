﻿//####################
//
//  CONTRO - +TIMER
//
// ver.2.0[2015/7/19]
//####################

//■一定時間ごとに実行する

//※タイマーはSIMに負荷をかけやすいので、必要最小限の利用をお願いします。
//常設オブジェクトの場合は５秒以上の秒数をセットするようにしてください。　


float timer_second=30.0;　//この秒数おきに実行する

default{
    state_entry(){
        llSetTimerEvent(timer_second);
    }
    timer(){
        llMessageLinked(LINK_THIS,llGetLinkNumber(),"RUN","");
    }
}