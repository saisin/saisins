﻿//##########################################
//
//  CONTRO - #RECEIVER
//
//  ver.2.16 [2015/7/15]
//##########################################
//[ スクリの動作 ]
//１、コマンドに応じて、オブジェクトの状態を変化させる。
//　(色変更、透明度変更、移動、オブジェクト削除)
//
// [ コントローラーコマンド ]
// ___,DEL,second
// ___,COLOR,<R,G,B>
// ___,COLOR_ANIM,<R,G,B>,<R,G,B>,second
// ___,ALPHA,alpha
// ___,ALPHA_ANIM,alpha,alpha,second
// ___,MOVE,pos(),ang()
// ___,MOVE_ANIM,pos(),ang(),pos(),ang(),second
//
//====================================================
//[ input ]
//(全てCOMMON_CHANNEL) [from CONTROLLER]
// channelname,___,DEL,second
// channelname,___,COLOR,<R,G,B>
// channelname,___,COLOR_ANIM,<R,G,B>,<R,G,B>,second
// channelname,___,ALPHA,alpha
// channelname,___,ALPHA_ANIM,alpha,alpha,second
// channelname,___,MOVE,pos(),ang()
// channelname,___,MOVE_ANIM,pos(),ang(),pos(),ang(),second
//
// channelname,___,XXX,XXX,,,
//上記以外のコマンドはLINK_SETへそのまま流す
//[ output ]
//(linkmessage) LINK_SET,0,"好きなコマンド&文字列１&文字列２,,," [to ADD_SCRIPT]
//
//
//##########################################
integer COMMON_CHANNEL=1357246809; //共通リッスンチャンネル
string MSG_CANNOT_DEL="このオブジェクトはno copyなのでDELしません。-> ";//後ろにオブジェクト名が付く
string objname;
//==============================================
Check(string command){
        list tmplist=llParseString2List(command,["\n"],[]);//A/objname,MOVE,<xyz>,<xyz>
        integer i;
        for(i=1;i<llGetListLength(tmplist);i++){
            if(llGetSubString(llList2String(tmplist,i),0,llStringLength(objname))==objname+","){
                list tmplist2=llCSV2List(llList2String(tmplist,i));//objname,MOVE,<xyz>,<xyz>
                string command=llList2String(tmplist2,1);    //命令の種類

                //----コマンドごとに処理開始----
                if(command=="DEL"){//___,DEL,second
                    float second=(float)llList2String(tmplist2,2);
                    integer frame=(integer)(second/0.25);//(integer)llList2String(tmplist22,3);
                    if(second*frame!=0){//フェードアウト指示があるかチェック
                        integer i;
                        integer j;
                        for(i=0;i<=frame;i++){
                            llSleep(second/(float)frame);
                            for(j=0;j<=llGetNumberOfPrims();j++){
                                llSetLinkAlpha(j,1.0-((float)i/(float)frame),ALL_SIDES);
                            }
                        }
                    }
                    if((llGetObjectPermMask(MASK_BASE)&PERM_COPY)&&(llGetObjectPermMask(MASK_OWNER)&PERM_COPY)){//コピー権限があるオブジェなら消す、ない場合消さずに通知
                        //llOwnerSay("Die-OK");
                        llDie();
                    }else{
                        llOwnerSay(MSG_CANNOT_DEL+objname+(string)llGetPos());
                    }
                }
                else if(command=="COLOR"){//___,COLOR,<R,G,B>
                    vector color=((vector)llList2String(tmplist2,2))/255.0;
                    integer j;
                    for(j=0;j<=llGetNumberOfPrims();j++){
                        llSetLinkColor(j,color,ALL_SIDES);
                    }
                }
                else if(command=="COLOR_ANIM"){//___,COLOR_ANIM,<R,G,B>,<R,G,B>,second
                    vector color1=(vector)llList2String(tmplist2,2)/255.0;
                    vector color2=(vector)llList2String(tmplist2,3)/255.0;
                    vector color_difference=<color1.x-color2.x,color1.y-color2.y,color1.z-color2.z>;
                    float second=(float)llList2String(tmplist2,4);
                    integer frame=(integer)(second/0.25);//(integer)llList2String(tmplist22,5);
                    if(second*frame==0){second=0.01;frame=1;}//どちらかが０の場合、一瞬で変化させる値を代入
                    integer i;
                    integer j;
                    for(i=0;i<=frame;i++){
                        llSleep(second/(float)frame);
                        for(j=0;j<=llGetNumberOfPrims();j++){
                            llSetLinkColor(j,<color1.x-(color_difference.x*(float)i/(float)frame),color1.y-(color_difference.y*(float)i/(float)frame),color1.z-(color_difference.z*(float)i/(float)frame)>,ALL_SIDES);
                        }
                    }
                    llSetLinkColor(j,color2,ALL_SIDES);
                }
                else if(command=="ALPHA"){//___,ALPHA,alpha
                    float alpha=(float)llList2String(tmplist2,2)*0.01;
                    integer j;
                    for(j=0;j<=llGetNumberOfPrims();j++){
                        llSetLinkAlpha(j,alpha,ALL_SIDES);
                    }
                }
                else if(command=="ALPHA_ANIM"){//___,ALPHA_ANIM,alpha,alpha,second
                    float alpha1=(float)llList2String(tmplist2,2)*0.01;
                    float alpha2=(float)llList2String(tmplist2,3)*0.01;
                    float alpha_difference=alpha1-alpha2;
                    float second=(float)llList2String(tmplist2,4);
                    integer frame=(integer)(second/0.25);//(integer)llList2String(tmplist22,5);
                    if(second*frame==0){second=0.01;frame=1;}//どちらかが０の場合、一瞬で変化させる値を代入
                    integer i;
                    integer j;
                    for(i=0;i<=frame;i++){
                        llSleep(second/(float)frame);
                        for(j=0;j<=llGetNumberOfPrims();j++){
                            llSetLinkAlpha(j,alpha1-(alpha_difference*(float)i/(float)frame),ALL_SIDES);
                        }
                    }
                }
                else if(command=="MOVE"){//___,MOVE,<X,Y,Z>,<RX,RY,RZ>
                    vector tgt=(vector)llList2String(tmplist2,2);
                    vector angle=(vector)llList2String(tmplist2,3);
                    if(200>llVecDist(llGetPos(),tgt)){//２００ｍより遠い場合移動しない
                        llSetRegionPos(tgt);
                        llSetRot(llEuler2Rot(angle*DEG_TO_RAD));
                    }
                }
                else if(command=="MOVE_ANIM"){//___,MOVE_ANIM,<X,Y,Z>,<RX,RY,RZ>,<X,Y,Z>,<RX,RY,RZ>,second
                    vector startpos=(vector)llList2String(tmplist2,2);
                    rotation startrot=llEuler2Rot((vector)llList2String(tmplist2,3)*DEG_TO_RAD);
                    vector endpos=(vector)llList2String(tmplist2,4);
                    rotation endrot=llEuler2Rot((vector)llList2String(tmplist2,5)*DEG_TO_RAD);
                    float second=(float)llList2String(tmplist2,6);
                    integer frame=(integer)(second/0.25);
                    if(second*frame==0){second=0.01;frame=1;}//どちらかが０の場合、一瞬で変化させる値を代入
                    vector pos_difference=(endpos-startpos)/frame;
                    vector rot_difference=llRot2Euler(endrot/startrot)/frame;
                        if((200>llVecDist(llGetPos(),startpos))&&(200>llVecDist(llGetPos(),endpos))){//REZZERより２００ｍ遠い場合移動しない
                        llSetRegionPos(startpos);
                        integer i;
                        float tmp=second/frame;
                        for(i=0;i<=frame;i++){
                            //llOwnerSay("target="+(string)tgt);
                            llSetPrimitiveParams([PRIM_POSITION,startpos+(pos_difference*i),PRIM_ROTATION,llEuler2Rot(rot_difference*i)*startrot]);
                            if(tmp>0.2){
                                llSleep(tmp-0.2);
                            }
                        }
                    }
                }
                else{
                    //用意されていないメッセージは全て他のプリムに流す
                    //XXX,コマンド,パラメータ1,パラメータ２　→　コマンド名&param1&param2
                    llMessageLinked(LINK_THIS,0,llDumpList2String(llList2List(tmplist2,1,-1),"&"),"");
                }
            }
        }
}



