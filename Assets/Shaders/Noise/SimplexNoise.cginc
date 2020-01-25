float Hash22(float2 p) {
	p = float2(dot(p,float2(127.1,311.7)), dot(p,float2(269.5,183.3)));
	return -1.0 + 2.0*frac(sin(p)*43758.5453123);
}
float3 Hash33(float3 p){
	p=float3( dot(p,float3(127.1,311.7, 74.7)),
			  dot(p,float3(269.5,183.3,246.1)),
			  dot(p,float3(113.5,271.9,124.6)));
	return -1.0+2.0*frac(sin(p)*43758.5453123);
}
float SNoise_2V(float2 p)
{
	const float K1 = 0.366025404; // (sqrt(3)-1)/2;
	const float K2 = 0.211324865; // (3-sqrt(3))/6;
	float2 i = floor(p + (p.x + p.y) * K1);
	float2 a = p - (i - (i.x + i.y) * K2);
	float2 o = (a.x < a.y) ? float2(0.0, 1.0) : float2(1.0, 0.0);
	float2 b = a - o + K2;
	float2 c = a - 1.0 + 2.0 * K2;
	float3 h = max(0.5 - float3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
	float3 n = h * h * h * h * float3(dot(a, Hash22(i)), dot(b, Hash22(i + o)), dot(c, Hash22(i + 1.0)));
	return dot(float3(70.0, 70.0, 70.0), n);
}
float SNoise_3V(float3 p)
{
    const float K1 = 0.333333333;
    const float K2 = 0.166666667;
    float3 i = floor(p + (p.x + p.y + p.z) * K1);
    float3 d0 = p - (i - (i.x + i.y + i.z) * K2);
    float3 e = step(float3(0.0,0.0,0.0), d0 - d0.yzx);
	float3 i1 = e * (1.0 - e.zxy);
	float3 i2 = 1.0 - e.zxy * (1.0 - e);
    float3 d1 = d0 - (i1 - 1.0 * K2);
    float3 d2 = d0 - (i2 - 2.0 * K2);
    float3 d3 = d0 - (1.0 - 3.0 * K2);
    float4 h = max(0.6 - float4(dot(d0, d0), dot(d1, d1), dot(d2, d2), dot(d3, d3)), 0.0);
    float4 n = h * h * h * h * float4(dot(d0, Hash33(i)), dot(d1, Hash33(i + i1)), dot(d2, Hash33(i + i2)), dot(d3, Hash33(i + 1.0)));
    return dot(float4(31.316,31.316,31.316,31.316), n);
}
float FBM_2V(float2 p){
	float f=0.0;
	f+=0.50000*SNoise_2V(p*1.0);
	f+=0.25000*SNoise_2V(p*2.03);
	f+=0.12500*SNoise_2V(p*4.01);
	f+=0.06250*SNoise_2V(p*8.05);
	f+=0.03125*SNoise_2V(p*16.02);
	return f/0.984375;
}
float FBM_3V(float3 p){
	float f=0.0;
	f+=0.50000*SNoise_3V(p*1.0);
	f+=0.25000*SNoise_3V(p*2.03);
	f+=0.12500*SNoise_3V(p*4.01);
	f+=0.06250*SNoise_3V(p*8.05);
	f+=0.03125*SNoise_3V(p*16.02);
	return f/0.984375;
}
float FBMR_2V( float2 p,float iterNum )
{
	float f=0.0;
	float s=0.5;
	float s2 = 2.00;
	float sum = 0.0;
	for(int i = 0;i< iterNum;i++){
		f += s*SNoise_2V( p ); 
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
		f += s*SNoise_3V( p ); 
		p *=s2;
		sum+=s;
		s*= 0.5;s2+=0.01;
	}
	return f/sum;
}
float TimeFBM_2V(float2 p,float t){
	float2 f=0.0;
	float s=0.5;
	for(int i=0;i<6;i++){
		p+=t;
		t*=1.5;
		f+=s*SNoise_2V(p);
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
		f+=s*SNoise_3V(p);
		p*=2.0;
		s*=0.5;
	}
	return f;
}
float AbsFBM_2V(float2 p)
{
    float f = 0.0;
    p = p * 7.0;
    f += 1.0000 * abs(SNoise_2V(p)); p = 2.0 * p;
    f += 0.5000 * abs(SNoise_2V(p)); p = 2.0 * p;
    f += 0.2500 * abs(SNoise_2V(p)); p = 2.0 * p;
    f += 0.1250 * abs(SNoise_2V(p)); p = 2.0 * p;
    f += 0.0625 * abs(SNoise_2V(p)); p = 2.0 * p;
    return f;
}
float AbsFBM_3V(float3 p)
{
    float f = 0.0;
    p = p * 7.0;
    f += 1.0000 * abs(SNoise_2V(p)); p = 2.0 * p;
    f += 0.5000 * abs(SNoise_2V(p)); p = 2.0 * p;
    f += 0.2500 * abs(SNoise_2V(p)); p = 2.0 * p;
    f += 0.1250 * abs(SNoise_2V(p)); p = 2.0 * p;
    f += 0.0625 * abs(SNoise_2V(p)); p = 2.0 * p;
    return f;
}
