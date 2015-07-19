//    ver.2.66 [2015/7/15]

integer COMMON_CHANNEL=1357246809; 
string NOTENAME="commands";
string MSG_LOADING="コマンドを読み込み中です、少々おまちください";
list commandlist=[]; 
list say_list; 
list timer_list; 
string command_source;
string command_buffer;
list command_pos_list;
list command_ang_list;
integer command_index;
key lastnotecardkey;
key req_note;
integer noteline;
integer jointflg;
string jointstrings;
integer loadingflg;
integer runflg;
integer posmemoryflg=FALSE;
integer posloadflg=FALSE;
integer touch_cnt;

Run(){
if(loadingflg){llOwnerSay(MSG_LOADING);return;}
if(posmemoryflg&&!posloadflg){llOwnerSay("POSLOADを行ってください。");return;}
string chnlname=llGetObjectDesc();
integer i;
list tmplist;

if(llList2String(say_list,command_index)!=" "){
tmplist=llParseString2List(llList2String(say_list,command_index),["\n"],[]);
for(i=0;llList2String(tmplist,i)!="";i=i+3){
if(llList2String(tmplist,i)=="SA"){
llSay(llList2Integer(tmplist,i+1),llList2String(tmplist,i+2));
}
if(llList2String(tmplist,i)=="SH"){
llShout(llList2Integer(tmplist,i+1),llList2String(tmplist,i+2));
}
}
}
if(llList2String(commandlist,command_index)!=" "){
tmplist=llParseString2List(llList2String(commandlist,command_index),["&"],[]);
for(i=0;i<llGetListLength(tmplist);i++){
llShout(COMMON_CHANNEL,chnlname+"\n"+llList2String(tmplist,i));
llMessageLinked(LINK_THIS,-1,chnlname+"\n"+llList2String(tmplist,i),"cmd");
}
}
 
if(command_index<llGetListLength(commandlist)-1){
float tmp_float=llList2Float(timer_list,command_index);
if(tmp_float==0){tmp_float=0.01;}
llSetTimerEvent(tmp_float);
}else{
runflg=FALSE;
}
++command_index;
}

ReplacePosAng(string from, string to){
integer len = (~-(llStringLength(from)));
if(~len)
{
string  buffer = command_buffer;
integer b_pos = ERR_GENERIC;
integer to_len = (~-(llStringLength(to)));
@loop;
integer to_pos = ~llSubStringIndex(buffer, from);
if(to_pos)
{
buffer = llGetSubString(command_buffer = llInsertString(llDeleteSubString(command_buffer, b_pos -= to_pos, b_pos + len), b_pos, to), (-~(b_pos += to_len)), 0x8000);
jump loop;
}
}
}
string Vec2Str(vector tgt){
return "<"+llGetSubString((string)(tgt.x),0,-5)+","+llGetSubString((string)(tgt.y),0,-5)+","+llGetSubString((string)(tgt.z),0,-5)+">";
}

MakeCommandlist(){
integer readcnt=0;
string tmpcommand;
string tmp_say_shout;
integer length_over_cnt=0;
integer i;
for(i=0;i<1000;i++){
string readline=llGetSubString(command_buffer,readcnt,readcnt+770);
integer search=llSubStringIndex(readline,"\n");

if(search!=-1){
readcnt+=search+1;
readline=llGetSubString(readline,0,search);
}else{
i=2000;
readline=llGetSubString(readline,0,-1);
}
list tmplist=llParseString2List(readline,[","],[]);
if(llList2String(tmplist,0)=="WAIT"){
if(tmpcommand==""){tmpcommand=" ";}
if(tmp_say_shout==""){tmp_say_shout=" ";}
commandlist+=[tmpcommand];
say_list+=[tmp_say_shout];
timer_list+=llList2Float(tmplist,1);
tmpcommand="";
tmp_say_shout="";
length_over_cnt=0;
}else{
if(llList2String(tmplist,0)=="SAY"){
tmp_say_shout+="SA\n"+llList2String(tmplist,1)+"\n"+llList2String(tmplist,2);
}else if(llList2String(tmplist,0)=="SHOUT"){
tmp_say_shout+="SH\n"+llList2String(tmplist,1)+"\n"+llList2String(tmplist,2);
}else{
if(llStringLength(tmpcommand)+llStringLength(readline)>990+(990*length_over_cnt)){
tmpcommand+="&"+readline;
length_over_cnt++;
}else{
tmpcommand+=readline;
}
}
}
if(i==2000){
command_buffer="";
if((tmpcommand!="")||(tmp_say_shout!="")){
if(tmpcommand==""){tmpcommand=" ";}
if(tmp_say_shout==""){tmp_say_shout=" ";}
commandlist+=[tmpcommand];
say_list+=[tmp_say_shout];
}
}
}
}

