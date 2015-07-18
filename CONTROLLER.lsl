//##########################################
//
//  CONTRO - #CONTROLLER
//
//    ver.2.66 [2015/7/15]
//##########################################
//[ スクリの動作 ]
//１、ノートカードに書かれたコマンドをShoutする
//２、座標を相対化・絶対化する
//
//[ コマンド ]
//  
//
//====================================================
//[input]
// (link_message) 0,"POSMEMORY",""  [from MOBILE]  //MOBILEスクリから相対化の指示
// (link_message) 0,"POSLOAD",""  [from MOBILE]  //MOBILEスクリから絶対化の指示
//
//[output]
//
//channelname&
//{
// ___,REZ,<X,Y,Z>,<ROT_X,ROT_Y,ROT_Z>,second
// ___,DEL,second
// ___,COLOR,<R,G,B>
// ___,COLOR_ANIM,<R,G,B>,<R,G,B>,second
// ___,ALPHA,alpha
// ___,ALPHA_ANIM,alpha,alpha,second
// ___,MOVE,<X,Y,Z>,<ROT_X,ROT_Y,ROT_Z>
// ___,MOVE_ANIM,<X,Y,Z>,<ROT_X,ROT_Y,ROT_Z>,<X,Y,Z>,<ROT_X,ROT_Y,ROT_Z>,second
// ___,WAIT,second
// ___,SAY,channel,message
// ___,SHOUT,channel,message
// ___,好きなコマンド,好きな文字列
//}
//##########################################
integer COMMON_CHANNEL=1357246809; //共通リッスンチャンネル
//integer COMMON_CHANNEL=0; //共通リッスンチャンネル
string NOTENAME="commands";
string MSG_LOADING="コマンドを読み込み中です、少々おまちください";

list commandlist=[]; //ノートカードから読み込んだコマンドのリスト
list say_list; //SAY,SHOUTコマンド用
list timer_list; //WAITコマンド用
string command_source;
string command_buffer;
list command_pos_list;//ストライドリスト　 素の文字列,相対座標
list command_ang_list;//ストライドリスト　 素の文字列,相対座標

integer command_index;
key lastnotecardkey;
key req_note;
integer noteline; //現在の読み込み行
integer jointflg;
string jointstrings;
integer loadingflg;
integer runflg;
integer posmemoryflg=FALSE;
integer posloadflg=FALSE;
integer touch_cnt;



//==============================================
Run(){
    if(loadingflg){llOwnerSay(MSG_LOADING);return;}
    if(posmemoryflg&&!posloadflg){llOwnerSay("POSLOADを行ってください。");return;}
    string chnlname=llGetObjectDesc();//チャンネル名取得
    integer i;
    list tmplist;

    //SAY_LISTチェック
    if(llList2String(say_list,command_index)!=" "){
        //llOwnerSay("turn"+(string)command_index+" say_list="+llDumpList2String(say_list,"&"));
        tmplist=llParseString2List(llList2String(say_list,command_index),["\n"],[]);
        for(i=0;llList2String(tmplist,i)!="";i=i+3){
            if(llList2String(tmplist,i)=="SA"){
                llSay(llList2Integer(tmplist,i+1),llList2String(tmplist,i+2));
            }
            if(llList2String(tmplist,i)=="SH"){
                llShout(llList2Integer(tmplist,i+1),llList2String(tmplist,i+2));
            }
        }
    }

    //コマンド再生
    if(llList2String(commandlist,command_index)!=" "){
        tmplist=llParseString2List(llList2String(commandlist,command_index),["&"],[]);
        for(i=0;i<llGetListLength(tmplist);i++){
            llShout(COMMON_CHANNEL,chnlname+"\n"+llList2String(tmplist,i));
            llMessageLinked(LINK_THIS,-1,chnlname+"\n"+llList2String(tmplist,i),"cmd");
        }
    }

    //コマンド続きあるならタイマーセット    
    if(command_index<llGetListLength(commandlist)-1){
        float tmp_float=llList2Float(timer_list,command_index);
        if(tmp_float==0){tmp_float=0.01;}
        llSetTimerEvent(tmp_float);
    }else{
        runflg=FALSE;
    }
    ++command_index;
}

