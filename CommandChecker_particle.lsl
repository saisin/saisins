//##########################################
//
//  CONTRO - CommandChecker_particle
//
// ver.2.1[2015/7/15]
//##########################################
//---- パーティクルマスク
integer PART_EMISSIVE_MASK;     //PSYS_PART_EMISSIVE_MASK;          明るさ全開にする
integer PART_INTERP_COLOR_MASK; //PSYS_PART_INTERP_COLOR_MASK;      色の変化を使う
integer PART_INTERP_SCALE_MASK; //PSYS_PART_INTERP_SCALE_MASK;      サイズの変化を使う
integer PART_WIND_MASK;         //PSYS_PART_WIND_MASK;              風の影響を受ける
integer PART_BOUNCE_MASK;       //PSYS_PART_BOUNCE_MASK;            オブジェクトのZ座標より下にいかなくなる。はねたりさせる
integer PART_FOLLOW_SRC_MASK;   //PSYS_PART_FOLLOW_SRC_MASK;        オブジェクトを動かすと一緒に動く
integer PART_FOLLOW_VELOCITY_MASK;//PSYS_PART_FOLLOW_VELOCITY_MASK; パーティクルに進行方向を向かせる
integer PART_TARGET_LINEAR_MASK;//PSYS_PART_TARGET_LINEAR_MASK;     ターゲットを直線的に追う
integer PART_TARGET_POS_MASK;   //PSYS_PART_TARGET_POS_MASK;        ターゲットを曲線的に追う

//---- パーティクルパラメーター
integer PART_PATTERN;
  //PSYS_SRC_PATTERN_EXPLODE        ＜爆発＞　球状に放射
  //PSYS_SRC_PATTERN_ANGLE_CONE     ＜アングルコーン＞　球状、半球状、円錐状に放射
  //PSYS_SRC_PATTERN_ANGLE          ＜アングル＞　円状、半円状に放射
  //PSYS_SRC_PATTERN_DROP           ＜ドロップ＞　速度ゼロで出す
float PART_START_ALPHA;         //発生時のアルファ度(0~1,   0で透明)
float PART_END_ALPHA;           //消滅時のアルファ度
vector PART_START_COLOR;        //発生時の色
vector PART_END_COLOR;          //消滅時の色
vector PART_START_SCALE;        //発生時のサイズ
vector PART_END_SCALE;          //消滅時のサイズ
float SRC_MAX_AGE;              //放出しつづける時間秒(0でずっと放出)
float PART_MAX_AGE;             //放出から消えるまでの時間秒(0~30)
vector PART_ACCEL;              //加速度
float PART_ANGLE_BEGIN;         //半球、半円の開始角度指定
float PART_ANGLE_END;           //半球、半円の終了角度指定
integer PART_BURST_COUNT;       //放出される数
float PART_BURST_RADIUS;        //放出する際、オブジェクトからこの分だけ離す
float PART_BURST_RATE;          //放出する間隔(0で最小間隔)
float PART_BURST_SPEED_MIN;     //放出する速度の下限値
float PART_BURST_SPEED_MAX;     //放出する速度の上限値
vector PART_OMEGA;              //放出する角度が毎秒この角度で回転していく
string PART_TEXTURE;            //パーティクルのテクスチャー
key PART_TARGET_KEY;            //パーティクルに追跡させる場合の対象キー
integer PART_BLEND_FUNC_SOURCE; //パーティクルブレンディングのSOURCE
integer PART_BLEND_FUNC_DEST;   //パーティクルブレンディングのDEST
//PSYS_PART_BF_ONE;
//PSYS_PART_BF_ZERO;
//PSYS_PART_BF_DEST_COLOR;
//PSYS_PART_BF_SOURCE_COLOR
//PSYS_PART_BF_ONE_MINUS_DEST_COLOR
//PSYS_PART_BF_ONE_MINUS_SOURCE_COLOR
//PSYS_PART_BF_SOURCE_ALPHA
//PSYS_PART_BF_ONE_MINUS_SOURCE_ALPHA

integer INT_PARTICLE=1978532;
key target_key;

