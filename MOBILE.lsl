//##########################################
//
//  CONTRO - #MOBILE
//
//  ver.2.1[2015/7/15]
//##########################################
//[ スクリの動作 ]
//１、長押しでダイアログを出す
//２、ベースとの相対化(PosMemory)する
//３、現地で絶対化(PosLoad)する
//
// [ PosMemoryのやり方 ]
//１、FrogFlagを基準点に移動させる
//３、インベントリーからMOBILE_BASEオブジェクトをREZする
//４、CONTROLLERオブジェクトを並べる
//５、MOBILE_BASEオブジェクトをルートプリムにしてリンクする
//６、ダイアログにしたがってPosMemoryを完了させる
//
// [ PosLoadのやり方 ]
//１、FrogFlagを基準点に移動させる
//２、MOBILE_BASEを長押ししてダイアログを出す
//３、ダイアログにしたがってPosLoadする
//
//====================================================
//[ input ]
// (COMMON_CHANNEL) chnlname,FLAG_INFO,llGetPos(),llGetRot()
//[output]
// (COMMON_CHANNEL) channelname,GET_FLAGPOS   [To FrogFlag]
// (link_message) 0,"POSMEMORY",rezzer_pos&rezzer_rot [to CHILDPRIMS] 子プリムへベースの位置を送り、相対化させる。
// (link_message) 0,"POSLOAD",rezzer_pos&rezzer_rot [to CHILDPRIMS] 子プリムへベースの位置を送り、絶対化させる。
//
//##########################################
integer COMMON_CHANNEL=1357246809; //共通リッスンチャンネル
string chnlname;  //チャンネル名(混線防止)

integer dlgchnl; //ダイアログ用リッスンチャンネル
integer lsnnum;
string DLG_POSMEMORY="POSMEMORYを行います。
FrogFlagをREZし基準点に移動したら
'POSMEMORY'ボタンを押してください";
string DLG_POSLOAD="POSLOADを行います。
FrogFlagをREZし基準点に移動したら
'POSLOAD'ボタンを押してください";
integer PosMemoryFlg=FALSE;

vector rezzer_pos=<0,0,0>;
rotation rezzer_rot=ZERO_ROTATION;

string timer_failed_msg;
integer touchcnt=0;

string MSG_ON_REZ="CONTROLLERをMOBILE_BASEとリンクさせてください。
MOBILE_BASEを最後に選択してルートプリムになるようにリンクしてください。";
string MSG_LINK_OK="リンクが完了しました。FrogFlagを任意の基準点に設置してください。";
string MSG_LINK_ERROR="×エラー：MOBILE_BASEがルートプリムになっていません、MOBILE_BASEを最後に選択してリンクしてください。";

