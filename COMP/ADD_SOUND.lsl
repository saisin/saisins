// ver.2.1[2015/7/15]

default{
state_entry(){}
link_message(integer sender,integer num,string msg,key id)
{
list data_list=llParseString2List(msg,["&"],[]);
string command=llList2String(data_list,0);
if(command=="SOUND_PLAY"){
llPlaySound(llList2String(data_list,1),(float)llList2String(data_list,2));
}
if(command=="SOUND_LOOP"){
llLoopSound(llList2String(data_list,1),(float)llList2String(data_list,2));
}
if(command=="SOUND_STOP"){
llStopSound();
}
if(command=="SOUND_QUEUE"){
if(llList2String(data_list,1)=="ON"){
llSetSoundQueueing(TRUE);
}else{
llSetSoundQueueing(FALSE);
}
}
if(command=="SOUND_COLLISION"){
llCollisionSound(llList2String(data_list,1),(float)llList2String(data_list,2));
}
if(command=="MUSIC_PLAY"){
llParcelMediaCommandList([PARCEL_MEDIA_COMMAND_TYPE,"audio/*",PARCEL_MEDIA_COMMAND_URL,llList2String(data_list,1),PARCEL_MEDIA_COMMAND_PLAY]);
}
if(command=="MUSIC_STOP"){
 llParcelMediaCommandList([PARCEL_MEDIA_COMMAND_URL,"",PARCEL_MEDIA_COMMAND_STOP]);
}
}
}