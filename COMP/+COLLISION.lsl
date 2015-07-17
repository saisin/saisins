// ver.2.1[2015/7/15]
default{
state_entry(){}
collision_start(integernum){
llMessageLinked(LINK_THIS,llGetLinkNumber(),"RUN","");
}
}