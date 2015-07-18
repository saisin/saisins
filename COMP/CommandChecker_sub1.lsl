//  ver.2.1[2015/7/15]

string checker_URL="http://yoshihiros2.sakura.ne.jp/contro/cmdcheck.php";
integer INT_SET_QUEUE=156783;
integer MY_NUM;
key req_id;
list check_queue;
list controller_key_queue;

default
{
state_entry(){
MY_NUM=(integer)llGetSubString(llGetScriptName(),-1,-1);
}

link_message(integer sender,integer num,string msg,key id){
if(num==INT_SET_QUEUE+MY_NUM){
check_queue+=[msg];
controller_key_queue+=[id];
if(llGetListLength(check_queue)==1){
req_id=llHTTPRequest(checker_URL,[HTTP_METHOD,"POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],"data="+llEscapeURL(llList2String(check_queue,0)));
llSleep(0.8);
}
}
}

http_response(key request_id, integer status, list metadata, string body){
if(req_id!=request_id){return;}
if (status == 200){
if(body!="OK"){
llSay(0,llKey2Name(llList2String(controller_key_queue,0))+" ["+body+"]");
llMessageLinked(LINK_ROOT,-1,body,llList2String(controller_key_queue,0));
}
}
check_queue=llDeleteSubList(check_queue,0,0);
controller_key_queue=llDeleteSubList(controller_key_queue,0,0);
if(check_queue!=[]){
req_id=llHTTPRequest(checker_URL,[HTTP_METHOD,"POST",HTTP_MIMETYPE,"application/x-www-form-urlencoded"],"data="+llEscapeURL(llList2String(check_queue,0)));
llSleep(0.8);
}
}
}
