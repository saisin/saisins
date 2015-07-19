//  ver.2.18 [2015/7/15]
default
{
state_entry(){}
link_message(integer sender,integer num,string msg,key id){
if((num==123456)&&(id=="REZ")){
list tmplist=llCSV2List(msg);//objname,<XYZ>,<XYZW>,0
llSetRegionPos((vector)llList2String(tmplist,1)+<0,0,9.5>);
llRezAtRoot(llList2String(tmplist,0),(vector)llList2String(tmplist,1),ZERO_VECTOR,(rotation)llList2String(tmplist,2),(integer)((float)llList2String(tmplist,3)*1000));
llMessageLinked(LINK_THIS,-1,"rez_end","");
}
}
}
