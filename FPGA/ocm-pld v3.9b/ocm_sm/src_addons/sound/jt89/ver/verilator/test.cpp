#include <cstdio>
#include <iostream>
#include <fstream>
#include <string>
#include <string>
#include <list>
#include "Vjt89.h"
#include "verilated_vcd_c.h"
// #include "feature.hpp"

  // #include "verilated.h"

using namespace std;

vluint64_t main_time = 0;      // Current simulation time
// This is a 64-bit integer to reduce wrap over issues and
// allow modulus.  You can also use a double, if you wish.

class SimTime {
    vluint64_t time_limit, fast_forward;
    vluint64_t main_next;
    int verbose_ticks;
    bool toggle, trace;
    int PERIOD, SEMIPERIOD, CLKSTEP;
    Vjt89* top;
    VerilatedVcdC* tfp;
public:
    int clk, clk_en, din, rst, wr_n; // inputs
    int sound, ready; // outputs

    void apply();
    void readback();

    void set_period( int _period ) {
        PERIOD =_period;
        PERIOD += PERIOD%2; // make it even
        SEMIPERIOD = PERIOD>>1;
        // CLKSTEP = SEMIPERIOD>>1;
        CLKSTEP = SEMIPERIOD;
    }
    int period() { return PERIOD; }
    SimTime( bool _trace ) : trace(_trace) { 
        top = new Vjt89;  
        clk=0; clk_en=1; din=0; rst=1; wr_n=1;
        sound = ready = 0;     
        main_time=0; fast_forward=0; time_limit=0; toggle=false;
        verbose_ticks = 48000*24/2;
        set_period(132);
        tfp = new VerilatedVcdC;
        if( trace ) {
            Verilated::traceEverOn(true);
            top->trace(tfp,99);
            tfp->open("test.vcd"); 
        }

    }
    ~SimTime() {
        delete top; top=0;
        delete tfp; tfp=0;
    }
    Vjt89 *Top() { return top; }

    void set_time_limit(vluint64_t t) { time_limit=t; }
    bool limited() { return time_limit!=0; }
    vluint64_t get_time_limit() { return time_limit; }
    vluint64_t get_time() { return main_time; }
    int get_time_s() { return main_time/1000000000; }
    int get_time_ms() { return main_time/1000000; }
    bool next_quarter();
    bool finish() { return main_time > time_limit && limited(); }
};

void SimTime::apply() {
    top->clk   = clk;
    top->clk_en= clk_en;
    top->rst   = rst;
    top->din   = din;
    top->wr_n  = wr_n;
}

void SimTime::readback() {
    sound = top->sound;
    ready = top->ready;
}

bool SimTime::next_quarter() {
    if( !toggle ) {
        main_time += SEMIPERIOD/2;
        main_next = main_time + SEMIPERIOD;
        toggle = true;
    }
    else {
        clk = 1-clk;
        main_time = main_next;
        toggle = false;
    }
    apply();
    // cout << wr_n << " - " << din << " - " << main_time << '\n';
    top->eval();
    readback();
    if(trace) tfp->dump(main_time);
    return clk==1;
}


double sc_time_stamp () {      // Called by $time in Verilog
   return main_time;           // converts to double, to match
                               // what SystemC does
}

class CmdWritter {
    int val;
    SimTime &sim;
    bool done;
    int last_clk;
    int state;
public:
    CmdWritter( SimTime& _sim );
    void Write( int _val );
    void Eval();
    bool Done() { return done; }
};

class RipParser {
    ifstream f;
    int line_cnt, regn;
    bool parse_error;
public:
    int val;
    vluint64_t wait;
    enum t_action { cmd_write, cmd_wait, cmd_finish, cmd_error };
    RipParser();
    bool open(char *filename);
    int parse();
    void set_vol   ( int cnt, int a, int b);
    void set_lsb   ( int cnt, int a, int b);
    void set_noise ( int cnt, int a, int b);
    void set_msb ( int cnt, int b);
    void set_rep ( int cnt, int a);
    void set_wait( int cnt, int a);
};

RipParser::RipParser() {
    wait = 0L;
    regn = line_cnt=0;
    parse_error = false;
}

bool RipParser::open(char *filename) {
    f.open( filename );
    if( !f ) {
        cout << "ERROR: Cannot open file: " << filename << '\n';
        return false;
    }
    return true;
}

void RipParser::set_vol( int cnt, int a, int b) {
    if( cnt!=2 || a>3 || b>0xf ) { parse_error=true; return; }
    regn = (a<<1) | 1;
    val = 0x80 | (regn<<4) | b;
}

void RipParser::set_lsb( int cnt, int a, int b) {
    if( cnt!=2 || a>2 || b>0xf ) { parse_error=true; return; }
    regn = a<<1;
    val = 0x80 | (regn<<4) | b;
}

void RipParser::set_noise( int cnt, int a, int b) {
    if( cnt!=2 || a>1 || b>3 ) { parse_error=true; return; }
    regn = 6;
    b |= a<<2;
    val = 0x80 | (regn<<4) | b;
}

void RipParser::set_msb( int cnt, int b) {
    if( cnt!=1 || b>0x3f ) { parse_error=true; return; }
    val = b;
}

void RipParser::set_rep( int cnt, int a) {
    if( cnt!=1 || a>0xf ) { parse_error=true; return; }
    val = (regn<<4) | a;
}

void RipParser::set_wait( int cnt, int a) {
    if( cnt!=1 ) { parse_error=true; return; }
    wait = a << 4;
}

