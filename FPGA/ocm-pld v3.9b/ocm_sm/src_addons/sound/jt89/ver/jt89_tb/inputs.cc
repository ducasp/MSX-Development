#include <iostream>

using namespace std;

int main() {
	int tone_addr[] = { 0, 2, 4};
	int vol_addr[]  = { 1, 3, 5};
	int ctrl_addr = 6;
	for( int ch=0; ch<1; ch++ ) 
	{
	cout << "// ch = " << ch << "\n";
	for( int vol=0; vol<8; vol++ )
	{
	cout << "// vol = " << vol << "\n";
	cout << "wr_n <= 1'b0;\n";
	cout << "din = { 1'b1, 3'd" << vol_addr[ch];
	cout << ", 4'd" << vol << "};\n";
	cout << "#500;\n";
	for( int tone=0; tone<1024; tone+=128 ) {
		cout << "wr_n <= 1'b0;\n";
		cout << "din <= { 1'b1, 3'd" << tone_addr[ch];
		cout << ", 4'd" << (tone&15) << "}; \n";
		cout << "#500\n";
		cout << "din <= { 2'b0, 6'd" << (tone>>4) << " };\n";
		cout << "#500\n";
		cout << "wr_n <= 1'b1;\n";
		cout << "for( cnt=0; cnt<" << tone << ";cnt=cnt+1)\n";
		cout << "\t#1000\n\n";
	}}}	
	cout << "$finish;\n";
	return 0;
}