default{
    state_entry(){}
    link_message(integer sender,integer num,string msg,key id)
    {
        if(num!=INT_PARTICLE){return;}
        target_key=id;        
        if(msg=="PART_START"){
            PART_EMISSIVE_MASK=PSYS_PART_EMISSIVE_MASK;
            PART_INTERP_COLOR_MASK=PSYS_PART_INTERP_COLOR_MASK;
            PART_INTERP_SCALE_MASK=PSYS_PART_INTERP_SCALE_MASK;
            PART_WIND_MASK=0;
            PART_BOUNCE_MASK=0;
            PART_FOLLOW_SRC_MASK=0;
            PART_FOLLOW_VELOCITY_MASK=PSYS_PART_FOLLOW_VELOCITY_MASK;
            PART_TARGET_LINEAR_MASK=PSYS_PART_TARGET_LINEAR_MASK;
            PART_TARGET_POS_MASK=0;//PSYS_PART_TARGET_POS_MASK;

            PART_PATTERN = PSYS_SRC_PATTERN_EXPLODE;
            PART_START_ALPHA = 1.0;
            PART_END_ALPHA = 1.0;
            PART_START_COLOR = <1,0.7,1>;
            PART_END_COLOR = <1,0.5,1>;
            PART_START_SCALE = <0.07,1,0>;
            PART_END_SCALE = <0.07,0.5,0>;
            SRC_MAX_AGE = 3;
            PART_MAX_AGE = 0.3;
            PART_ACCEL = <0,0,0>;
            PART_ANGLE_BEGIN = 0;
            PART_ANGLE_END = PI;
            PART_BURST_COUNT = 30;
            PART_BURST_RADIUS = 0;
            PART_BURST_RATE = 0.0;
            PART_BURST_SPEED_MIN = 3;
            PART_BURST_SPEED_MAX = 3;
            PART_OMEGA = <0.0,0.0,0.0>;
            PART_TEXTURE = NULL_KEY;
            PART_TARGET_KEY = target_key;
            PART_BLEND_FUNC_SOURCE=PSYS_PART_BF_SOURCE_ALPHA;
            PART_BLEND_FUNC_DEST=PSYS_PART_BF_ONE_MINUS_SOURCE_ALPHA;

            llParticleSystem(
                [PSYS_PART_FLAGS , PART_BOUNCE_MASK |
                    PART_EMISSIVE_MASK |
                    PART_FOLLOW_SRC_MASK |
                    PART_FOLLOW_VELOCITY_MASK |
                    PART_INTERP_COLOR_MASK |
                    PART_INTERP_SCALE_MASK |
                    PART_TARGET_LINEAR_MASK |
                    PART_TARGET_POS_MASK |
                    PART_WIND_MASK
                ,PSYS_SRC_PATTERN, PART_PATTERN
                ,PSYS_PART_START_ALPHA, PART_START_ALPHA 
                ,PSYS_PART_END_ALPHA, PART_END_ALPHA 
                ,PSYS_PART_START_COLOR, PART_START_COLOR
                ,PSYS_PART_END_COLOR, PART_END_COLOR 
                ,PSYS_PART_START_SCALE, PART_START_SCALE 
                ,PSYS_PART_END_SCALE, PART_END_SCALE 
                ,PSYS_SRC_MAX_AGE, SRC_MAX_AGE
                ,PSYS_PART_MAX_AGE, PART_MAX_AGE
                ,PSYS_SRC_ACCEL, PART_ACCEL 
                ,PSYS_SRC_ANGLE_BEGIN, PART_ANGLE_BEGIN
                ,PSYS_SRC_ANGLE_END, PART_ANGLE_END 
                ,PSYS_SRC_BURST_PART_COUNT, PART_BURST_COUNT 
                ,PSYS_SRC_BURST_RADIUS, PART_BURST_RADIUS 
                ,PSYS_SRC_BURST_RATE, PART_BURST_RATE 
                ,PSYS_SRC_BURST_SPEED_MIN, PART_BURST_SPEED_MIN 
                ,PSYS_SRC_BURST_SPEED_MAX, PART_BURST_SPEED_MAX 
                ,PSYS_SRC_OMEGA, PART_OMEGA 
                ,PSYS_SRC_TEXTURE, PART_TEXTURE 
                ,PSYS_SRC_TARGET_KEY, PART_TARGET_KEY
                ,PSYS_PART_BLEND_FUNC_SOURCE,PART_BLEND_FUNC_SOURCE
                ,PSYS_PART_BLEND_FUNC_DEST,PART_BLEND_FUNC_DEST
            ]);
            llSleep(0.5);
            llSetTimerEvent(3);
        }
    }
    timer(){
        llSetTimerEvent(0);
        llParticleSystem([]);
    }
}