int RipParser::parse() {
    char line[512];
    while( !f.eof() ) {
        f.getline( line, 512 ); line[511]=0;
        line_cnt++;
        cout << "Line " << line_cnt << '\n';
        char *noblanks=line;
        while( *noblanks==' ' || *noblanks=='\t' ) noblanks++;
        char *cmd = noblanks;
        char *args=cmd+1;
        while( (*args!=' ' && *args!='\t') && *args!=0 ) args++;
        if( *args==0 ) continue;
        *args=0;
        // cout << "CMD=" << cmd << '\n';
        args++;
        int a=0xff,b=0xff, cnt;
        bool do_wait=false;
        parse_error = false;
        cnt=sscanf(args,"%x,%x", &a, &b);
        if( strcmp(cmd,"vol" )==0 ) set_vol( cnt, a,b);
        if( strcmp(cmd,"lsb" )==0 ) set_lsb( cnt, a,b);
        if( strcmp(cmd,"msb" )==0 ) set_msb( cnt, a);
        if( strcmp(cmd,"rep" )==0 ) set_rep( cnt, a);
        if( strcmp(cmd,"no"  )==0 ) set_noise( cnt, a,b);
        if( strcmp(cmd,"wait")==0 ) { do_wait=true; set_wait(cnt, a); }
        if( parse_error ) {
            cout << "Error at line #" << line_cnt << 'n';
            return cmd_error;
        }
        return do_wait ? cmd_wait : cmd_write;
    }
    return cmd_finish;
}

class HexWritter {
    ofstream of;
    int cnt;
public:
    HexWritter(char *name);
    void write( int val );
};

HexWritter::HexWritter( char* name ) {
    char *fname = new char[ strlen(name)+4 ];
    strcpy( fname, name );
    strcat( fname, ".hex" );
    of.open(fname);
    delete[] fname;
    cnt=0;
}

void HexWritter::write( int val ) {
    if(cnt==15) {
        of << hex << val << '\n';
        cnt=0;
    }
    else cnt++;
}


int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    bool trace = true, slow=false;
    RipParser gym;
    bool forever=true;
    char *gym_filename;
    vluint64_t time_limit = 0;

    for( int k=1; k<argc; k++ ) {
        if( string(argv[k])=="-slow" )  {  slow=true;  continue; }
        if( string(argv[k])=="-trace" ) { trace=true;  continue; }
        if( string(argv[k])=="-f" ) { 
            gym_filename = argv[++k];
            if( !gym.open( gym_filename ) ) return 1;
            continue;
        }
        if( string(argv[k])=="-time" ) { 
            int aux;
            sscanf(argv[++k],"%d",&aux);
            time_limit = aux;
            time_limit *= 1000000;
            forever=false;
            cout << "Simulate until " << time_limit/1000000 << "ms\n";
            continue; 
        }
        cout << "ERROR: Unknown argument " << argv[k] << "\n";
        return 1;
    }
    SimTime sim(trace);
    sim.set_time_limit( time_limit );
    CmdWritter writter( sim );
    HexWritter hex_wr( gym_filename );

    // Reset
    sim.rst = 1;
    // cout << "Reset\n";
    while( sim.get_time() < 8*sim.period() ) sim.next_quarter();
    sim.rst = 0;
    while( sim.get_time() < 16*sim.period() ) sim.next_quarter();

    enum { WRITE_VAL, WAIT_FINISH } state;
    state = WRITE_VAL;
    
    vluint64_t timeout=0;
    // cout << "Main loop\n";
    vluint64_t wait=0;

    vluint64_t adjust_sum=0;
    int next_verbosity = 200;
    vluint64_t next_sample=0;
    while( forever || !sim.finish() ) {
        writter.Eval();
        if( sim.next_quarter() ) {
            hex_wr.write( sim.sound );
            //cout << "writte done = " << writter.Done() << '\n';
            if( sim.get_time() < wait || !writter.Done() ) continue;
            switch( gym.parse() ) {
                default: 
                    cout << "Unknown command.\n";
                    goto finish;
                case RipParser::cmd_write: 
                    writter.Write( gym.val );
                    break; // parse register
                case RipParser::cmd_wait: 
                    wait=sim.period() * gym.wait;
                    wait+=sim.get_time();
                    timeout=0;
                    break;// wait 16.7ms    
                case RipParser::cmd_finish: // reached end of file
                    cout << "Finished parsing.\n";
                    goto finish;
                case RipParser::cmd_error: // unsupported command
                    cout << "ERROR: parse error\n";
                    goto finish;                
            }       
        }
    }
finish:
    if( main_time>1000000000 ) { // sim lasted for seconds
        cout << "$finish at " << dec << sim.get_time_s() << "s = " << sim.get_time_ms() << " ms\n";
    } else {
        cout << "$finish at " << dec << sim.get_time_ms() << "ms = " << sim.get_time() << " ns\n";
    }
    // "VerilatedCov::write("log/cov.dat");
 }


CmdWritter::CmdWritter( SimTime &_sim ) : sim(_sim) {
    last_clk = 0;
    state    = 2;
    done     = true;
}

void CmdWritter::Write( int _val ) {
    val   = _val;
    done  = false;
    state = 0;
}

void CmdWritter::Eval() {   
    int clk = sim.clk;
    //cout << "CmdWritter::Eval " << clk << '\n';
    if( !clk && last_clk ) {
        switch( state ) {
            case 0: 
                //cout << "0";
                sim.din = val;
                sim.wr_n = 0;
                state=1;
                break;
            case 1:
                sim.wr_n = 1;
                state = 2;
                break;
            case 2:             
                done = true;
                state=2;    // stay here until new write
                break;
            default: 
                cout << "Unexpected CmdWritter state\n";
                break;
        }
        //cout << "**" << sim.wr_n << '\n';
    }
    last_clk = clk;
}