default{
state_entry(){
if((llGetObjectDesc()=="")||(llGetObjectDesc()=="(No Description)")){
llSetObjectDesc("OWNER");
}
loadingflg=TRUE;
req_note=llGetNotecardLine(NOTENAME,0);
lastnotecardkey=llGetInventoryKey(NOTENAME);
}
touch_start(integer num){
if((llDetectedKey(0)!=llGetOwner())||(llGetListLength(commandlist)==0)){return;}
touch_cnt=0;
}
touch(integer num){
if((llDetectedKey(0)!=llGetOwner())||(llGetListLength(commandlist)==0)){return;}
++touch_cnt;
if(touch_cnt==60){
llOwnerSay("ストップしました");
llSetTimerEvent(0);
}
}
touch_end(integer num){
if((llDetectedKey(0)!=llGetOwner())||(llGetListLength(commandlist)==0)){return;}
if(touch_cnt<60){
command_index=0;
runflg=TRUE;
Run();
}
}


timer(){
llSetTimerEvent(0);
Run();
}
changed(integer chg){
if(chg & CHANGED_INVENTORY){
if(lastnotecardkey!=llGetInventoryKey(NOTENAME)){
lastnotecardkey=llGetInventoryKey(NOTENAME);
commandlist=[];
say_list=[];
timer_list=[];
command_source="";
command_pos_list=[];
command_ang_list=[];
noteline=0;
jointflg=FALSE;
jointstrings="";
loadingflg=TRUE;
posmemoryflg=FALSE;
posloadflg=FALSE;
llSetText("",<1,1,1>,0);
req_note=llGetNotecardLine(NOTENAME,0);
}
}
}
dataserver(key reqid,string data){
if(reqid==req_note){
if(data!=EOF){
if(llStringLength(data)>=255){llOwnerSay("#ERROR#"+(string)(noteline+1)+"行目 :コマンドは1行あたり255文字未満にしてください。");}
if(data!=""){
if(llGetSubString(data,0,0)!="\""){
list tmplist=llParseString2List(data,["pos("],[]);
integer i;
string tmp;
for(i=1;i<llGetListLength(tmplist);i++){
tmp=llGetSubString(llList2String(tmplist,i),0,llSubStringIndex(llList2String(tmplist,i),")")-1);
if(llListFindList(command_pos_list,(list)tmp)==-1){
command_pos_list+=[tmp,<0,0,0>];
}
}
tmplist=llParseString2List(data,["ang("],[]);
for(i=1;i<llGetListLength(tmplist);i++){
tmp=llGetSubString(llList2String(tmplist,i),0,llSubStringIndex(llList2String(tmplist,i),")")-1);
if(llListFindList(command_ang_list,(list)tmp)==-1){
command_ang_list+=[tmp,ZERO_ROTATION];
}
}
if(llGetSubString(data,-1,-1)==","){
jointflg=TRUE;
jointstrings+=data;
}else{
if(jointflg){
if(command_source!=""){data="\n"+data;}
command_source+=jointstrings+data;
jointflg=FALSE;
jointstrings="";
}else{
if(command_source!=""){data="\n"+data;}
command_source+=data;
}
}
}else{
llSetText(llGetSubString(data,1,llStringLength(data)-2),<1,1,1>,1);
}
}
noteline++;
req_note=llGetNotecardLine(NOTENAME,noteline);
}else{
jointstrings="";
command_buffer=command_source;
integer i;

for(i=0;i<1000;i++){
integer search1=llSubStringIndex(command_buffer,"pos(");
if(search1==-1){
i=2000;
}else{
command_buffer=llInsertString(llDeleteSubString(command_buffer,search1,search1+3),search1,"<");
string tmpstr=llGetSubString(command_buffer,search1,search1+100);
integer search2=llSubStringIndex(tmpstr,")");
if(search2!=-1){
command_buffer=llInsertString(llDeleteSubString(command_buffer,search1+search2,search1+search2),search1+search2,">");
}
}
}
for(i=0;i<1000;i++){
integer search1=llSubStringIndex(command_buffer,"ang(");
if(search1==-1){
i=2000;
}else{
command_buffer=llInsertString(llDeleteSubString(command_buffer,search1,search1+3),search1,"<");
string tmpstr=llGetSubString(command_buffer,search1,search1+100);
integer search2=llSubStringIndex(tmpstr,")");
if(search2!=-1){
command_buffer=llInsertString(llDeleteSubString(command_buffer,search1+search2,search1+search2),search1+search2,">");
}
}
}
MakeCommandlist();
loadingflg=FALSE;
}
}
}
link_message(integer sender,integer num,string msg,key id){
if((msg=="RUN")&&(num==llGetLinkNumber())){
command_index=0;
runflg=TRUE;
Run();
}
if(msg=="POSMEMORY"){
llMessageLinked(LINK_ROOT,-1,"PM_START","");
if(loadingflg){llOwnerSay(MSG_LOADING);return;}
if(runflg){runflg=FALSE;llSetTimerEvent(0);}
list tmplist=llParseString2List(id,["&"],[]);
vector flag_pos=(vector)llList2String(tmplist,0);
rotation flag_rot=(rotation)llList2String(tmplist,1);
vector relpos;
integer i;
for(i=0;i<llGetListLength(command_pos_list);i+=2){
relpos=((vector)("<"+llList2String(command_pos_list,i)+">")-flag_pos)/flag_rot;
command_pos_list=llListReplaceList(command_pos_list,(list)relpos,i+1,i+1);
}
for(i=0;i<llGetListLength(command_ang_list);i+=2){
rotation relrot=llEuler2Rot((vector)("<"+llList2String(command_ang_list,i)+">")*DEG_TO_RAD)/flag_rot;
command_ang_list=llListReplaceList(command_ang_list,(list)relrot,i+1,i+1);
}
llMessageLinked(LINK_ROOT,-1,"PM_END","");
posmemoryflg=TRUE;
}
if(msg=="POSLOAD"){
if(!posmemoryflg){llOwnerSay("先にPOSMEMORYを行ってください。　");return;}
llMessageLinked(LINK_ROOT,-1,"PL_START","");
if(loadingflg){llOwnerSay(MSG_LOADING);return;}
if(runflg){runflg=FALSE;llSetTimerEvent(0);}
list tmplist=llParseString2List(id,["&"],[]);
vector flag_pos=(vector)llList2String(tmplist,0);
rotation flag_rot=(rotation)llList2String(tmplist,1);

command_buffer=command_source;

integer i;
for(i=0;i<llGetListLength(command_pos_list);i+=2){
vector abspos=flag_pos+(llList2Vector(command_pos_list,i+1)*flag_rot);
ReplacePosAng("pos("+llList2String(command_pos_list,i)+")",Vec2Str(abspos));
}
for(i=0;i<llGetListLength(command_ang_list);i+=2){
vector absang=llRot2Euler(llList2Rot(command_ang_list,i+1)*flag_rot)*RAD_TO_DEG;
ReplacePosAng("ang("+llList2String(command_ang_list,i)+")",Vec2Str(absang));
}
commandlist=[];
say_list=[];
timer_list=[];
MakeCommandlist();
llMessageLinked(LINK_ROOT,-1,"PL_END","");
posloadflg=TRUE;
}
}
}