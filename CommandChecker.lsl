//##########################################
//
//  CONTRO - #CommandChecker
//
//  ver.2.11[2015/7/15]
//##########################################

integer power=FALSE;
integer COMMON_CHANNEL=1357246809;
integer INT_SET_QUEUE=156783;
integer INT_PARTICLE=1978532;
integer lsnnum;
list search_object_list;
list command_list;
list controller_key_list;
integer checkercnt=0;
//==========================================================
Error(){
    llSetColor(<1,.5,1>,ALL_SIDES);
    llSetTimerEvent(6);
}
//==========================================================

default{
state_entry(){
    llSetColor(<.4,.4,.4>,ALL_SIDES);
    llSetLinkTexture(2,TEXTURE_BLANK,ALL_SIDES);    
}
on_rez(integer num){
    llResetScript(); 
}
touch_start(integer num){
    if(llDetectedKey(0)!=llGetOwner()){return;}
    if(power){
        llSay(0,"コマンドチェックOFF");
        llListenRemove(lsnnum);
        llSetColor(<.4,.4,.4>,ALL_SIDES);
        llSetLinkTexture(2,TEXTURE_BLANK,ALL_SIDES);
    }else{
        llSay(0,"コマンドチェックON");
        lsnnum=llListen(COMMON_CHANNEL,"","","");
        llSetColor(<0,.3,.9>,ALL_SIDES);
        llSetLinkTexture(2,"ee69eba9-6e0f-af6f-2931-fa821fdb9ad5",ALL_SIDES);
    }
    power=!power;
}
listen(integer chnl,string name,key id,string msg){
    if(llGetOwnerKey(id)!=llGetOwner()){return;}
    //HTTP経由で構文チェック

    llMessageLinked(LINK_THIS,INT_SET_QUEUE+1,msg,id);
    //llMessageLinked(LINK_THIS,INT_SET_QUEUE+checkercnt+1,msg,id);
    //checkercnt=(checkercnt+1)%5;

    //センサーチェック
    list tmplist=llParseString2List(msg,["\n"],[]);//A/objname,MOVE,<xyz>,<xyz>
    integer i;
    for(i=1;i<llGetListLength(tmplist);i++){
        list tmplist2=llParseStringKeepNulls(llList2String(tmplist,i),[","],[]);//objname,MOVE,<xyz>,<xyz>
        if(llList2String(tmplist2,1)!="REZ"){
            if(llList2String(tmplist2,1)!="DEL"){
                search_object_list+=llList2String(tmplist2,0);    //オブジェクトの名前
                command_list+=llList2List(tmplist,i,i);
                controller_key_list+=[id];
            }
        }else{
            llSleep(0.3);
        }
    }
    if(search_object_list!=[]){
        llSensor(llList2String(search_object_list,0),"",ACTIVE|PASSIVE|SCRIPTED,96,PI);
    }
}
sensor(integer num){
    search_object_list=llDeleteSubList(search_object_list,0,0);
    command_list=llDeleteSubList(command_list,0,0);
    controller_key_list=llDeleteSubList(controller_key_list,0,0);

    if(search_object_list!=[]){
        llSensor(llList2String(search_object_list,0),"",ACTIVE|PASSIVE|SCRIPTED,96,PI);
    }
}
no_sensor(){
    Error();
    llSay(0,llKey2Name(llList2String(controller_key_list,0))+" [△注意 オブジェクト名\'"+llList2String(search_object_list,0)+"\'は周囲に見つかりませんでした。]\n"
                +llList2String(command_list,0));
    llMessageLinked(LINK_THIS,INT_PARTICLE,"PART_START",llList2Key(controller_key_list,0));
    
    search_object_list=llDeleteSubList(search_object_list,0,0);
    command_list=llDeleteSubList(command_list,0,0);
    controller_key_list=llDeleteSubList(controller_key_list,0,0);

    if(search_object_list!=[]){
        llSensor(llList2String(search_object_list,0),"",ACTIVE|PASSIVE|SCRIPTED,96,PI);
    }
}

timer(){
    if(power)llSetColor(<0,.3,.9>,ALL_SIDES);
}

link_message(integer sender,integer num,string msg,key id){
    if(num==-1){
        Error();
        llMessageLinked(LINK_THIS,INT_PARTICLE,"PART_START",id);
    }
}
}