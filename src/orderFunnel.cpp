#include "orderFunnel.h"
#include <algorithm>
#include <string>
#include <cstring>
#include <stdexcept>
//put the funnels into cannonical order
//order a set of four (considered as first pair / second pair) so that the pair containing the smallest value comes first, followed by the other pair. Each pair also sorted as (smaller, larger)
void orderFour(int* start)
{
	int* minElement = std::min_element(start, start + 4);
	//if minimum is in first pair do nothing
	if((minElement - start) / 2 == 0)
	{
	}
	//if it's in second pair switch
	else
	{
		int fourValues[4];
		memcpy(fourValues, start, sizeof(int)*4);
		memcpy(start+2, fourValues, sizeof(int)*2);
		memcpy(start, fourValues+2, sizeof(int)*2);
	}
	//also order each pair as (min, max)
	int min = std::min(start[0], start[1]), max = std::max(start[0], start[1]);
	start[0] = min; start[1] = max;
	min = std::min(start[2], start[3]), max = std::max(start[2], start[3]);
	start[2] = min; start[3] = max;
}
//order a set of eight values so that the set of  four (out of first four / last four) containing the smallest value come first
void orderByFour(int* funnel)
{
	int* minVal = std::min_element(funnel, funnel + 8);
	//if the smallest value is in the first four, do nothing
	if((minVal - funnel) / 4 == 0)
	{
	}
	else
	{
		//if the smallest value is in the second four, switch the two sets of four
		int original[8];
		memcpy(original, funnel, sizeof(int)*8);
		memcpy(funnel, original + 4, sizeof(int)*4);
		memcpy(funnel + 4, original, sizeof(int)*4);
	}
}
void orderFunnel4(int* funnel)
{
	orderFour(funnel);
}
void orderFunnel8(int* funnel)
{
	orderByFour(funnel);
	orderFour(funnel);
	orderFour(funnel+4);
}
void orderByEight(int* funnel)
{
	int* minVal = std::min_element(funnel, funnel + 16);
	//if the smallest value is in the first four, do nothing
	if ((minVal - funnel) / 8 == 0)
	{
	}
	else
	{
		//if the smallest value is in the second four, switch the two sets of four
		int original[16];
		memcpy(original, funnel, sizeof(int) * 16);
		memcpy(funnel, original + 8, sizeof(int) * 8);
		memcpy(funnel + 8, original, sizeof(int) * 8);
	}
}
void orderFunnel16(int* funnel)
{
	orderByEight(funnel);
	orderFunnel8(funnel);
	orderFunnel8(funnel + 8);
}
void orderFunnel(int* funnel, int nFounders)
{
	if(nFounders == 2)
	{
		int min = std::min(funnel[0], funnel[1]);
		int max = std::max(funnel[0], funnel[1]);
		funnel[0] = min;
		funnel[1] = max;
	}
	else if(nFounders == 4)
	{
		orderFunnel4(funnel);
	}
	else if (nFounders == 8)
	{
		orderFunnel8(funnel);
	}
	else if (nFounders == 16)
	{
		orderFunnel16(funnel);
	}
	else throw std::runtime_error("Input nFounders must be 2, 4, 8 or 16");
}
