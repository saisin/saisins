//####################
//
//  CONTRO - +SIT
//
// ver.2.0[2015/7/19]
//####################

//■座ったら実行する

integer avatar_number=0;//座っているアバター数
integer i;
default
{
    state_entry(){}
    changed(integer chg){
        if(chg&CHANGED_LINK){
            if(avatar_number<llGetNumberOfPrims()-llGetObjectPrimCount(llGetKey())){//誰かが座るたびに実行する
                llMessageLinked(LINK_THIS,llGetLinkNumber(),"RUN","");
            }
            avatar_number=llGetNumberOfPrims()-llGetObjectPrimCount(llGetKey());
        }
    }
}