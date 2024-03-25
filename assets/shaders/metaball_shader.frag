#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;

float pixelPower;
const float powerTreshold = 2.5;
const int numberOfMetaballs = 2;
const float lineSize = 1000.0;
float norm;
out vec4 fragColor;
vec2 fragCoord;

uniform float leftBallXPos;
uniform float rightBallXPos;
uniform float leftCircleRadius; // = .65;
uniform float rightCircleRadius; // = .65;
float normalizedLeftBallXPos = leftBallXPos/iResolution.x;
float normalizedRightBallXPos = rightBallXPos/iResolution.x;

vec3 ColorOfMetaball(int metaballNumber)
{
	return vec3(1.0, 1.0, 1.0);
}

vec2 PositionOfMetaball(int metaballNumber)
{
	vec2 metaPos = vec2(0.0);
	
	if(metaballNumber == 0)
	{
		metaPos = vec2(normalizedLeftBallXPos, 0.5);	
	}
	else if(metaballNumber == 1)
	{
		metaPos = vec2(normalizedRightBallXPos, 0.5);
	}
    
 	metaPos.x = metaPos.x * (iResolution.x / iResolution.y);
	
	return metaPos;
}

float RadiusOfMetaball(int metaballNumber)
{
	float radius = 0.0;
	
	if(metaballNumber == 0)
	{
		radius = leftCircleRadius;
	}
	else if(metaballNumber == 1)
	{
		radius = rightCircleRadius;
	}
	
	return radius;
}

float Norm(float num)
{
	float res = pow(num, norm);
	return res;	
}

float SquareDistanceToMetaball(int metaballNumber, vec2 pixelPos)
{
	vec2 metaPos = PositionOfMetaball(metaballNumber);
	vec2 distanceVector = pixelPos - PositionOfMetaball(metaballNumber);
	distanceVector = vec2(abs(distanceVector.x), abs(distanceVector.y));	
	float normDistance = Norm(distanceVector.x) + Norm(distanceVector.y);
	return normDistance;
}

float PowerOfMetaball(int metaballNumber, vec2 pixelPos)
{
    float power = 0.0;

    float radius = RadiusOfMetaball(metaballNumber);
    float squareDistance = SquareDistanceToMetaball(metaballNumber, pixelPos);

    // Smoothly decrease the power contribution as the distance decreases
    float distanceFactor = 1.0 - smoothstep(0.0, radius, sqrt(squareDistance)); // Adjust the radius as needed

    power = distanceFactor * Norm(radius) / squareDistance;

    return power;
}

// float PowerOfMetaball(int metaballNumber, vec2 pixelPos)
// {
// 	float power = 0.0;
	
// 	float radius = RadiusOfMetaball(metaballNumber);
// 	float squareDistance = SquareDistanceToMetaball(metaballNumber, pixelPos);
	
	
// 	power = Norm(radius) / squareDistance;
	
// 	return power;
// }

vec3 CalculateColor(float maxPower, vec2 pixelPos)
{
	vec3 val = vec3(0.0);
					
	for(int i = 0; i < numberOfMetaballs; i++)
	{
		val += ColorOfMetaball(i) * (PowerOfMetaball(i, pixelPos) / maxPower);
	}
	
	return val;
}

vec4 Metaballs(vec2 pixelPos)
{
	vec3 val;
	pixelPower = 0.0;
	vec4 col = vec4(0.0);
	int powerMeta = 0;
	float maxPower = 0.0;
	for(int i = 0; i < numberOfMetaballs; i++)
	{
		float power = PowerOfMetaball(i, pixelPos);
		pixelPower += power;
		if(maxPower < power)
		{
			maxPower = power;
			powerMeta = i;
		}
		power *= RadiusOfMetaball(i);
	}

	val = CalculateColor(maxPower, pixelPos);
	
	if(pixelPower < powerTreshold || pixelPower > powerTreshold + Norm(lineSize))
	{
    	col.a = 0.0;
	}

  else {
    col = vec4(val, 1.0);
  }
  return col;
}

void main()
{
  	fragCoord = FlutterFragCoord().xy;
	norm = 2.0;

	vec2 pixelPos = fragCoord.xy / iResolution.xy;
    pixelPos.x = pixelPos.x * iResolution.x / iResolution.y;
	vec4 col = vec4(0.0);
	
	// Antialiasing via supersampling
	float e = 1. / min(iResolution.y , iResolution.x);
	vec2 uv = (fragCoord.xy / iResolution.xy * 2. - 1.)
			* vec2(iResolution.x / iResolution.y, 1) * 1.25;
	for (float i = -4.0; i < 4.0; ++i) {
        for (float j = -4.0; j < 4.0; ++j) {
    		col += Metaballs(pixelPos + vec2(i, j) * (e/4.0)) / (4.*4.0*4.0);
        }
    }

	fragColor = col;
}