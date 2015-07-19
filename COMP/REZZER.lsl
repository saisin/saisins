//  ver.2.18 [2015/7/15]

integer COMMON_CHANNEL=1357246809;
vector rezzer_pos;
list save_command_list=[];
list rezzing_objname_list=[];
integer activeflg=FALSE;

AddRezObjName(string objname){
if(llListFindList(rezzing_objname_list,(list)objname)==-1){
rezzing_objname_list+=[objname];
save_command_list+=["@"];
}
}
DelRezObjName(string objname){
integer ind=llListFindList(rezzing_objname_list,(list)objname);if(ind==-1){return;}
save_command_list=llDeleteSubList(save_command_list,ind,ind);
rezzing_objname_list=llDeleteSubList(rezzing_objname_list,ind,ind);
}
AddCommands(integer ind,string add_command){
list tmplist=llParseString2List(llList2String(save_command_list,ind),["\n"],[]);
save_command_list=llListReplaceList(save_command_list,(list)llDumpList2String(tmplist+(list)add_command,"\n"),ind,ind);
}
ShoutCommands(string objname){
integer ind=llListFindList(rezzing_objname_list,(list)objname);if(ind==-1){return;}
list commandlist=llParseString2List(llList2String(save_command_list,ind),["\n"],[]);

string chnlname=llGetObjectDesc();
string send=chnlname;
integer i;
string tmp;
for(i=1;i<llGetListLength(commandlist);i++){
tmp=llList2String(commandlist,i);
if((llStringLength(send)+llStringLength(tmp)+2)<1000){
send+="\n"+tmp;
}else{
llShout(COMMON_CHANNEL,send);
send=chnlname+"\n"+tmp;
}
}
if(send!=chnlname){llShout(COMMON_CHANNEL,send);}
}

default{
state_entry(){
if(llGetObjectDesc()==""){
llSetObjectDesc("OWNER");
}
rezzer_pos=llGetPos();
llListen(COMMON_CHANNEL,"","","");
llListen(COMMON_CHANNEL+1,"","","REZZED");
}

timer(){
llSetTimerEvent(0);
llSetRegionPos(rezzer_pos);
llSetLinkPrimitiveParamsFast(llGetLinkNumber(),[
PRIM_TEXTURE,ALL_SIDES,"43b69a6a-c20b-0f42-1097-cf1fa5810f9c",<1,1,0>,<0,0,0>,0,
PRIM_TEXTURE,0,"30953c55-91c5-f0e9-d34b-6147af8fca65",<1,1,0>,<0,0,0>,0,
PRIM_TEXTURE,5,TEXTURE_BLANK,<1,1,0>,<0,0,0>,0]);
rezzing_objname_list=[];
save_command_list=[];
activeflg=FALSE;
}

listen(integer chnl,string name,key id,string msg){
if(chnl==COMMON_CHANNEL+1){
ShoutCommands(name);
DelRezObjName(name);
return;
}
if((llGetObjectDesc()=="OWNER")||(llGetObjectDesc()=="owner")){
if(llGetOwnerKey(id)!=llGetOwner()){
return;
}
}
string objname=llGetObjectName();
if((rezzing_objname_list==[])&&(llSubStringIndex(msg,","+objname)==-1)){return;}
list tmplist=llParseStringKeepNulls(msg,["\n"],[]);
integer i;
for(i=1;i<llGetListLength(tmplist);i++){
list tmplist2=llCSV2List(llList2String(tmplist,i));
string command=llList2String(tmplist2,1);
if(command=="REZ"){
if((!activeflg)&&(rezzing_objname_list==[])){
rezzer_pos=llGetPos();
activeflg=TRUE;
llSetLinkPrimitiveParamsFast(llGetLinkNumber(),[PRIM_TEXTURE,ALL_SIDES,TEXTURE_TRANSPARENT,<1,1,0>,<0,0,0>,0]);
llSetTimerEvent(30);
}
if(llList2String(tmplist2,5)==objname){
string rezobjname=llList2String(tmplist2,0);
if(llGetInventoryType(rezobjname)!=INVENTORY_NONE){
AddRezObjName(rezobjname);
llMessageLinked(LINK_THIS,123456,rezobjname+","+llList2String(tmplist2,2)+","+(string)(llEuler2Rot((vector)llList2String(tmplist2,3)*DEG_TO_RAD))+","+llList2String(tmplist2,4),"REZ");
}else{
llOwnerSay(rezobjname+"はインベントリーに見つかりませんでした");
}
}
}
if(!((command=="REZ")&&(llList2String(tmplist2,5)==objname))){
integer found=llListFindList(rezzing_objname_list,llList2List(tmplist2,0,0));
if(found!=-1){
AddCommands(found,llList2String(tmplist,i));
}
}
}
}
link_message(integer sender,integer num,string msg,key id){
if((num==-1)&&(msg=="rez_end")){
llSetTimerEvent(5);
}
}
}