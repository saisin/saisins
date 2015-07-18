// ver.2.1[2015/7/15]

integer GetFace(string tgt){
integer ret;
if(tgt=="ALL_SIDES"){
ret=-1;
}else{
ret=(integer)tgt;
}
return ret;
}

default
{
state_entry(){}
link_message(integer sender,integer num,string msg,key id)
{
if(num!=0){return;}
list tmplist=llParseString2List(msg,["&"],[]);
string command=llList2String(tmplist,0);

if(command=="SCALE"){
llScaleByFactor((float)llList2String(tmplist,1)*0.01);
return;
}
if(command=="SCALE_TARGET"){
llSetLinkPrimitiveParamsFast((integer)llList2String(tmplist,1),[PRIM_SIZE,(vector)llList2String(tmplist,2)]);
return;
}
if(command=="GLOW"){
float brightness=(float)llList2String(tmplist,1);
integer j;
for(j=0;j<=llGetNumberOfPrims();j++){
llSetLinkPrimitiveParamsFast(j,[PRIM_GLOW,ALL_SIDES,brightness]);
}
return;
}
if(command=="TEXTURE"){
integer face=GetFace(llList2String(tmplist,1));
llSetTexture(llList2String(tmplist,2),face);
return;
}
if(command=="PHYSICS"){
integer tmp=1;
if(llList2String(tmplist,1)!="ON"){tmp=0;}
llSetStatus(STATUS_PHYSICS,tmp);
return;
}
if(command=="IMPULSE"){
llApplyImpulse((vector)llList2String(tmplist,1)*llGetObjectMass(llGetKey()),FALSE);
}
if(command=="IMPULSE2"){
llApplyImpulse((vector)llList2String(tmplist,1)*llGetObjectMass(llGetKey()),TRUE);
}
if(command=="OMEGA"){
llTargetOmega((vector)llList2String(tmplist,1),(float)llList2String(tmplist,2),(float)llList2String(tmplist,2));
}
if(command=="PHANTOM"){
integer tmp=1;
if(llList2String(tmplist,1)!="ON"){tmp=0;}
llSetStatus(STATUS_PHANTOM,tmp);
return;
}
if(command=="FULLBRIGHT"){
integer tmp=1;
if(llList2String(tmplist,1)!="ON"){tmp=0;}
integer j;
for(j=0;j<=llGetNumberOfPrims();j++){
llSetLinkPrimitiveParamsFast(j,[PRIM_FULLBRIGHT,ALL_SIDES,tmp]);
}
return;
}

if(command=="COLOR_TARGET"){
integer face=GetFace(llList2String(tmplist,2));
llSetLinkColor((integer)llList2String(tmplist,1),((vector)llList2String(tmplist,3))/255.0,face);
return;
}
if(command=="ALPHA_TARGET"){
integer face=GetFace(llList2String(tmplist,2));
llSetLinkAlpha((integer)llList2String(tmplist,1),1.0-(0.01*(float)llList2String(tmplist,3)),face);
return;
}
if(command=="GLOW_TARGET"){
integer face=GetFace(llList2String(tmplist,2));
llSetLinkPrimitiveParamsFast((integer)llList2String(tmplist,1),[PRIM_GLOW,face,(float)llList2String(tmplist,3)]);
return;
}
if(command=="TEXTURE_TARGET"){
integer face=GetFace(llList2String(tmplist,2));
llSetLinkPrimitiveParamsFast((integer)llList2String(tmplist,1),[PRIM_TEXTURE,face,llList2String(tmplist,3),(vector)llList2String(tmplist,4),(vector)llList2String(tmplist,5),(float)llList2String(tmplist,6)]);
return;
}
}
}