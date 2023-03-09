Shader "Custom/benghuai" {
 Properties {
  _MainTex("Texture", 2 D) = "white" {}
  _LightMapTex("LightMapTex", 2 D) = "white" {}
  _MainColor("MainColor", color) = (1, 1, 1, 1)
  _FirstShadowArea("FirstShadowArea", range(0, 1)) = 0.5
  _FirstShadowColor("FirstShadowColor", color) = (0.5, 0.5, 0.5, 1)
  _SecondShadow("SecondShadow", range(0, 1)) = 0.2
  _SecondShadowColor("SecondShadowColor", color) = (0.5, 0.5, 0.5, 1)
  _Shininess("Shininess", range(0, 1)) = 0.2
  _SpecIntensity("SpecIntensity", range(0, 1)) = 0.7
  _LightSpecColor("LightSpecColor", color) = (0.5, 0.5, 0.5, 1)
  _DitherAlpha("DitherAlpha", float) = 0
  _Outline("Thick of Outline", range(0, 0.1)) = 0.03
  _Factor("Factor", range(0, 1)) = 0.5
  _OutColor("OutColor", color) = (0, 0, 0, 0)
 }
 
 SubShader {
  pass { //处理光照前的pass渲染
   Tags {
    "LightMode" = "Always"
   }
   Cull Front
   ZWrite On
   CGPROGRAM# pragma multi_compile_fog# pragma vertex vert# pragma fragment frag# include "UnityCG.cginc"
   float _Outline;
   float _Factor;
   fixed4 _OutColor;
   struct v2f {
    float4 pos: SV_POSITION;
    UNITY_FOG_COORDS(0)
   };


   v2f vert(appdata_full v) {
    v2f o;
    float3 dir = normalize(v.vertex.xyz);
    float3 dir2 = v.normal;
    float D = dot(dir, dir2);
    dir = dir * sign(D);
    dir = dir * _Factor + dir2 * (1 - _Factor);
    v.vertex.xyz += dir * _Outline;
    o.pos = UnityObjectToClipPos(v.vertex);
    UNITY_TRANSFER_FOG(o, o.pos);
    return o;
   }
   float4 frag(v2f i): COLOR {
    float4 c = _OutColor;
    UNITY_APPLY_FOG(i.fogCoord, c);
    return c;
   }
   ENDCG
  }


  Pass {
   Tags {
    "RenderType" = "Opaque"
   }
   CGPROGRAM# pragma vertex vert# pragma fragment frag# pragma multi_compile_fog# include "lighting.cginc"#
   include "UnityCG.cginc"#
   include "AutoLight.cginc"


   sampler2D _MainTex;
   float4 _MainTex_ST;


   sampler2D _LightMapTex;
   //float4 _ProjectionParams;
   //float4 _WorldSpaceLightPos0;
   float _UsingDitherAlpha;
   float _DitherAlpha;
   float _SecondShadow;
   fixed4 _SecondShadowColor;
   fixed4 _FirstShadowColor;
   half _FirstShadowArea;
   float _Shininess;
   float _SpecIntensity;
   fixed4 _LightSpecColor;
   float _BloomFactor;
   fixed4 _MainColor;


   float4 imm[4];


   struct appdata {
    float4 vertex: POSITION;
    float3 normal: NORMAL;
    float4 uv: TEXCOORD0;
    float4 color: COLOR0;
   };


   struct v2f {
    float4 vertex: POSITION;
    float4 color: COLOR0;
    float2 uv: TEXCOORD0;
    float color1: COLOR1;
    float3 normal: TEXCOORD1;
    float3 viewDir: TEXCOORD2;
    float4 vstex3: TEXCOORD3;
    UNITY_FOG_COORDS(4)
   };




   v2f vert(appdata v) {
    v2f o;
    float4 worldPos = UnityObjectToClipPos(v.vertex);
    o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
    o.vertex = worldPos;
    o.color = v.color;
    o.uv = TRANSFORM_TEX(v.uv.xy, _MainTex);


    float4 worldNormal;
    worldNormal.xyz = normalize(UnityObjectToWorldNormal(v.normal));
    o.normal.xyz = worldNormal.xyz;

    //计算半lambert光照
    float lambert = dot(worldNormal.xyz, normalize(-_WorldSpaceLightPos0));
    lambert = lambert * 0.5 + 0.5;
    o.color1 = lambert;
    //目前vstex3再片源着色器里面使用是在opengles3.0中做一些特殊处理，目前不清楚这部分特殊处理是在做什么
    //worldPos.y = worldPos.y * _ProjectionParams.x;
    //worldNormal.xzw = worldPos.xwy * float3(0.5, 0.5, 0.5);
    //worldPos.xy = worldNormal.zz + worldNormal.xw;
    //o.vstex3.xyw = worldPos.xyw;//smoothstep(float3(0.0, 0.0, 0.0), worldPos.xyw, ises3);//mix(vec3(0.0, 0.0, 0.0), worldPos.xyw, vec3(bvec3(ises3)));
    //o.vstex3.z = _DitherAlpha;// ises3 ? _DitherAlpha : float(0.0);
    UNITY_TRANSFER_FOG(o, o.vertex);
    return o;
   }

   fixed4 frag(v2f i): SV_Target {
    imm[0] = float4(1.0, 0.0, 0.0, 0.0);
    imm[1] = float4(0.0, 1.0, 0.0, 0.0);
    imm[2] = float4(0.0, 0.0, 1.0, 0.0);
    imm[3] = float4(0.0, 0.0, 0.0, 1.0);
    float4 mainColor = float4(1, 1, 1, 1);


    //opengles3.0里面做了一些特殊处理，目前不清楚处理了什么
    //bool ises3;
    //#ifdef UNITY_ADRENO_ES3
    //ises3 = !!(float4(0.0, 0.0, 0.0, 0.0) != float4(_UsingDitherAlpha, _UsingDitherAlpha, _UsingDitherAlpha, _UsingDitherAlpha));
    //#else
    //ises3 = float4(0.0, 0.0, 0.0, 0.0) != float4(_UsingDitherAlpha, _UsingDitherAlpha, _UsingDitherAlpha, _UsingDitherAlpha);
    //#endif
    //if (ises3) {
    //#ifdef UNITY_ADRENO_ES3
    //ises3 = !!(i.vstex3.z<0.949999988);
    //#else
    //ises3 = i.vstex3.z<0.949999988;
    //#endif
    //if (ises3) {
    //float2 temp = i.vstex3.yx / i.vstex3.ww;
    //temp.xy = temp.xy * _ScreenParams.yx;
    //temp.xy = temp.xy * float2(0.25, 0.25);
    //
    //float2 tempvec2 = float2(max(temp.x, -temp.x), max(temp.y, -temp.y));// greaterThanEqual(temp.xyxy, (-temp.xyxy)).xy;
    //temp.xy = float2(abs(temp.x) - floor(abs(temp.x)), abs(temp.y) - floor(abs(temp.y)));//fract(abs(temp.xy));
    //temp.x = (tempvec2.x) ? temp.x : (-temp.x);
    //temp.y = (tempvec2.y) ? temp.y : (-temp.y);
    //temp.xy = temp.xy * float2(4.0, 4.0);
    //float2 tempvec2_t = float2(temp.xy);


    /*mainColor.x = dot(hlslcc_mtx4x4_DITHERMATRIX[0], imm[int(tempvec2_t.y)]);
    mainColor.y = dot(hlslcc_mtx4x4_DITHERMATRIX[1], imm[int(tempvec2_t.y)]);
    mainColor.z = dot(hlslcc_mtx4x4_DITHERMATRIX[2], imm[int(tempvec2_t.y)]);
    mainColor.w = dot(hlslcc_mtx4x4_DITHERMATRIX[3], imm[int(tempvec2_t.y)]);*/




    /*temp.x = dot(mainColor, imm[int(tempvec2_t.x)]);
    temp.x = i.vstex3.z * 17.0 + (-temp.x);
    temp.x = temp.x + 0.99000001;
    temp.x = floor(temp.x);
    temp.x = max(temp.x, 0.0);
    int u_xlati0 = int(temp.x);
    if ((u_xlati0) == 0) { discard; }*/
    //}
    //}


    fixed3 lightMapColor = tex2D(_LightMapTex, i.uv.xy).xyz;
    mainColor.xyz = tex2D(_MainTex, i.uv.xy).xyz;
    //采样的图的g通道乘以顶点r值
    float vrCr = lightMapColor.g * i.color.r;


    //阈值，关于第二层暗面的颜色，如果lColorG = 0,就是用第二层暗面颜色，否则使用第一层暗面颜色
    float lColorG = max(floor((vrCr + i.color1) * 0.5 + (-_SecondShadow) + 1.0), 0.0);
    half3 secondShadowColor = mainColor.xyz * _SecondShadowColor.rgb;
    fixed3 firstShadowColor = mainColor.xyz * _FirstShadowColor.rgb;
    secondShadowColor.rgb = (int(lColorG) != 0) ? firstShadowColor.rgb : secondShadowColor.rgb;


    //阈值，关于普通颜色与第一层暗面的阈值，如果lColorGx = 0 就是用第一层暗面，随光的方向进行移动
    float lColorGx = max(floor((-i.color.r) * lightMapColor.g + 1.5), 0.0);
    float2 tempXY = vrCr.rr * float2(1.20000005, 1.25) + float2(-0.100000001, -0.125);
    vrCr = (lColorGx != 0) ? tempXY.y : tempXY.x;
    vrCr = max(floor((vrCr + i.color1) * 0.5 + (-_FirstShadowArea) + 1.0), 0);
    lColorGx = int(vrCr);
    firstShadowColor.rgb = (lColorGx != 0) ? mainColor.rgb : firstShadowColor.rgb;


    vrCr = lightMapColor.g * i.color.r;
    //阈值，关于第一层暗面与第二层暗面的阈值，如果lColorGz = 0 就使用第二层暗面，固定暗面
    float lColorGz = max(floor(vrCr + 0.909999967), 0.0);
    half3 color = (lColorGz != 0) ? firstShadowColor.rgb : secondShadowColor.rgb;

    //计算高光
    float3 normal = normalize(i.normal.xyz);
    float3 viewDirection = i.viewDir;
    float3 lightDirection = normalize(-_WorldSpaceLightPos0.xyz);
    float3 H = normalize(viewDirection + lightDirection);
    half spec = pow(max(dot(normal, H), 0.0), _Shininess);

    //阈值，关于高光颜色选择，如果lColorGy = 0, 使用高光颜色，否则，无高光
    float lColorGy = int(max(floor(2 - spec - lightMapColor.b), 0.0));
    float3 specColor = lightMapColor.r * _LightSpecColor * _SpecIntensity * spec; //  float3(_SpecIntensity * _LightSpecColor.x, _SpecIntensity * _LightSpecColor.y, _SpecIntensity * _LightSpecColor.z);
    specColor = (lColorGy != 0) ? float3(0.0, 0.0, 0.0) : specColor.rgb;
    color.rgb = color.rgb + specColor;
    color.rgb = color.rgb * _MainColor.rgb;


    fixed4 col;
    col.xyz = color.rgb;
    col.w = _BloomFactor;
    return col;
   }
   ENDCG
  }
 }
}