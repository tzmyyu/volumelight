float2 Hash22(float2 p){
	p=float2(dot(p,float2(127.1,311.7)),
			dot(p,float2(269.5,183.3)));
	return -1.0+2.0*frac(sin(p)*43758.5453123);
}
float3 Hash33(float3 p){
	p=float3( dot(p,float3(127.1,311.7, 74.7)),
			  dot(p,float3(269.5,183.3,246.1)),
			  dot(p,float3(113.5,271.9,124.6)));
	return -1.0+2.0*frac(sin(p)*43758.5453123);
}
float3 Hash32(float2 p)
{
	float3 p3 = frac(float3(p.xyx) * float3(443.897, 441.423, 437.195));
    p3 += dot(p3, p3.yxz+19.19);
    return frac((p3.xxy+p3.yzz)*p3.zyx);
}
float4 Hash43(float3 p)
{
	float4 p4 = frac(float4(p.xyzx)*float4(443.897, 441.423, 437.195, 444.129));
    p4 += dot(p4, p4.wzxy+19.19);
    return frac((p4.xxyz+p4.yzzw)*p4.zywx);
}
float WNoise_2V( in float2 x )
{
    float2 p = floor( x );
    float2  f = frac( x );

    float res = 8.0;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        float2 b = float2( i, j );
        float2  r = float2( b ) - f + Hash22( p + b )*0.33;
        float d = dot( r, r );

        res = min( res, d );
    }
    return sqrt( res );
}
float WNoise_3V( in float3 x )
{
    float3 p = floor( x );
    float3  f = frac( x );

    float res = 8.0;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
	for( int k=-1; k<=1; k++ )
    {
        float3 b = float3( k,i, j );
        float3  r = float3( b ) - f + Hash33( p + b )*0.33;
        float d = dot( r, r );

        res = min( res, d );
    }
    return sqrt( res );
}
float SWNoise_2V(float2 x,float smooth)
{
    float2 p = floor( x );
    float2  f = frac( x );

    float res = 0.0;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        float2 b = float2( i, j );
        float2  r = float2( b ) - f + Hash22( p + b )*0.33;
        float d = dot( r, r );
        res += 1.0/pow( d, smooth );
    }
    return pow( 1.0/res, 1.0/16.0 );
}
float SWNoise_3V(float3 x,float smooth)
{
    float3 p = floor( x );
    float3  f = frac( x );

    float res = 0.0;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
	for( int k=-1; k<=1; k++ )
    {
        float3 b = float3(k, i, j );
        float3  r = float3( b ) - f + Hash33( p + b )*0.33;
        float d = dot( r, r );
        res += 1.0/pow( d, smooth );
    }
    return pow( 1.0/res, 1.0/16.0 );
}
float SWNoise_2V_2(float2 x,float smooth)
{
    float2 p = floor(x);
    float2 f = frac(x);

    float res = 0.0;
    for(int j = -1; j <= 1; j ++)
    for(int i = -1; i <= 1; i ++)
    {
        float2 b = float2(i,j);
        float2 r = float2(b) -  f + Hash22(p + b)*0.33;
        float d = length(r);

        res += exp(-smooth* d);
    }
    return  -(1.0 / smooth)* log(res);
}
float SWNoise_3V_2(float3 x,float smooth)
{
    float3 p = floor(x);
    float3 f = frac(x);

    float res = 0.0;
    for(int j = -1; j <= 1; j ++)
    for(int i = -1; i <= 1; i ++)
	for( int k=-1; k<=1; k++ )
    {
        float3 b = float3(k,i,j);
        float3 r = float3(b) -  f + Hash33(p + b)*0.33;
        float d = length(r);
        res += exp(-smooth* d);
    }
    return  -(1.0 / smooth)* log(res);
}
float ShakeWNoise_2V( in float2 x, float u, float v )
{
    float2 p = floor(x);
    float2 f = frac(x);
    float k = 1.0 + 63.0*pow(1.0-v,4.0);
    float va = 0.0;
    float wt = 0.0;
    for( int j=-2; j<=2; j++ )
    for( int i=-2; i<=2; i++ )
    {
        float2  g = float2( float(i), float(j) );
        float3  o = Hash32( p + g )*float3(u,u,1.0);
        float2  r = g - f + o.xy;
        float d = dot(r,r);
        float w = pow( 1.0-smoothstep(0.0,1.414,sqrt(d)), k );
        va += w*o.z;
        wt += w;
    }

    return va/wt;
}
float ShakeWNoise_3V( in float3 x, float u, float v )
{
    float3 p = floor(x);
    float3 f = frac(x);
    float k = 1.0 + 63.0*pow(1.0-v,4.0);
    float va = 0.0;
    float wt = 0.0;
    for( int j=-3; j<=3; j++ )
    for( int i=-3; i<=3; i++ )
	for( int kk=-3; kk<=3; kk++ )
    {
        float3  g = float3(float(kk),float(i),float(j) );
        float4  o = Hash43( p + g )*float4(u,u,u,1.0);
        float3  r = g - f + o.xyz;
        float d = dot(r,r);
        float w = pow( 1.0-smoothstep(0.0,1.414,sqrt(d)), k );
        va += w*o.z;
        wt += w;
    }

    return va/wt;
}
