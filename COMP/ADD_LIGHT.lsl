//##########################################
//
//  CONTRO - #ADD_LIGHT
//
// ver.2.1[2015/7/15]
//##########################################
//[ スクリの動作 ]
//　光源の色・明るさをコントロールする
//
// [ コントローラーコマンド ]
// ___,LIGHT,色(vector),明るさ(0~1.0),半径(0-20.0),弱まる(0~2.0)             //全てのプリムの光源を変更
// ___,LIGHT_TARGET,ターゲットプリムのリンク番号(1~),色,明るさ,半径,弱まる　//ターゲットのプリムの光源を変更
//
//
//
//====================================================
//[input]
// (link_message) LIGHT&色(vector)&明るさ(0~1.0)&半径(0-20.0)&弱まる(0~2.0)             //全てのプリムの光源を変更
// (link_message) LIGHT_TARGET&ターゲットプリムのリンク番号(1~)&色&明るさ&半径&弱まる　//ターゲットのプリムの光源を変更
//
//
//##########################################
//明るさは、減衰は最低にして輝度のみで強さを決める。
float radius=20;
float falloff=0;

float intensity;

default{
    state_entry(){}
    link_message(integer sender,integer num,string msg,key id)
    {
        //-----------------------------------------------------------------------------
        //msgにコマンド名と複数のパラメーターが&区切りで送られてくるので
        //分割してリストdata_listに保存する。
        //コマンド名をチェックして好きな処理を実行する。
        //-----------------------------------------------------------------------------
        if(num!=0){return;}
        list data_list=llParseString2List(msg,["&"],[]);
        string command=llList2String(data_list,0);//比較用にコマンドは変数に入れる

        //コマンド名をチェックし操作を実行する
        if(command=="LIGHT"){//"LIGHT"&(vector)色&(float)明るさ
            vector color=((vector)llList2String(data_list,1))/255.0;
            intensity=(float)llList2String(data_list,2);
            radius=(float)llList2String(data_list,3);
            falloff=(float)llList2String(data_list,4);
            integer i;
            for(i=0;i<llGetNumberOfPrims();i++){
                if((color==<0,0,0>)||(intensity<=0)){
                    llSetLinkPrimitiveParamsFast((!!llGetLinkNumber())+i,[PRIM_POINT_LIGHT,FALSE,color,intensity,radius,falloff]);
                }else{
                    llSetLinkPrimitiveParamsFast((!!llGetLinkNumber())+i,[PRIM_POINT_LIGHT,TRUE,color,intensity,radius,falloff]);
                }
            }
        }
        if(command=="LIGHT_TARGET"){//"LIGHT_TARGET"&リンクナンバー&(vector)色&(float)明るさ
            integer linknum=(integer)llList2String(data_list,1);
            vector color=((vector)llList2String(data_list,2))/255.0;
            intensity=(float)llList2String(data_list,3);
            radius=(float)llList2String(data_list,3);
            falloff=(float)llList2String(data_list,4);
            if((color==<0,0,0>)||(intensity<=0)){
                llSetLinkPrimitiveParamsFast(linknum,[PRIM_POINT_LIGHT,FALSE,color,intensity,radius,falloff]);
            }else{
                llSetLinkPrimitiveParamsFast(linknum,[PRIM_POINT_LIGHT,TRUE,color,intensity,radius,falloff]);
            }
        }
    }
}