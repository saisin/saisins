// ver.2.1[2015/7/15]

float radius=20;
float falloff=0;
float intensity;

default{
state_entry(){}
link_message(integer sender,integer num,string msg,key id)
{
if(num!=0){return;}
list data_list=llParseString2List(msg,["&"],[]);
string command=llList2String(data_list,0);

if(command=="LIGHT"){
vector color=((vector)llList2String(data_list,1))/255.0;
intensity=(float)llList2String(data_list,2);
radius=(float)llList2String(data_list,3);
falloff=(float)llList2String(data_list,4);
integer i;
for(i=0;i<llGetNumberOfPrims();i++){
if((color==<0,0,0>)||(intensity<=0)){
llSetLinkPrimitiveParamsFast((!!llGetLinkNumber())+i,[PRIM_POINT_LIGHT,FALSE,color,intensity,radius,falloff]);
}else{
llSetLinkPrimitiveParamsFast((!!llGetLinkNumber())+i,[PRIM_POINT_LIGHT,TRUE,color,intensity,radius,falloff]);
}
}
}
if(command=="LIGHT_TARGET"){
integer linknum=(integer)llList2String(data_list,1);
vector color=((vector)llList2String(data_list,2))/255.0;
intensity=(float)llList2String(data_list,3);
radius=(float)llList2String(data_list,3);
falloff=(float)llList2String(data_list,4);
if((color==<0,0,0>)||(intensity<=0)){
llSetLinkPrimitiveParamsFast(linknum,[PRIM_POINT_LIGHT,FALSE,color,intensity,radius,falloff]);
}else{
llSetLinkPrimitiveParamsFast(linknum,[PRIM_POINT_LIGHT,TRUE,color,intensity,radius,falloff]);
}
}
}
}