ReplacePosAng(string from, string to)
{//replaces all occurrences of 'from' with 'to' in 'src'.
    integer len = (~-(llStringLength(from)));
    if(~len)
    {
        string  buffer = command_buffer;
        integer b_pos = ERR_GENERIC;
        integer to_len = (~-(llStringLength(to)));
        @loop;//instead of a while loop, saves 5 bytes (and runs faster).
        integer to_pos = ~llSubStringIndex(buffer, from);
        if(to_pos)
        {
//            b_pos -= to_pos;
//            command_buffer = llInsertString(llDeleteSubString(command_buffer, b_pos, b_pos + len), b_pos, to);
//            b_pos += to_len;
//            buffer = llGetSubString(command_buffer, (-~(b_pos)), 0x8000);
            buffer = llGetSubString(command_buffer = llInsertString(llDeleteSubString(command_buffer, b_pos -= to_pos, b_pos + len), b_pos, to), (-~(b_pos += to_len)), 0x8000);
            jump loop;
        }
    }
}
string Vec2Str(vector tgt){
    return "<"+llGetSubString((string)(tgt.x),0,-5)+","+llGetSubString((string)(tgt.y),0,-5)+","+llGetSubString((string)(tgt.z),0,-5)+">";
}

MakeCommandlist(){
            //分割
            integer readcnt=0;
            string tmpcommand;
            string tmp_say_shout;
            integer length_over_cnt=0;
            integer i;
            for(i=0;i<1000;i++){
                //1行ずつ調べて追加いく
                string readline=llGetSubString(command_buffer,readcnt,readcnt+770);
                integer search=llSubStringIndex(readline,"\n");

                if(search!=-1){
                    readcnt+=search+1;
                    readline=llGetSubString(readline,0,search);
                }else{//EOF
                    i=2000;
                    readline=llGetSubString(readline,0,-1);
                }
                //１行取得終了            
                list tmplist=llParseString2List(readline,[","],[]);//チェックする
                if(llList2String(tmplist,0)=="WAIT"){//WAITが見つかったので格納
                    if(tmpcommand==""){tmpcommand=" ";}
                    if(tmp_say_shout==""){tmp_say_shout=" ";}
                    commandlist+=[tmpcommand];
                    say_list+=[tmp_say_shout];
                    timer_list+=llList2Float(tmplist,1);
                    tmpcommand="";
                    tmp_say_shout="";
                    length_over_cnt=0;
                }else{
                    //SAYとSHOUTは除く
                    if(llList2String(tmplist,0)=="SAY"){
                        tmp_say_shout+="SA\n"+llList2String(tmplist,1)+"\n"+llList2String(tmplist,2);
                    }else if(llList2String(tmplist,0)=="SHOUT"){
                        tmp_say_shout+="SH\n"+llList2String(tmplist,1)+"\n"+llList2String(tmplist,2);
                    }else{//普通のコマンドなので長さチェックして格納
                        if(llStringLength(tmpcommand)+llStringLength(readline)>990+(990*length_over_cnt)){//1000超える場合分分割マークの＆をつけておく
                            tmpcommand+="&"+readline;
                            length_over_cnt++;
                        }else{
                            tmpcommand+=readline;
                        }
                    }
                }
            
                //終了なら格納
                if(i==2000){
		    command_buffer="";
                    if((tmpcommand!="")||(tmp_say_shout!="")){
                        if(tmpcommand==""){tmpcommand=" ";}
                        if(tmp_say_shout==""){tmp_say_shout=" ";}                    
                        commandlist+=[tmpcommand];
                        say_list+=[tmp_say_shout];
                    }
                }
            }
}
//===============================================
default{
    state_entry(){
        if((llGetObjectDesc()=="")||(llGetObjectDesc()=="(No Description)")){
            llSetObjectDesc("OWNER");
        }
        loadingflg=TRUE;
        req_note=llGetNotecardLine(NOTENAME,0);
        lastnotecardkey=llGetInventoryKey(NOTENAME);
    }
    touch_start(integer num){
        if((llDetectedKey(0)!=llGetOwner())||(llGetListLength(commandlist)==0)){return;}
        touch_cnt=0;
    }
    touch(integer num){
        if((llDetectedKey(0)!=llGetOwner())||(llGetListLength(commandlist)==0)){return;}
        ++touch_cnt;
        if(touch_cnt==60){
            llOwnerSay("ストップしました");
            llSetTimerEvent(0);
        }
    }
    touch_end(integer num){
        if((llDetectedKey(0)!=llGetOwner())||(llGetListLength(commandlist)==0)){return;}
        if(touch_cnt<60){
			command_index=0;
			runflg=TRUE;
			Run();
		}
    }


    timer(){
        llSetTimerEvent(0);
        Run();
    }
    changed(integer chg){
        if(chg & CHANGED_INVENTORY){
            if(lastnotecardkey!=llGetInventoryKey(NOTENAME)){//ノートが変更されたので読み込む
                lastnotecardkey=llGetInventoryKey(NOTENAME);
                commandlist=[];
                say_list=[];
                timer_list=[];                
                command_source="";
                command_pos_list=[];
                command_ang_list=[];
                noteline=0;
                jointflg=FALSE;
                jointstrings="";
                loadingflg=TRUE;
                posmemoryflg=FALSE;
                posloadflg=FALSE;
                llSetText("",<1,1,1>,0);
                req_note=llGetNotecardLine(NOTENAME,0);
            }
        }
    }
    dataserver(key reqid,string data){
        if(reqid==req_note){
            if(data!=EOF){
                if(llStringLength(data)>=255){llOwnerSay("#ERROR#"+(string)(noteline+1)+"行目 :コマンドは1行あたり255文字未満にしてください。");}
                if(data!=""){
                    if(llGetSubString(data,0,0)!="\""){
                        //pos() ang()　保存しておく
                        list tmplist=llParseString2List(data,["pos("],[]);
                        integer i;
                        string tmp;
                        for(i=1;i<llGetListLength(tmplist);i++){
                            tmp=llGetSubString(llList2String(tmplist,i),0,llSubStringIndex(llList2String(tmplist,i),")")-1);
                            if(llListFindList(command_pos_list,(list)tmp)==-1){
                                command_pos_list+=[tmp,<0,0,0>];//128,128,20|<1.0000,0.0000,0.0000> //絶対<>無し文字列|相対
                            }
                        }
                        tmplist=llParseString2List(data,["ang("],[]);
                        for(i=1;i<llGetListLength(tmplist);i++){
                            tmp=llGetSubString(llList2String(tmplist,i),0,llSubStringIndex(llList2String(tmplist,i),")")-1);
                            if(llListFindList(command_ang_list,(list)tmp)==-1){
                                command_ang_list+=[tmp,ZERO_ROTATION];//0,0,90|rotation //絶対<>無し文字列|相対
                            }
                        }
                        //,終わりは複数行コマンドなのでつなげる
                        if(llGetSubString(data,-1,-1)==","){
                            jointflg=TRUE;
                            jointstrings+=data;
                        }else{
                            if(jointflg){
                                if(command_source!=""){data="\n"+data;}
                                command_source+=jointstrings+data;
                                jointflg=FALSE;
                                jointstrings="";
                            }else{
                                if(command_source!=""){data="\n"+data;}
                                command_source+=data;
                            }
                        }
                    }else{
                        llSetText(llGetSubString(data,1,llStringLength(data)-2),<1,1,1>,1);
                    }
                }
                noteline++;
                req_note=llGetNotecardLine(NOTENAME,noteline);
            }else{

				jointstrings="";
                //pos()を抜き出して置換
                command_buffer=command_source;
                integer i;
                
                for(i=0;i<1000;i++){
                    integer search1=llSubStringIndex(command_buffer,"pos(");
                    if(search1==-1){
                        i=2000;
                    }else{
                        command_buffer=llInsertString(llDeleteSubString(command_buffer,search1,search1+3),search1,"<");
                        string tmpstr=llGetSubString(command_buffer,search1,search1+100);
                        integer search2=llSubStringIndex(tmpstr,")");
                        if(search2!=-1){
                            command_buffer=llInsertString(llDeleteSubString(command_buffer,search1+search2,search1+search2),search1+search2,">");
                        }
                    }
                }

                //ang()を抜き出して置換
                for(i=0;i<1000;i++){
                    integer search1=llSubStringIndex(command_buffer,"ang(");
                    if(search1==-1){
                        i=2000;
                    }else{
                        command_buffer=llInsertString(llDeleteSubString(command_buffer,search1,search1+3),search1,"<");
                        string tmpstr=llGetSubString(command_buffer,search1,search1+100);
                        integer search2=llSubStringIndex(tmpstr,")");
                        if(search2!=-1){
                            command_buffer=llInsertString(llDeleteSubString(command_buffer,search1+search2,search1+search2),search1+search2,">");
                        }
                    }
                }

                MakeCommandlist();
                //llOwnerSay("buffer="+command_buffer);
                //llOwnerSay("poslist="+llDumpList2String(command_pos_list,"\n"));
                //llOwnerSay("anglist="+llDumpList2String(command_ang_list,"\n"));
                //llOwnerSay("cmdlist="+llDumpList2String(commandlist,"\n"));
                
                loadingflg=FALSE;
            }
        }
    }
    link_message(integer sender,integer num,string msg,key id){
        if((msg=="RUN")&&(num==llGetLinkNumber())){
            command_index=0;
            runflg=TRUE;
            Run();
        }
        if(msg=="POSMEMORY"){
            llMessageLinked(LINK_ROOT,-1,"PM_START","");
            if(loadingflg){llOwnerSay(MSG_LOADING);return;}
            if(runflg){runflg=FALSE;llSetTimerEvent(0);}
            list tmplist=llParseString2List(id,["&"],[]);//<128,128,20>&rotation
            vector flag_pos=(vector)llList2String(tmplist,0);
            rotation flag_rot=(rotation)llList2String(tmplist,1);
            vector relpos;
            integer i;
            //llOwnerSay("cmdposlist="+(string)llGetListLength(command_pos_list));
            for(i=0;i<llGetListLength(command_pos_list);i+=2){
                relpos=((vector)("<"+llList2String(command_pos_list,i)+">")-flag_pos)/flag_rot;
                command_pos_list=llListReplaceList(command_pos_list,(list)relpos,i+1,i+1);
                //llOwnerSay("pos_list_i="+llList2String(command_pos_list,i)+"\nrelpos="+(string)relpos);
            }
            for(i=0;i<llGetListLength(command_ang_list);i+=2){
                rotation relrot=llEuler2Rot((vector)("<"+llList2String(command_ang_list,i)+">")*DEG_TO_RAD)/flag_rot;
                command_ang_list=llListReplaceList(command_ang_list,(list)relrot,i+1,i+1);
            }
            //llOwnerSay("poslist="+llDumpList2String(command_pos_list,"\n"));
            //llOwnerSay("anglist="+llDumpList2String(command_ang_list,"\n"));
            llMessageLinked(LINK_ROOT,-1,"PM_END","");
            posmemoryflg=TRUE;
        }
        if(msg=="POSLOAD"){
            if(!posmemoryflg){llOwnerSay("先にPOSMEMORYを行ってください。　");return;}
            llMessageLinked(LINK_ROOT,-1,"PL_START","");
            if(loadingflg){llOwnerSay(MSG_LOADING);return;}
            if(runflg){runflg=FALSE;llSetTimerEvent(0);}
            list tmplist=llParseString2List(id,["&"],[]);//<128,128,20>&<0,0,0,1>
            vector flag_pos=(vector)llList2String(tmplist,0);
            rotation flag_rot=(rotation)llList2String(tmplist,1);
            
            command_buffer=command_source;

            integer i;
            for(i=0;i<llGetListLength(command_pos_list);i+=2){//絶対座標変換
                vector abspos=flag_pos+(llList2Vector(command_pos_list,i+1)*flag_rot);
                ReplacePosAng("pos("+llList2String(command_pos_list,i)+")",Vec2Str(abspos));
                //llOwnerSay("abspos_i("+(string)i+")="+(string)abspos);
            }
            for(i=0;i<llGetListLength(command_ang_list);i+=2){
                vector absang=llRot2Euler(llList2Rot(command_ang_list,i+1)*flag_rot)*RAD_TO_DEG;
                ReplacePosAng("ang("+llList2String(command_ang_list,i)+")",Vec2Str(absang));
                //llOwnerSay("absrot_i("+(string)i+")="+absang);
            }

            //llOwnerSay("poslist="+llDumpList2String(command_pos_list,"\n"));
            //llOwnerSay("anglist="+llDumpList2String(command_ang_list,"\n"));
            //llOwnerSay("cmdlist="+llDumpList2String(commandlist,"\n"));

            commandlist=[];
            say_list=[];
            timer_list=[];
            MakeCommandlist();
            //llOwnerSay("buffer="+command_buffer);
            llMessageLinked(LINK_ROOT,-1,"PL_END","");
            posloadflg=TRUE;
        }
    }
}