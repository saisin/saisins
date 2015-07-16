//##########################################
//
//  CONTRO - #ADD_PRIM
//
// ver.2.1[2015/7/15]
//##########################################
//[ スクリの動作 ]
// 基本コマンドで出来ないプリム操作あれこれ
//
//
// [ コントローラーコマンド ]
// ___,SCALE,スケール                                        //スケールを変更する。(５０で半分、１００で変化なし、２００で２倍)
// ___,SCALE_TARGET,リンクナンバー,スケール(<X,Y,Z>)  //指定プリムのスケールを<X,Y,Z>に変更する。
// ___,COLOR_TARGET,リンクナンバー,面,色(<R,G,B>)            //指定プリム・面の色を変更する
// ___,ALPHA_TARGET,リンクナンバー,面,アルファ(0~100)        //指定プリム・面の透過度を変更する
// ___,GLOW_TARGET,リンクナンバー,面,明るさ(0~100)            //指定プリム・面のグロー値を変更する
// ___,TEXTURE_TARGET,リンクナンバー,面,テクスチャ名,repeats(<X,Y,Z>),offsets(<X,Y,Z>),rotation(0~360) //指定プリム・面のテクスチャーを変更する
// ___,GLOW,明るさ(0~100)                                  //オブジェクト全体のグロー値を変更する
// ___,TEXTURE,面,テクスチャ名                            //オブジェクト全体のテクスチャーを変更する
// ___,PHYSICS,ON/OFF                                    //オブジェクトの物理属性を変更する
// ___,PHANTOM,ON/OFF                                    //オブジェクトのファントム属性を変更する
// ___,FULLBRIGHT,ON/OFF                                //オブジェクトのフルブライト属性を変更する
// ___,SETOMEGA,回転軸(<x,y,z>),回転のはやさ(0~10.0) //オブジェクトを回転させる
// ___,IMPULSE,飛ぶ方向[<X,Y,Z>]                       //指定した方向に飛ぶ（飛ぶ方向はワールド座標）
// ___,IMPULSE2,飛ぶ方向[<X,Y,Z>]                       //指定した方向に飛ぶ（飛ぶ方向はローカル座標）
//
//
////====================================================
// [input]
// (link_message) SCALE&scale
// (link_message) SCALE_TARGET&scale_vec
// (link_message) COLOR_TARGET&linknum&face&color
// (link_message) ALPHA_TARGET&linknum&face&alpha
// (link_message) GLOW_TARGET&linknum&face&brightness
// (link_message) TEXTURE_TARGET&linknum&face&texturename&repeats&offsets&rotation
// (link_message) GLOW&brightness
// (link_message) TEXTURE&face&texturename
//
// (link_message) PHYSICS&ON/OFF
// (link_message) PHANTOM&ON/OFF
// (link_message) FULLBRIGHT&ON/OFF
// (link_message) OMEGA&vector&speed
// (link_message) IMPULSE&world_vector
// (link_message) IMPULSE2&local_vector
//
//##########################################


//================================================
integer GetFace(string tgt){
    integer ret;
    if(tgt=="ALL_SIDES"){
        ret=-1;
    }else{
        ret=(integer)tgt;
    }
    return ret;
}

//================================================
default
{
    state_entry(){}

    link_message(integer sender,integer num,string msg,key id)
    {
        if(num!=0){return;}
        list tmplist=llParseString2List(msg,["&"],[]);
        string command=llList2String(tmplist,0);

        //----コマンドごとの処理
        if(command=="SCALE"){//SCALE,(1~10000)%
            llScaleByFactor((float)llList2String(tmplist,1)*0.01);
            return;
        }
        if(command=="SCALE_TARGET"){//SCALE_TARGET,linknum,scale(<X,Y,Z>)
            llSetLinkPrimitiveParamsFast((integer)llList2String(tmplist,1),[PRIM_SIZE,(vector)llList2String(tmplist,2)]);
            return;
        }
        if(command=="GLOW"){//GLOW,brightness(0-1.0)
            float brightness=(float)llList2String(tmplist,1);
            integer j;
            for(j=0;j<=llGetNumberOfPrims();j++){
                llSetLinkPrimitiveParamsFast(j,[PRIM_GLOW,ALL_SIDES,brightness]);
            }
            return;
        }
        if(command=="TEXTURE"){//face,texturename
            integer face=GetFace(llList2String(tmplist,1));
            llSetTexture(llList2String(tmplist,2),face);
            return;
        }
        if(command=="PHYSICS"){
            integer tmp=1;
            if(llList2String(tmplist,1)!="ON"){tmp=0;}
            llSetStatus(STATUS_PHYSICS,tmp);
            return;
        }
        if(command=="IMPULSE"){
            llApplyImpulse((vector)llList2String(tmplist,1)*llGetObjectMass(llGetKey()),FALSE);
        }
        if(command=="IMPULSE2"){
            llApplyImpulse((vector)llList2String(tmplist,1)*llGetObjectMass(llGetKey()),TRUE);
        }
        if(command=="OMEGA"){//OMEGA,<0,0,1>,speed
            llTargetOmega((vector)llList2String(tmplist,1),(float)llList2String(tmplist,2),(float)llList2String(tmplist,2));
        }
        if(command=="PHANTOM"){
            integer tmp=1;
            if(llList2String(tmplist,1)!="ON"){tmp=0;}
            llSetStatus(STATUS_PHANTOM,tmp);
            return;
        }
        if(command=="FULLBRIGHT"){
            integer tmp=1;
            if(llList2String(tmplist,1)!="ON"){tmp=0;}
            integer j;
            for(j=0;j<=llGetNumberOfPrims();j++){
                llSetLinkPrimitiveParamsFast(j,[PRIM_FULLBRIGHT,ALL_SIDES,tmp]);
            }
            return;
        }

        if(command=="COLOR_TARGET"){//linknum,face,color
            integer face=GetFace(llList2String(tmplist,2));
            llSetLinkColor((integer)llList2String(tmplist,1),((vector)llList2String(tmplist,3))/255.0,face);
            return;
        }
        if(command=="ALPHA_TARGET"){//linknum,face,alpha
            integer face=GetFace(llList2String(tmplist,2));
            llSetLinkAlpha((integer)llList2String(tmplist,1),1.0-(0.01*(float)llList2String(tmplist,3)),face);
            return;
        }
        if(command=="GLOW_TARGET"){//linknum,face,brightness
            integer face=GetFace(llList2String(tmplist,2));
            llSetLinkPrimitiveParamsFast((integer)llList2String(tmplist,1),[PRIM_GLOW,face,(float)llList2String(tmplist,3)]);
            return;
        }
        if(command=="TEXTURE_TARGET"){//linknum,face,texturename,repeats,offsets,rotation
            integer face=GetFace(llList2String(tmplist,2));
            llSetLinkPrimitiveParamsFast((integer)llList2String(tmplist,1),[PRIM_TEXTURE,face,llList2String(tmplist,3),(vector)llList2String(tmplist,4),(vector)llList2String(tmplist,5),(float)llList2String(tmplist,6)]);
            return;
        }
    }
}