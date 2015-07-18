﻿// ver.2.1 [2015/7/15]

integer COMMON_CHANNEL=1357246809;
string anim_obj_name;
integer registry_number;
integer lsnnum;
integer lsnchnl;
string step_flg;

default
{
state_entry()
{
lsnchnl=(integer)llFrand(-900000);
lsnnum=llListen(lsnchnl,"",llGetOwner(),"");
llTextBox(llGetOwner(),"初期設定を行います。\n#ADD_ANIMATIONの入ったオブジェクトの名前を入力してください。",lsnchnl);
step_flg="GET_OBJNAME";
}
listen(integer chnl,string name,key id,string msg){
if(id!=llGetOwner()){return;}
llListenRemove(lsnnum);
if(step_flg=="GET_OBJNAME"){
if(msg==""){
llResetScript();
}else{
anim_obj_name=msg;
step_flg="GET_NUMBER";
lsnchnl=(integer)llFrand(-900000);
lsnnum=llListen(lsnchnl,"",llGetOwner(),"");
llTextBox(llGetOwner(),"このスタンドに座った人に割り当てる登録ナンバーを半角数字で入力して下さい。",lsnchnl);
}
return;
}
if(step_flg=="GET_NUMBER"){
registry_number=(integer)msg;
if((registry_number<0)||(registry_number>100)){
llOwnerSay("登録ナンバーに[ "+msg+" ]番は使えません。0～100の数字のみ有効です。");
llResetScript();
return;
}
step_flg="CONFIRM";
lsnchnl=(integer)llFrand(-900000);
lsnnum=llListen(lsnchnl,"",llGetOwner(),"");
llDialog(llGetOwner(),"オブジェクト名："+anim_obj_name+"\n登録ナンバー："+(string)registry_number+"番\nで設定します。",["OK","やり直す"],lsnchnl);
return;
}
if(step_flg=="CONFIRM"){
if(msg=="OK"){
llOwnerSay("設定しました。最後にNoPoseStandの説明欄がオブジェクト\""+anim_obj_name+"\"の説明欄と同じになっているかご確認ください。[ 現在:"+llGetObjectDesc()+" ]");
step_flg="READY";
}else{
llResetScript();
}
}
}
changed(integer chg){
if(chg & CHANGED_LINK){
integer links = 0;
if(llGetObjectPrimCount(llGetKey()) < (links = llGetNumberOfPrims())){
llShout(COMMON_CHANNEL,llGetObjectDesc()+"\n"+anim_obj_name+",ANIM_REGISTRY,"+llGetLinkName(links)+","+(string)registry_number);
}else{
llShout(COMMON_CHANNEL,llGetObjectDesc()+"\n"+anim_obj_name+",ANIM_REGISTRY,,"+(string)registry_number);
}
}
}
}
