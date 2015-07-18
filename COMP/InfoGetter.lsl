//  ver.2.1[2015/7/15]
default
{
state_entry(){}
touch_start(integer total_number)
{
integer primnum=llDetectedLinkNumber(0);
integer primface=llDetectedTouchFace(0);
llOwnerSay("LinkNumber="+(string)primnum+"\nFaceNumber="+(string)primface);
}
}