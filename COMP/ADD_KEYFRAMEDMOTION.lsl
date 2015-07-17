//##########################################
//
//  CONTRO - #ADD_KEYFRAMEDMOTION
//
// ver.2.1[2015/7/15]
//##########################################
//[ スクリの動作 ]
//キーフレームドモーション用追加スクリ
//MOVE_ANIMと違い、移動中のウェイトがありません
//ただし、移動中にMOVEやMOVE_ANIMを使うとエラーが出ます
//また、ラグによって時間内に移動が終わらない事があります
//
//
// [ コマンド ]
// ___,KFM_FORWARD,pos(),ang(),second,pos(),ang(),,,
// ___,KFM_LOOP,pos(),ang(),second,pos(),ang(),,,
// ___,KFM_PING_PONG,pos(),ang(),second,pos(),ang(),,,
// ___,KFM_REVERSE,pos(),ang(),second,pos(),ang(),,,
// ___,KFM_STOP
// ___,KFM_LIMIT,ON/OFF
//
//
//====================================================
//[input]
// (link_message) KFM_FORWARD&pos()&ang() [&second&pos()&ang()],,,
// (link_message) KFM_LOOP&pos()&ang() [&second&pos()&ang()],,,
// (link_message) KFM_PING_PONG&pos()&ang() [&second&pos()&ang()],,,
// (link_message) KFM_REVERSE&pos()&ang() [&second&pos()&ang()],,,
// (link_message) KFM_STOP
//
//
//##########################################
list KFM_CMD=["KFM_FORWARD","KFM_LOOP","KFM_PING_PONG","KFM_REVERSE","KFM_STOP"];
string MSG_ERROR_PARAM_NUMBERS_1="#ERROR#次のコマンドはパラメータ数が間違っている為実行しません。\n\"";
string MSG_ERROR_PARAM_NUMBERS_2="\"";
string MSG_ERROR_TOO_FAR="#ERROR#キーフレームドモーションの移動は1コマンド100m以内にしてください。";
string MSG_ERROR_TOO_FAR_2="#ERROR#現在位置から100m以上離れた場所への指定はできません。";
string MSG_ERROR_KFM_LOOP="#ERROR#KFM_LOOPの最初と最後の座標が一致しない為実行しません。";
integer limit_flg=TRUE;

//=========================================================
list GetDifference(list data){
    //data=(vector)pos,(vector)angle,second,(vector)pos,(vector)angle,second,,,
    //位置・角度差分を計算して返す
    list differ;
    integer i;
    vector lastpos=(vector)llList2String(data,0);
    rotation lastrot=(rotation)llEuler2Rot((vector)llList2String(data,1)*DEG_TO_RAD);
    for(i=2;i<llGetListLength(data);i=i+3){
        vector tmpvec=(vector)llList2String(data,i+1)-lastpos;
        if((llVecMag(tmpvec)>100)&&(limit_flg)){
            llOwnerSay(MSG_ERROR_TOO_FAR);
            differ=[<0,0,0>,ZERO_ROTATION,0.2,<0,0,0>,ZERO_ROTATION,0.2];
            i=1000;
        }else{
            differ+=(list)(tmpvec);
            differ+=(list)((rotation)llEuler2Rot((vector)llList2String(data,i+2)*DEG_TO_RAD)/lastrot);
            differ+=(list)(((float)llList2String(data,i)*45)/45.0);
            lastpos=(vector)llList2String(data,i+1);
            lastrot=(rotation)llEuler2Rot((vector)llList2String(data,i+2)*DEG_TO_RAD);
        }
    }
    return differ;
}


default{
    state_entry(){
        llSetPrimitiveParams([PRIM_PHYSICS_SHAPE_TYPE, PRIM_PHYSICS_SHAPE_CONVEX]);
        llSetKeyframedMotion([],[]);
    }
    link_message(integer sender,integer num,string msg,key id)
    {
        //-----------------------------------------------------------------------------
        //msgにコマンド名と複数のパラメーターが&区切りで送られてくるので
        //分割してリストdata_listに保存する。
        //コマンド名をチェックして好きな処理を実行する。
        //-----------------------------------------------------------------------------
        if(num!=0){
            return;
        }
        list data_list=llParseString2List(msg,["&"],[]);
        string command=llList2String(data_list,0);//比較用にコマンドは変数に入れる

        //コマンド名をチェックし操作を実行する
        if(llListFindList(KFM_CMD,(list)command)!=-1){
            llSetKeyframedMotion([],[]);
            if(command=="KFM_STOP"){llSetKeyframedMotion([],[KFM_COMMAND,KFM_CMD_STOP]);return;}
            integer mode;
            if(command=="KFM_FORWARD"){mode=KFM_FORWARD;}
            if(command=="KFM_LOOP"){mode=KFM_LOOP;
                if((llList2String(data_list,1)!=llList2String(data_list,-2))||(llList2String(data_list,2)!=llList2String(data_list,-1))){//ループは最初と最後の座標・角度が一致しない場合実行しない
                    llOwnerSay(MSG_ERROR_KFM_LOOP);
                    return;
                }
            }
            if(command=="KFM_PING_PONG"){mode=KFM_PING_PONG;}
            vector tgtvec=(vector)llList2String(data_list,1);
            if(command=="KFM_REVERSE"){mode=KFM_REVERSE; tgtvec=(vector)llList2String(data_list,-2);}
            if((llVecMag(llGetPos()-tgtvec)>110)&&(limit_flg)){
                llOwnerSay(MSG_ERROR_TOO_FAR_2);
                return;
            }
            if(((llGetListLength(data_list)-3)%3)==0){//簡易構文チェック
                llSetRegionPos(tgtvec);
                if(command!="KFM_REVERSE"){
                    llSetRot(llEuler2Rot((vector)llList2String(data_list,2)*DEG_TO_RAD));
                }else{
                    llSetRot(llEuler2Rot((vector)llList2String(data_list,-1)*DEG_TO_RAD));
                }
                llSetKeyframedMotion(GetDifference(llList2List(data_list,1,llGetListLength(data_list))),[KFM_MODE,mode]);
                llSetKeyframedMotion([],[KFM_COMMAND,KFM_CMD_PLAY]);
            }else{
                llOwnerSay(MSG_ERROR_PARAM_NUMBERS_1+llDumpList2String(data_list,",")+MSG_ERROR_PARAM_NUMBERS_2);
            }
        }
    }
}