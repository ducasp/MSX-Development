#pragma once
// ----------------------------------------------------------
//		printinterface.h - by Danilo Angelo, 2023
//
//		Interface for print and debug functionalities.
// ----------------------------------------------------------

#ifndef  __PRINTINTERFACE_H__							
#define  __PRINTINTERFACE_H__	

#include "targetconfig.h"

extern void print(const unsigned char*);
extern const unsigned char linefeed[];

#ifdef DEBUG
extern const unsigned char msgdbg[];
#define dbg(msg)	do { print (msgdbg); print(msg); } while(0)
#else
#define dbg(msg)	// nothing
#endif

#endif	//  __PRINTINTERFACE_H__
