// ver.2.11[2015/7/15]

list NUMLIST=["0","1","2","3","4","5","6","7","8","9"];
integer my_script_number;
string my_avatar_name;
key my_avatar_key;
string nowanim;
string tgt_name;
integer perm;
integer i;

default{
on_rez(integer num){
llResetScript();
}
state_entry(){
string tmp=llGetScriptName();
integer index=llStringLength(tmp)-1;
for(i=0;i<4;i++){
string check=llGetSubString(tmp,index,index);
if(llListFindList(NUMLIST,(list)check)!=-1){index--;}else{i=10;}
}
if(index==llStringLength(tmp)){
my_script_number=0;}else{
my_script_number=(integer)llGetSubString(tmp,index,llStringLength(tmp));
}
}
link_message(integer sender,integer num,string msg,key id)
{
if(num!=0){
return;
}
list data_list=llParseStringKeepNulls(msg,["&"],[]);
string command=llList2String(data_list,0);

if(command=="ANIM_REGISTRY"){
if((integer)llList2String(data_list,2)!=my_script_number){return;}
llSetTimerEvent(0);
if((llGetPermissions()&PERMISSION_TRIGGER_ANIMATION)&&(llGetPermissionsKey()==my_avatar_key)){
if(nowanim!=""){
llStopAnimation(nowanim);
}
}
nowanim="";
tgt_name=llList2String(data_list,1);
if(my_avatar_name!=tgt_name){
if(tgt_name==llKey2Name(llGetOwner())){
llRequestPermissions(llGetOwner(),PERMISSION_TRIGGER_ANIMATION);
}else{
if(tgt_name==""){
my_avatar_key="";
my_avatar_name="";
}else{
llSensor(tgt_name,"",AGENT,96,PI);
}
}
}
}else if(command=="ANIM_START"){
if(llListFindList(llList2List(data_list,2,-1),(list)((string)my_script_number))==-1){
return;
}
if((llGetPermissions()&PERMISSION_TRIGGER_ANIMATION)&&(llGetPermissionsKey()==my_avatar_key)){
if(nowanim!=""){llStopAnimation(nowanim);}
nowanim=llList2String(data_list,1);
llStartAnimation(nowanim);
}
}else if(command=="ANIM_STOP"){
if(llListFindList(data_list,(list)((string)my_script_number))==-1){return;}
if((llGetPermissions()&PERMISSION_TRIGGER_ANIMATION)&&(llGetPermissionsKey()==my_avatar_key)){
if(nowanim!=""){llStopAnimation(nowanim);}
}
}
}
run_time_permissions(integer perm){
if(perm&PERMISSION_TRIGGER_ANIMATION){
my_avatar_key=llGetPermissionsKey();
my_avatar_name=llKey2Name(my_avatar_key);
}
}
sensor(integer num){
llRequestPermissions(llDetectedKey(0),PERMISSION_TRIGGER_ANIMATION);
}
no_sensor(){
llOwnerSay(tgt_name+"さんが96m以内に見つかりませんでした。");
}
}