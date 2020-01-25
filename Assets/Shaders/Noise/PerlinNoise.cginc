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
float PNoise_2V( in float2 p )
{
    float2 i = floor( p );
    float2 f = frac( p );
	float2 u = f*f*(3.0-2.0*f);
    return lerp( lerp( dot( Hash22( i + float2(0.0,0.0) ), f - float2(0.0,0.0) ), 
                     dot( Hash22( i + float2(1.0,0.0) ), f - float2(1.0,0.0) ), u.x),
                lerp( dot( Hash22( i + float2(0.0,1.0) ), f - float2(0.0,1.0) ), 
                     dot( Hash22( i + float2(1.0,1.0) ), f - float2(1.0,1.0) ), u.x), u.y);
}
float PNoise_3V( in float3 p )
{
    float3 i = floor( p );
    float3 f = frac( p );
	
	float3 u = f*f*(3.0-2.0*f);

    return lerp( lerp( lerp( dot( Hash33( i + float3(0.0,0.0,0.0) ), f - float3(0.0,0.0,0.0) ), 
                          dot( Hash33( i + float3(1.0,0.0,0.0) ), f - float3(1.0,0.0,0.0) ), u.x),
                     lerp( dot( Hash33( i + float3(0.0,1.0,0.0) ), f - float3(0.0,1.0,0.0) ), 
                          dot( Hash33( i + float3(1.0,1.0,0.0) ), f - float3(1.0,1.0,0.0) ), u.x), u.y),
                lerp( lerp( dot( Hash33( i + float3(0.0,0.0,1.0) ), f - float3(0.0,0.0,1.0) ), 
                          dot( Hash33( i + float3(1.0,0.0,1.0) ), f - float3(1.0,0.0,1.0) ), u.x),
                     lerp( dot( Hash33( i + float3(0.0,1.0,1.0) ), f - float3(0.0,1.0,1.0) ), 
                          dot( Hash33( i + float3(1.0,1.0,1.0) ), f - float3(1.0,1.0,1.0) ), u.x), u.y), u.z );
}
float FBM_2V(float2 p){
	float f=0.0;
	f+=0.50000*PNoise_2V(p*1.0);
	f+=0.25000*PNoise_2V(p*2.03);
	f+=0.12500*PNoise_2V(p*4.01);
	f+=0.06250*PNoise_2V(p*8.05);
	f+=0.03125*PNoise_2V(p*16.02);
	return f/0.984375;
}
float FBM_3V(float3 p){
	float n = 0.0;
    n += 0.50000*PNoise_3V( p*1.0 );
    n += 0.25000*PNoise_3V( p*2.0 );
    n += 0.12500*PNoise_3V( p*4.0 );
    n += 0.06250*PNoise_3V( p*8.0 );
    n += 0.03125*PNoise_3V( p*16.0 );
    return n/0.984375;
}
float FBMR_2V( float2 p,float iterNum )
{
	float f=0.0;
	float s=0.5;
	float s2 = 2.00;
	float sum = 0.0;
	for(int i = 0;i< iterNum;i++){
		f += s*PNoise_2V( p ); 
		p = mul(float2x2(0.60,-0.80,0.80,0.60),p)*s2;
		sum+=s;
		s*= 0.5;s2+=0.01;
	}
	return f/sum;
}
float FBMR_3V( float3 p,float iterNum)
{
    float f = 0.0;
	float s = 0.5;
	float s2 = 2.00;
	float sum = 0.0;
	for(int i = 0;i< iterNum;i++){
		f += s*PNoise_3V( p ); 
		p *=s2;
		sum+=s;
		s*= 0.5;s2+=0.01;
	}
	return f/sum;
}
float TimeFBM_2V(float2 p,float t){
	float2 f=0.0;
	float s=0.5;
	for(int i=0;i<5;i++){
		p+=t;
		t*=1.5;
		f+=s*PNoise_2V(p);
		p*=2.0;
		s*=0.5;
	}
	return f;
}
float TimeFBM_3V(float3 p,float t){
	float3 f=0.0;
	float s=0.5;
	for(int i=0;i<5;i++){
		p+=t;
		t*=1.5;
		f+=s*PNoise_3V(p);
		p*=2.0;
		s*=0.5;
	}
	return f;
}
float AbsFBM_2V(float2 p)
{
    float f = 0.0;
    p = p * 7.0;
    f += 1.0000 * abs(PNoise_2V(p)); p = 2.0 * p;
    f += 0.5000 * abs(PNoise_2V(p)); p = 2.0 * p;
    f += 0.2500 * abs(PNoise_2V(p)); p = 2.0 * p;
    f += 0.1250 * abs(PNoise_2V(p)); p = 2.0 * p;
    f += 0.0625 * abs(PNoise_2V(p)); p = 2.0 * p;
    return f;
}
float AbsFBM_3V(float3 p)
{
    float f = 0.0;
    p = p * 7.0;
    f += 1.0000 * abs(PNoise_2V(p)); p = 2.0 * p;
    f += 0.5000 * abs(PNoise_2V(p)); p = 2.0 * p;
    f += 0.2500 * abs(PNoise_2V(p)); p = 2.0 * p;
    f += 0.1250 * abs(PNoise_2V(p)); p = 2.0 * p;
    f += 0.0625 * abs(PNoise_2V(p)); p = 2.0 * p;
    return f;
}
