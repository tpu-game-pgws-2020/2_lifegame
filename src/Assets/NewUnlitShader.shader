Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _CellColor ("Cell color", Color) = (0, 1, 0, 0)
        _EmptyColor ("Empty color", Color) = (0, 0, 0, 0)
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
            float4 _CellColor;
            float4 _EmptyColor;

            int is_alive(float2 uv)
            {
                float3 c = tex2D(_SelfTexture2D, uv);// 前のフレームの値をとる
                if((c.r==_CellColor.r&&c.g==_CellColor.g&&c.b==_CellColor.b)||(c.r==_EmptyColor.r&&c.g==_EmptyColor.g&&c.b==_EmptyColor.b))
                    return (c.r==_CellColor.r&&c.g==_CellColor.g&&c.b==_CellColor.b) ? 1 : 0;
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
                    if(2 == num_alive || num_alive == 3) ret = _CellColor;
                    // 過疎：隣接する生きたセルが1つ以下ならば、過疎により死滅する。
                    if(1 >= num_alive) ret = _EmptyColor;
                    // 過密：隣接する生きたセルが4つ以上ならば、過密により死滅する。
                    if(4 <= num_alive) ret = _EmptyColor;// 黒
                }else{// 自分が死んでいる
                    // 誕生：隣接する生きたセルがちょうど3つあれば、次の世代が誕生する。
                    if(3 == num_alive)
                        ret = _CellColor;
                    else
                        ret=_EmptyColor;
                }

                return float4(ret, 1);
            }

            ENDCG
        }
    }
}
