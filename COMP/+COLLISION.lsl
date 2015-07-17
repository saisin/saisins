//####################
//
//  CONTRO - +COLLISION
//
// ver.2.0[2015/7/19]
//####################

//■アバターやオブジェクトとぶつかったら実行する

default{
    state_entry(){}
    collision_start(integer num){
        llMessageLinked(LINK_THIS,llGetLinkNumber(),"RUN","");
    }
}