integer controller_cnt;
integer controller_cnt2;
list controller_linknum;
string timer_mode;
integer controller_num=0;
//==============================================
default{
    state_entry(){
        controller_num=llGetObjectPrimCount(llGetKey());
        if(controller_num==1){
            llOwnerSay(MSG_ON_REZ);
        }else{
            dlgchnl=(integer)llFrand(1000000);
            lsnnum=llListen(dlgchnl,"",llGetOwner(),"");
            llDialog(llGetOwner(),DLG_POSMEMORY,["POSMEMORY","キャンセル"],dlgchnl);
            timer_mode="dialog";
            llSetTimerEvent(60);
        }
    }
    on_rez(integer num){
        if(!PosMemoryFlg){llOwnerSay(MSG_ON_REZ);}
    }
    changed(integer chg){
        if(chg & CHANGED_LINK){
            PosMemoryFlg=FALSE;
            if((llGetObjectDesc()=="")||(llGetObjectDesc()=="(No Description)")){
                if(llGetLinkPrimitiveParams(2,[PRIM_DESC])!=[""]){
                    llSetObjectDesc(llList2String(llGetLinkPrimitiveParams(2,[PRIM_DESC]),0));//子プリム１のDESCをコピー
                }else{
                    llSetObjectDesc("OWNER");
                }
            }
            controller_num=llGetObjectPrimCount(llGetKey());
            if(controller_num==1){
                PosMemoryFlg=FALSE;
            }else{
                if(llGetLinkNumber()==1){
                    llOwnerSay(MSG_LINK_OK);
                }else{
                    llOwnerSay(MSG_LINK_ERROR);
                }
            }
        }
    }
    touch_start(integer num){
        touchcnt=0;
    }
    touch(integer num){
        if(llDetectedKey(0)!=llGetOwner()){return;}
        ++touchcnt;
        if(touchcnt==60){
            llListenRemove(lsnnum);
            dlgchnl=(integer)llFrand(1000000);
            lsnnum=llListen(dlgchnl,"",llGetOwner(),"");
            if(PosMemoryFlg){
                llDialog(llGetOwner(),DLG_POSLOAD,["POSLOAD","キャンセル"],dlgchnl);
            }else{
                llDialog(llGetOwner(),DLG_POSMEMORY,["POSMEMORY","キャンセル"],dlgchnl);
            }
            timer_failed_msg="ダイアログの時間切れです。";
            llSetTimerEvent(60);
        }
    }

    listen(integer chnl,string name,key id,string msg){
        if(chnl==dlgchnl){
            if((msg=="POSMEMORY")||(msg=="POSLOAD")){
                llSetTimerEvent(0);
                llListenRemove(lsnnum);
                if(llGetNumberOfPrims()==1){
                    llOwnerSay("CONTROLLERがリンクされていません。");
                    return;
                }
                lsnnum=llListen(COMMON_CHANNEL+1,"","","");
                llShout(COMMON_CHANNEL+1,llGetObjectDesc()+",GET_FLAGINFO");
                llOwnerSay("FrogFlagを確認中・・・");
                timer_mode="checkflag";
                llSetTimerEvent(10);
            }
            if(msg=="キャンセル"){
                llListenRemove(lsnnum);
                llOwnerSay("キャンセルしました。");
            }
        }
        
        if(chnl==COMMON_CHANNEL+1){//chnlname+",FLAG_INFO,"+(string)llGetPos()+","+(string)llGetRot()
            list tmplist=llCSV2List(msg);
            chnlname=llList2String(tmplist,0);          //チャンネル名取得
            if(chnlname!=llGetObjectDesc()){return;}
            if(llList2String(tmplist,1)!="FLAG_INFO"){return;}
            llListenRemove(lsnnum);
            llSetTimerEvent(0);
            rezzer_pos=(vector)llList2String(tmplist,2);
            rezzer_rot=(rotation)llList2String(tmplist,3);
            if(!PosMemoryFlg){
                llOwnerSay("POSMEMORYを開始します・・・");
                controller_cnt=0;
                controller_cnt2=0;
        controller_linknum=[];
                timer_mode="pos_memory";
                llMessageLinked(LINK_SET,-1,"POSMEMORY",(string)rezzer_pos+"&"+(string)rezzer_rot);
                llSetTimerEvent(10);
            }else{
                llOwnerSay("POSLOADを開始します・・・");
                controller_cnt=0;
                controller_cnt2=0;
        controller_linknum=[];
                timer_mode="pos_load";
                llMessageLinked(LINK_SET,-1,"POSLOAD",(string)rezzer_pos+"&"+(string)rezzer_rot);
                llSetTimerEvent(10);
            }
        }
    }
    link_message(integer sender,integer num,string msg,key id){
        if(num==-1){
            if(msg=="PM_START"){
            controller_cnt++;
            controller_linknum+=(list)sender;
        }
            if(msg=="PM_END"){
            controller_cnt2++;
            integer find=llListFindList(controller_linknum,[sender]);
            if(find!=-1){controller_linknum=llDeleteSubList(controller_linknum,find,find);}
        }
            if(msg=="PL_START"){
            controller_cnt++;
            controller_linknum+=(list)sender;
        }
            if(msg=="PL_END"){
            controller_cnt2++;
            integer find=llListFindList(controller_linknum,[sender]);
            if(find!=-1){controller_linknum=llDeleteSubList(controller_linknum,find,find);}
        }
        }
    }
    timer(){
        llSetTimerEvent(0);
        llListenRemove(lsnnum);
        if(timer_mode=="pos_memory"){
            if(controller_cnt==controller_cnt2){
                llOwnerSay((string)controller_cnt2+" CONTROLLERのPOSMEMORYが完了しました。\n移動先でFrogFlagを設置し、MOBILE_BASEを長押ししてPOSLOADを行ってください。");
                PosMemoryFlg=TRUE;
            }else{
                string tmpstr;
                integer i;
                for(i=0;llList2String(controller_linknum,i)!="";i++){
                    tmpstr+="リンクナンバー"+llList2String(controller_linknum,i)+"のCONTROLLERが容量オーバーしています。\n";
                }
                llOwnerSay("×エラー：POSMEMORY失敗\n"+tmpstr+"該当CONTROLLERのコマンドを減らしてください。");
            }
            return;
        }
        if(timer_mode=="pos_load"){
            if(controller_cnt==controller_cnt2){
                llOwnerSay((string)controller_cnt+" CONTROLLERのPOSLOADが完了しました。\n問題がなければFrogFlagを撤去してください。");
            }else{
                string tmpstr;
                integer i;
                for(i=0;llList2String(controller_linknum,i)!="";i++){
                    tmpstr+="リンクナンバー"+llList2String(controller_linknum,i)+"のCONTROLLERが容量オーバーしています。\n";
                }
                llOwnerSay("×エラー：POSLOAD失敗\n"+tmpstr+"該当CONTROLLERのコマンドを減らしてPOSMEMORYからやり直してください。");
            }
            return;
        }
        if(timer_mode=="checkflag"){
            llOwnerSay("×エラー：FrogFlagが見つかりませんでした。チャンネル設定をご確認ください。FrogFlagは100ｍ以内に設置して下さい。");
            return;
        }
        if(timer_mode=="dialog"){
            llOwnerSay("ダイアログの時間切れです");
            return;
        }
    }
}