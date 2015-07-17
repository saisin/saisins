//####################
//
//  CONTRO - +TOUCH
//
// ver.2.0[2015/7/19]
//####################

//■他人がタッチすると発動する。

default{
    state_entry(){}
    touch_start(integer num){
        if(llDetectedKey(0)!=llGetOwner()){// 重複防止の為、オーナーのタッチは除外
            llMessageLinked(LINK_THIS,llGetLinkNumber(),"RUN","");
        }
    }
}