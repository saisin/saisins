//##########################################
//
//  CONTRO - +SIT
//
// ver.2.1[2015/7/15]
//##########################################

//■座るとRUNする。複数座る場合座るたびに発動。

integer avatar_number;//座っているアバター人数
integer i;
default
{
    state_entry(){}
    changed(integer chg){
        if(chg&CHANGED_LINK){
            if(avatar_number<llGetNumberOfPrims()-llGetObjectPrimCount(llGetKey())){
                llMessageLinked(LINK_THIS,llGetLinkNumber(),"RUN","");
            }
            avatar_number=llGetNumberOfPrims()-llGetObjectPrimCount(llGetKey());
        }
    }
}