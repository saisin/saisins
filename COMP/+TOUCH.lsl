﻿//##########################################
//
//  CONTRO - +TOUCH
//
// ver.2.1[2015/7/15]
//##########################################

//■他人がタッチすると発動する。（重複防止の為、オーナーは除く）
default{
    state_entry(){}
    touch_start(integer num){
        if(llDetectedKey(0)!=llGetOwner()){
            llMessageLinked(LINK_THIS,llGetLinkNumber(),"RUN","");
        }
    }
}