//==============================================
default{
    state_entry(){
        if((llGetObjectDesc()=="")||(llGetObjectDesc()=="(No Description)")){
            llSetObjectDesc("OWNER");
        }
        llListen(COMMON_CHANNEL,"","","");
    }
    on_rez(integer num){
        llShout(COMMON_CHANNEL+1,"REZZED");
        float second=num*0.001;     //フェードイン秒数
        integer frame=(integer)(second/0.2);//フェードインフレーム数
        if(second*frame==0){return;}
        integer i;
        integer j;
        for(i=0;i<=frame;i++){
            for(j=0;j<=llGetNumberOfPrims();j++){
                llSetLinkAlpha(j,((float)i/(float)frame),ALL_SIDES);
            }
            llSleep(0.2);
        }
    }
    listen(integer chnl,string name,key id,string msg){
        //チャンネルチェック
        if(llGetSubString(msg,0,llStringLength(llGetObjectDesc()))!=llGetObjectDesc()+"\n"){
//            llOwnerSay("channelが違うのでリターン");
            return;
        }
        if((llGetObjectDesc()=="OWNER")||(llGetObjectDesc()=="owner")){
            if(llGetOwnerKey(id)!=llGetOwner()){return;}
        }
        //自分宛てコマンドチェック
        objname=llGetObjectName();
        if(llSubStringIndex(msg,"\n"+objname+",")==-1){
//            llOwnerSay("自分宛てコマンドがみつからないのでリターン");
            return;
        }

        //llOwnerSay("run: msg="+msg);
        Check(msg);
    }
    link_message(integer sender,integer num,string msg,key id){
        if((num==1)&&(id=="commands")){
            objname=llGetObjectName();
            Check(msg);
        }
    }
}