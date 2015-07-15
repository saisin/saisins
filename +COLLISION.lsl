//##########################################
//
//  CONTRO - +COLLISION
//
// ver.2.1[2015/7/15]
//##########################################

//■人やモノとぶつかると発動する。

default{
    state_entry(){}
    collision_start(integer num){
        llMessageLinked(LINK_THIS,llGetLinkNumber(),"RUN","");
    }
}