float Hash12(float2 p)
{
	float3 p3  = frac(float3(p.xyx) * float3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yzx + 19.19);
    return frac((p3.x + p3.y) * p3.z);
}
float Hash13(float3 p3)
{
	p3  = frac(p3 *float3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yzx + 19.19);
    return frac((p3.x + p3.y) * p3.z);
}
float VNoise_2V( in float2 p )
{
    float2 i = floor( p );
    float2 f = frac( p );
	float2 u = f*f*(3.0-2.0*f);
    return lerp(lerp(Hash12(i + float2(0.0, 0.0)), Hash12(i + float2(1.0, 0.0)), u.x),
               lerp(Hash12(i + float2(0.0, 1.0)), Hash12(i + float2(1.0, 1.0)), u.x),
               u.y);
}
float VNoise_3V( in float3 p )
{
    float3 i = floor( p );
    float3 f = frac( p );
	float3 u = f*f*(3.0-2.0*f);
    return lerp(lerp(lerp( Hash13(i+float3(0.0,0.0,0.0)), Hash13(i+float3(1.0,0.0,0.0)),u.x),
                     lerp( Hash13(i+float3(0.0,1.0,0.0)), Hash13(i+float3(1.0,1.0,0.0)), u.x), u.y),
                lerp( lerp( Hash13(i+float3(0.0,0.0,1.0)), Hash13(i+float3(1.0,0.0,1.0)), u.x),
                     lerp(Hash13(i+float3(0.0,1.0,1.0)), Hash13(i+float3(1.0,1.0,1.0)),u.x), u.y)
					 , u.z );
}
float FBM_2V(float2 p){
	float f=0.0;
	f+=0.50000*VNoise_2V(p*1.0);
	f+=0.25000*VNoise_2V(p*2.03);
	f+=0.12500*VNoise_2V(p*4.01);
	f+=0.06250*VNoise_2V(p*8.05);
	f+=0.03125*VNoise_2V(p*16.02);
	return f/0.984375;
}
float FBM_3V(float3 p){
	float n = 0.0;
    n += 0.50000*VNoise_3V( p*1.0 );
    n += 0.25000*VNoise_3V( p*2.0 );
    n += 0.12500*VNoise_3V( p*4.0 );
    n += 0.06250*VNoise_3V( p*8.0 );
    n += 0.03125*VNoise_3V( p*16.0 );
    return n/0.984375;
}
float FBMR_2V( float2 p,float iterNum )
{
	float f=0.0;
	float s=0.5;
	float s2 = 2.00;
	float sum = 0.0;
	for(int i = 0;i< iterNum;i++){
		f += s*VNoise_2V( p ); 
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
		f += s*VNoise_3V( p ); 
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
		f+=s*VNoise_2V(p);
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
		f+=s*VNoise_3V(p);
		p*=2.0;
		s*=0.5;
	}
	return f;
}
float AbsFBM_2V(float2 p)
{
    float f = 0.0;
    p = p * 7.0;
    f += 1.0000 * abs(VNoise_2V(p)); p = 2.0 * p;
    f += 0.5000 * abs(VNoise_2V(p)); p = 2.0 * p;
    f += 0.2500 * abs(VNoise_2V(p)); p = 2.0 * p;
    f += 0.1250 * abs(VNoise_2V(p)); p = 2.0 * p;
    f += 0.0625 * abs(VNoise_2V(p)); p = 2.0 * p;
    return f;
}
float AbsFBM_3V(float3 p)
{
    float f = 0.0;
    p = p * 7.0;
    f += 1.0000 * abs(VNoise_2V(p)); p = 2.0 * p;
    f += 0.5000 * abs(VNoise_2V(p)); p = 2.0 * p;
    f += 0.2500 * abs(VNoise_2V(p)); p = 2.0 * p;
    f += 0.1250 * abs(VNoise_2V(p)); p = 2.0 * p;
    f += 0.0625 * abs(VNoise_2V(p)); p = 2.0 * p;
    return f;
}