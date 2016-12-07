![](https://bytebucket.org/LUXOPHIA/projectmap/raw/171bee704242255fb97dfaa53bcb402561134cf8/--------/_SCREENSHOT/ProjectMap.png)

# ﻿ProjectMap #

任意の画像をプロジェクトマッピングするシェーダを作る方法。シェーダは HLSL 言語で書きます。

単純に考えると、プロジェクタ側から光を出してオブジェクトを照らしているイメージですが、この場合は逆に、視点側から見えるオブジェクトの表面座標が、投影されるテクスチャのどの位置に当たるかを逆算することで、投影されているかのようなビジュアルを作り出します。

具体的には、ピクセルシェーダの中で処理しています。

まず、プロジェクタの位置 P と ローカル座標系 X/Y/Z を計算（ProZ が投影方向）。

```
    float4 ProP = mul( float4( 0, 0, 0, 1 ), _ProjMatrix );
    float4 ProX = mul( float4( 1, 0, 0, 0 ), _ProjMatrix );
    float4 ProY = mul( float4( 0, 1, 0, 0 ), _ProjMatrix );
    float4 ProZ = mul( float4( 0, 0, 1, 0 ), _ProjMatrix );
```

次に、プロジェクタ位置 P から 表面座標 _Sender.Pos へ向かう光線方向 PV を計算。

```
    float4 PV = _Sender.Pos - ProP;
```

光線方向 PV と 投影方向 ProjZ との内積 PL がゼロ以下であれば、そもそもプロジェクタから放射されない。

```
    float PL = dot( PV, ProZ );

    if ( PL > 0 )
    {
        ～
    }
```

光線方向 PV と 表面法線 N との内積がゼロ以上であれば、裏側からの照射なので無効。

```
        PV = PV / PL;

        if ( dot( PV, N ) < 0 )
        {
            ～
        }
```

投影角度 _ProjAngleW/H に応じて、テクスチャ座標 S を計算。

```
            float2 S;
            S.x = dot( PV, ProX ) / tan( _ProjAngleW / 2 );
            S.y = dot( PV, ProY ) / tan( _ProjAngleH / 2 );
```

テクスチャ座標 S が -1～+1 の範囲に入っていれば投影領域内。

```
            if ( ( -1 <= S.x ) && ( S.x <= +1 ) &&
                 ( -1 <= S.y ) && ( S.y <= +1 ) )
            {
                ～
            }
```

テクスチャ座標を 0～1 の範囲へマッピング。

```
                S.x = ( S.x + 1 ) / 2;
                S.y = ( S.y + 1 ) / 2;

```

光線 PV と 表面法線 N との内積で、ランバート反射率 PD を計算。

```
                float PD = max( -dot( N, normalize( PV ) ), 0.0 );

```

テクスチャ色 と ランバート反射率 PD の積を、基本シェーディングの色に加算。

```
                _Result.Col = _Result.Col + _DiffRatio * _ProjImage.Sample( _SamplerState, S ) * PD;
```

ランバート反射率 PD を無視すれば、輝度変化のない投影も可能。

![](https://bytebucket.org/LUXOPHIA/projectmap/raw/171bee704242255fb97dfaa53bcb402561134cf8/--------/_SCREENSHOT/ProjectMap-NonDiffuse.png)