//  ver.2.16 [2015/7/15]

integer COMMON_CHANNEL=1357246809;
string MSG_CANNOT_DEL="このオブジェクトはno copyなのでDELしません。-> ";
string objname;

Check(string command){
list tmplist=llParseString2List(command,["\n"],[]);
integer i;
for(i=1;i<llGetListLength(tmplist);i++){
if(llGetSubString(llList2String(tmplist,i),0,llStringLength(objname))==objname+","){
list tmplist2=llCSV2List(llList2String(tmplist,i));
string command=llList2String(tmplist2,1);
if(command=="DEL"){
float second=(float)llList2String(tmplist2,2);
integer frame=(integer)(second/0.25);
if(second*frame!=0){
integer i;
integer j;
for(i=0;i<=frame;i++){
llSleep(second/(float)frame);
for(j=0;j<=llGetNumberOfPrims();j++){
llSetLinkAlpha(j,1.0-((float)i/(float)frame),ALL_SIDES);
}
}
}
if((llGetObjectPermMask(MASK_BASE)&PERM_COPY)&&(llGetObjectPermMask(MASK_OWNER)&PERM_COPY)){
llDie();
}else{
llOwnerSay(MSG_CANNOT_DEL+objname+(string)llGetPos());
}
}
else if(command=="COLOR"){
vector color=((vector)llList2String(tmplist2,2))/255.0;
integer j;
for(j=0;j<=llGetNumberOfPrims();j++){
llSetLinkColor(j,color,ALL_SIDES);
}
}
else if(command=="COLOR_ANIM"){
vector color1=(vector)llList2String(tmplist2,2)/255.0;
vector color2=(vector)llList2String(tmplist2,3)/255.0;
vector color_difference=<color1.x-color2.x,color1.y-color2.y,color1.z-color2.z>;
float second=(float)llList2String(tmplist2,4);
integer frame=(integer)(second/0.25);
if(second*frame==0){second=0.01;frame=1;}
integer i;
integer j;
for(i=0;i<=frame;i++){
llSleep(second/(float)frame);
for(j=0;j<=llGetNumberOfPrims();j++){
llSetLinkColor(j,<color1.x-(color_difference.x*(float)i/(float)frame),color1.y-(color_difference.y*(float)i/(float)frame),color1.z-(color_difference.z*(float)i/(float)frame)>,ALL_SIDES);
}
}
llSetLinkColor(j,color2,ALL_SIDES);
}
else if(command=="ALPHA"){
float alpha=(float)llList2String(tmplist2,2)*0.01;
integer j;
for(j=0;j<=llGetNumberOfPrims();j++){
llSetLinkAlpha(j,alpha,ALL_SIDES);
}
}
else if(command=="ALPHA_ANIM"){
float alpha1=(float)llList2String(tmplist2,2)*0.01;
float alpha2=(float)llList2String(tmplist2,3)*0.01;
float alpha_difference=alpha1-alpha2;
float second=(float)llList2String(tmplist2,4);
integer frame=(integer)(second/0.25);
if(second*frame==0){second=0.01;frame=1;}
integer i;
integer j;
for(i=0;i<=frame;i++){
llSleep(second/(float)frame);
for(j=0;j<=llGetNumberOfPrims();j++){
llSetLinkAlpha(j,alpha1-(alpha_difference*(float)i/(float)frame),ALL_SIDES);
}
}
}
else if(command=="MOVE"){
vector tgt=(vector)llList2String(tmplist2,2);
vector angle=(vector)llList2String(tmplist2,3);
if(200>llVecDist(llGetPos(),tgt)){
llSetRegionPos(tgt);
llSetRot(llEuler2Rot(angle*DEG_TO_RAD));
}
}
else if(command=="MOVE_ANIM"){
vector startpos=(vector)llList2String(tmplist2,2);
rotation startrot=llEuler2Rot((vector)llList2String(tmplist2,3)*DEG_TO_RAD);
vector endpos=(vector)llList2String(tmplist2,4);
rotation endrot=llEuler2Rot((vector)llList2String(tmplist2,5)*DEG_TO_RAD);
float second=(float)llList2String(tmplist2,6);
integer frame=(integer)(second/0.25);
if(second*frame==0){second=0.01;frame=1;}
vector pos_difference=(endpos-startpos)/frame;
vector rot_difference=llRot2Euler(endrot/startrot)/frame;
if((200>llVecDist(llGetPos(),startpos))&&(200>llVecDist(llGetPos(),endpos))){
llSetRegionPos(startpos);
integer i;
float tmp=second/frame;
for(i=0;i<=frame;i++){
llSetPrimitiveParams([PRIM_POSITION,startpos+(pos_difference*i),PRIM_ROTATION,llEuler2Rot(rot_difference*i)*startrot]);
if(tmp>0.2){
llSleep(tmp-0.2);
}
}
}
}
else{
llMessageLinked(LINK_THIS,0,llDumpList2String(llList2List(tmplist2,1,-1),"&"),"");
}
}
}
}

//==============================================
default{
state_entry(){
if((llGetObjectDesc()=="")||(llGetObjectDesc()=="(No Description)")){
llSetObjectDesc("OWNER");
}
llListen(COMMON_CHANNEL,"","","");
}
on_rez(integer num){
llShout(COMMON_CHANNEL+1,"REZZED");
float second=num*0.001;
integer frame=(integer)(second/0.2);
if(second*frame==0){return;}
integer i;
integer j;
for(i=0;i<=frame;i++){
for(j=0;j<=llGetNumberOfPrims();j++){
llSetLinkAlpha(j,((float)i/(float)frame),ALL_SIDES);
}
llSleep(0.2);
}
}
listen(integer chnl,string name,key id,string msg){
if(llGetSubString(msg,0,llStringLength(llGetObjectDesc()))!=llGetObjectDesc()+"\n"){
return;
}
if((llGetObjectDesc()=="OWNER")||(llGetObjectDesc()=="owner")){
if(llGetOwnerKey(id)!=llGetOwner()){return;}
}
objname=llGetObjectName();
if(llSubStringIndex(msg,"\n"+objname+",")==-1){
return;
}
Check(msg);
}
link_message(integer sender,integer num,string msg,key id){
if((num==-1)&&(id=="cmd")){
objname=llGetObjectName();
Check(msg);
}
}
}