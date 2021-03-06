﻿//  ver.2.1[2015/7/15]

integer COMMON_CHANNEL=1357246809;
string chnlname;
string MSG_HOWTO="任意の基準点に設置してください。次にMOBILE_BASEを長押ししてPosMemory/PosLoadを行ってください。";

default
{
    state_entry(){
        llOwnerSay(MSG_HOWTO);
        if((llGetObjectDesc()=="")||(llGetObjectDesc()=="(No Description)")){
            if(llGetLinkPrimitiveParams(2,[PRIM_DESC])!=[""]){
                llSetObjectDesc(llList2String(llGetLinkPrimitiveParams(2,[PRIM_DESC]),0));
            }else{
                llSetObjectDesc("OWNER");
            }
        }
        chnlname=llGetObjectDesc();
        llListen(COMMON_CHANNEL+1,"","","");
    }
    touch_start(integer num){
        llOwnerSay(MSG_HOWTO);
    }
    listen(integer chnl,string name,key id,string msg){
        list tmplist=llCSV2List(msg);
        chnlname=llList2String(tmplist,0);
        if(chnlname!=llGetObjectDesc()){
            return;
        }
        if(llList2String(tmplist,1)!="GET_FLAGINFO"){
            if(llList2String(tmplist,1)=="FLAG_INFO"){
                llOwnerSay("×エラー：FrogFlagが重複しています。POS_MEMORY,POS_LOADをやり直してください。"+(string)llGetPos());
            }
            return;
        }
        llShout(COMMON_CHANNEL+1,chnlname+",FLAG_INFO,"+(string)llGetPos()+","+(string)llGetRot());
    }
    on_rez(integer num){
        llOwnerSay(MSG_HOWTO);
        vector boundingbox=(vector)llList2String(llGetBoundingBox(llGetKey()),0);
        llSetPos(llGetPos()+<0,0,boundingbox.z>);
    }
}
