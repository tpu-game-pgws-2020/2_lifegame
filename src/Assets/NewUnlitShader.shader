Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _RandomMap("Random Map", 2D) = ""
    }

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            Name "Update"
            CGPROGRAM
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag

            #include "UnityCustomRenderTexture.cginc"

            sampler2D _RandomMap;

            int is_alive(float2 uv)
            {
                float3 c = tex2D(_SelfTexture2D, uv);// 前のフレームの値をとる
                float lum = 0.2126*c.r + 0.7152*c.g + 0.0722*c.b;// 輝度を計算
                return (0.5 < lum) ? 1 : 0;
            }

            float4 frag(v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.globalTexcoord;

                // 隣のピクセルへの距離
                float du = 1.0 / _CustomRenderTextureWidth;
                float dv = 1.0 / _CustomRenderTextureHeight;

                // 返り値
                float3 ret = tex2D(_SelfTexture2D, uv).rgb;

                // 隣接するセルの数
                int num_alive = 
                    is_alive(uv+float2(-du,-dv)) +
                    is_alive(uv+float2(-du,  0)) +
                    is_alive(uv+float2(-du,+dv)) +
                    is_alive(uv+float2(  0,-dv)) +
                    // is_alive(uv+float2(  0,  0)) +// 自分自身は取り除く
                    is_alive(uv+float2(  0,+dv)) +
                    is_alive(uv+float2(+du,-dv)) +
                    is_alive(uv+float2(+du,  0)) +
                    is_alive(uv+float2(+du,+dv));

                if(is_alive(uv) == 1)
                {// 自分が生きている
                    // 生存：隣接する生きたセルが2つか3つならば、次の世代でも生存する。
                    if(2 == num_alive || num_alive == 3) ret = tex2D(_SelfTexture2D, uv).rgb;
                    // 過疎：隣接する生きたセルが1つ以下ならば、過疎により死滅する。
                    // todo!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                    // 過密：隣接する生きたセルが4つ以上ならば、過密により死滅する。
                    if(4 <= num_alive) ret = float3(0,0,0);// 黒
                }else{// 自分が死んでいる
                    // 誕生：隣接する生きたセルがちょうど3つあれば、次の世代が誕生する。
                    if(3 == num_alive){
                        ret = tex2D(_RandomMap, uv * _Time).rgb;// ランダムな値にする
                        // 生成したものの暗さが暗かったら明るくする
                        float lum = 0.2126*ret.r + 0.7152*ret.g + 0.0722*ret.b;
                        if(lum < 0.5) ret += 0.5;
                    }
                }

                return float4(ret, 1);
            }

            ENDCG
        }
    }
}
