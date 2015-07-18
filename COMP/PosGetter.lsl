//  ver.2.1[2015/7/15]

string DEL_COMMAND="PG消去";
string Cut(float tgt,integer num){
return llGetSubString((string)tgt,0,-num);
}

default
{
state_entry()
{
llListen(0,"",llGetOwner(),DEL_COMMAND);
}
on_rez(integer num)
{
llResetScript();
}
touch_start(integer total_number)
{
string px;
string py;
string pz;
string ax;
string ay;
string az;

vector pos;
vector ang;

pos=llGetPos();
ang=llRot2Euler(llGetRot())*RAD_TO_DEG;

px=Cut(pos.x,5);
py=Cut(pos.y,5);
pz=Cut(pos.z,5);
ax=Cut(ang.x,8);
ay=Cut(ang.y,8);
az=Cut(ang.z,8);

llOwnerSay("pos("+(string)px+","+(string)py+","+(string)pz+"),ang("+(string)ax+","+(string)ay+","+(string)az+")");
}
listen(integer chnl,string name,key id,string msg)
{
llOwnerSay("#PosGetterスクリプトを消去しました。");
llRemoveInventory(llGetScriptName());
}
}