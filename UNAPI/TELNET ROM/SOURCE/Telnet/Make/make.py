# ----------------------------------------------------------
#		make.py - by Danilo Angelo, 2023
#
#		Build script for MSX projects.
#
#       Run with:
#       python .\Make\make.py <profile> [clean] [all]
#       Ex: python .\Make\make.py Debug clean all
# ----------------------------------------------------------

# -----------------------------------------------------------------------------------
OPEN1 = r'MSX SDCC Make Script Copyright © 2020-2023 Danilo Angelo'
OPEN2 = r'version 00.06.01 - Codename Sam'
# -----------------------------------------------------------------------------------

from dis import code_info
import sys
import platform
from datetime import datetime, date
import os
import subprocess
import string
import shlex
import re
import posixpath
import ntpath
import traceback 

# -----------------------------------------------------------------------------------
# HELPER FUNCTIONS
# -----------------------------------------------------------------------------------

## FIX PATH TO OS-SPECIFIC FORMAT
def fixPath (path) -> str:
    result = path.replace(separator, os.sep)
    return result

## FIX DOUBLE LINE-FEED
def fixLF (string) -> str:
    result = re.sub('\x0d*\x0a', '\n', string)
    return result

## DEBUG
def debug(debugLevel, message):
	if debugLevel <= VAR['BUILD_DEBUG']:
		print(message)
	return


## EXECUTE WITHOUT FIX
def executeWithoutFix(debugLevel, commandLine):
    cl = commandLine
    debug(debugLevel, '## {}'.format(cl))
    tokens = shlex.split(cl)
    
    if VAR['DBG_PARAMS'] <= VAR['BUILD_DEBUG']:
        for index, token in enumerate (tokens[1:]):
            print('ARG[{}]={}'.format(index + 1, token))

    execution = subprocess.run(tokens, capture_output=True)
    if execution.returncode > 0:
        debug (VAR['DBG_ERROR'], '### Error {} executing'.format(execution.returncode))
        debug (VAR['DBG_ERROR'], '### {}'.format(commandLine))
        debug (VAR['DBG_ERROR'], '### error message: {}'.format(fixLF(execution.stderr.decode())))
        raise Exception(execution.returncode)
    elif debugLevel <= VAR['BUILD_DEBUG']:
        print (fixLF(execution.stdout.decode()))

    return


## EXECUTE
def execute(debugLevel, commandLine):
    executeWithoutFix (debugLevel, fixPath(commandLine))
    return


## EXECUTE ACTION
def execAction (phase):
    pTokens=phase.split()
    action = "{}_{}_ACTION".format(pTokens[0].upper(), pTokens[1].upper())
    if action in VAR:
        commandLine = VAR[action]
        if not commandLine == '':
            debug(VAR['DBG_STEPS'], '-------------------------------------------------------------------------------')
            debug(VAR['DBG_STEPS'], 'Executing {} action...'.format(phase))
            executeWithoutFix(VAR['DBG_CALL3'], '{} {}'.format(VAR['SHELL_PREFIX'], commandLine))
            debug(VAR['DBG_STEPS'], 'Done executing {} action.'.format(phase))
    return


## RESOLVE STRING
def resolveString (string):
    while (True):
        foundVar=re.search(r'\[(.*?)\]', string)
        if foundVar:
            name=foundVar.group(0)
            string = string.replace(name, VAR[name[1:-1]])
        else:
            break
    return string


## RESOLVE VARIABLES
def resolveVariables ():
    for key, value in VAR.items():
        if isinstance(value, str):
            VAR[key] = resolveString(value)
    return


## SET VARIABLES
def setVar (key, value):
    try:
        VAR[key]=int(value)
    except ValueError:
        VAR[key]=value
    return


## CHECK IF VARIABLES ARE SET
def isSet (key) -> bool:
    if VAR.get(key) == None:
        return False
    v = VAR[key]
    return not ((v == '') or (v == None))
    
## ACCUMULATE HEADER SIZES
def getHeaderSize() -> int:
    result = 0
    global OBJLIST
    for relFile in OBJLIST:
        debug (VAR['DBG_DETAIL'], 'Analyzing "{}"...'.format(relFile))
        if relFile[-4:].lower() == '.rel':
            debug(VAR['DBG_EXTROVERT'], 'Opening file {}.'.format(relFile))
            with open(relFile, 'r') as f1:
                debug(VAR['DBG_VERBOSE'], 'Opened file {}.'.format(relFile))
                for line in f1:
                    size = 0
                    line1 = line.strip()
                    tokens = line1.split()
                    if len(tokens) >= 4:
                        key = tokens[1]
                        value = int('0x{}'.format(tokens[3]), 16)
                        if key == '_HEADER0':
                            size = value
                        elif VAR['CODE_AFTER_MDO'] == 1:
                            # could not get SDCC to put _CODE after _MDO*,
                            # so I parameterized this section.
                            if ((key == '_MDONAME') or (key == '_MDOHOOKS') or 
                                (key == '_MDOCHILDLIST') or (key == '_MDOCHILDLISTFINAL') or 
                                (key == '_MDOCHILDREN') or (key == '_MDOHOOKIMPLEMENTATIONS') or 
                                (key == '_MDOHOOKIMPLEMENTATIONSFINAL') or (key == '_MDOSERVICES')):
                                size = value

                    if size > 0:
                        result += size
                        debug (VAR['DBG_EXTROVERT'], 'Found {} bytes in "{}" (Total: {}).'.format(size, relFile, result))
    return result

# -----------------------------------------------------------------------------------
# BUILD PHASES
# -----------------------------------------------------------------------------------
def setDebugLevel():
    global BUILD_DEBUG_NAME
    filename = fixPath (r'{}\TargetConfig_{}.txt'.format(VAR['MSX_CFG_PATH'], VAR['PROFILE']))
    with open(filename, 'r') as f1:
        for line in f1:
            line1 = line.strip()
            tokens = line1.split()
            if len(tokens) > 0:
                if tokens[0] == 'BUILD_DEBUG':
                    setVar ('BUILD_DEBUG', tokens[1])
                    setVar ('BUILD_DEBUG_NAME', '')
                    for key, value in VAR.items():
                        if (key[0:4] == 'DBG_') and (str(value) == tokens[1]):
                            setVar ('BUILD_DEBUG_NAME', key)
                    break
    f1.close()


def opening():
    debug(VAR['DBG_OPENING'], '-------------------------------------------------------------------------------')
    debug(VAR['DBG_OPENING'], OPEN1)
    debug(VAR['DBG_OPENING'], OPEN2)
    debug(VAR['DBG_SETTING'], 'Profile: {}'.format(VAR['PROFILE']))
    debug(VAR['DBG_SETTING'], 'Build Debug Level: {}({})'.format(VAR['BUILD_DEBUG'], VAR['BUILD_DEBUG_NAME']))
    return


def configureTarget():
    debug(VAR['DBG_STEPS'], '-------------------------------------------------------------------------------')
    debug(VAR['DBG_STEPS'], 'Configuring target...')
    
    debug(VAR['DBG_VERBOSE'], 'Building targetconfig files\' headers.')
    global tc_h
    global tc_s
    
    tc_h = tc_h + '//-------------------------------------------------\n'
    tc_h = tc_h + '// targetconfig.h created automatically by make.bat\n'
    tc_h = tc_h + '// on {}, {}\n'.format(VAR['MSX_BUILD_TIME'], VAR['MSX_BUILD_DATE'])
    tc_h = tc_h + '//\n'
    tc_h = tc_h + '// DO NOT BOTHER EDITING THIS.\n'
    tc_h = tc_h + '// ALL CHANGES WILL BE LOST.\n'
    tc_h = tc_h + '//-------------------------------------------------\n'
    tc_h = tc_h + '\n'
    tc_h = tc_h + '#ifndef  __TARGETCONFIG_H__\n'
    tc_h = tc_h + '#define  __TARGETCONFIG_H__\n'
    tc_h = tc_h + '\n'

    tc_s = tc_s + ';-------------------------------------------------\n'
    tc_s = tc_s + '; targetconfig.h created automatically by make.bat\n'
    tc_s = tc_s + '; on {}, {}\n'.format(VAR['MSX_BUILD_TIME'], VAR['MSX_BUILD_DATE'])
    tc_s = tc_s + ';\n'
    tc_s = tc_s + '; DO NOT BOTHER EDITING THIS.\n'
    tc_s = tc_s + '; ALL CHANGES WILL BE LOST.\n'
    tc_s = tc_s + ';-------------------------------------------------\n'
    tc_s = tc_s + '\n'
    
    filename = fixPath (r'{}\TargetConfig_{}.txt'.format(VAR['MSX_CFG_PATH'], VAR['PROFILE']))
    debug(VAR['DBG_EXTROVERT'], 'Opening file {}.'.format(filename))
    with open(filename, 'r') as f1:
        debug(VAR['DBG_VERBOSE'], 'Opened file {}.'.format(filename))
        targetSection=None
        for line in f1:
            line1 = line.strip()
            tokens = line1.split()
            if len(tokens) > 0:
                key = tokens[0]
                if not key[0] == ';':
                    if key[0] == '.':
                        targetSection=key
                        debug(VAR['DBG_EXTROVERT'], 'Entered section {}.'.format(targetSection))
                    else:
                        value = ''
                        for token in tokens[1:]:
                            if token[0] == ';':
                                break
                            if len(value) == 0:
                                value=token
                            else:
                                value='{} {}'.format(value, token)

                        debug(VAR['DBG_DETAIL'], 'Found setting {} = {}.'.format(key, value))
                        
                        setVar (key, value)
                        if value == '':
                            if targetSection == '.APPLICATION':
                                tc_h = tc_h + '#define  {}\n'.format(key)
                                tc_s = tc_s + '{} = 1\n'.format(key)
                        else:
                            if targetSection == '.APPLICATION':
                                upperValue = value.upper()
                                if upperValue == '_OFF':
                                    tc_h = tc_h + '//#define  {}\n'.format(key)
                                    tc_s = tc_s + '{} = 0\n'.format(key)
                                elif upperValue == '_ON':
                                    tc_h = tc_h + '#define  {}\n'.format(key)
                                    tc_s = tc_s + '{} = 1\n'.format(key)
                                else:
                                    tc_h = tc_h + '#define  {}  {}\n'.format(key, value)
                                    tc_s = tc_s + '{} = {}\n'.format(key, value)
    f1.close()
    
    debug(VAR['DBG_VERBOSE'], 'Finalizing targetconfig.h.')
    tc_h = tc_h + '\n'
    tc_h = tc_h + '#endif	//  __TARGETCONFIG_H__\n'

    debug(VAR['DBG_VERBOSE'], 'Resolving variables.')
    VAR['MSX_OBJ_PATH'] = fixPath(VAR['MSX_OBJ_PATH'])
    VAR['MSX_BIN_PATH'] = fixPath(VAR['MSX_BIN_PATH'])
    VAR['MSX_DEV_PATH'] = fixPath(VAR['MSX_DEV_PATH'])
    VAR['MSX_LIB_PATH'] = fixPath(VAR['MSX_LIB_PATH'])
    resolveVariables()
    
    debug(VAR['DBG_VERBOSE'], 'Configuring verbose parameters.')
    if VAR['DBG_TOOLSDETAIL'] <= VAR['BUILD_DEBUG']:
        VAR['SDCC_DETAIL'] = '-V --verbose'
        VAR['SYMBOL_DETAIL'] = '-v'
        VAR['HEX2BIN_DETAIL'] = '-v'
    else:
        VAR['SDCC_DETAIL'] = ''
        VAR['SYMBOL_DETAIL'] = ''
        VAR['HEX2BIN_DETAIL'] = ''

    debug(VAR['DBG_SETTING'], '-----------------------------------')
    debug(VAR['DBG_SETTING'], 'Filesystem settings...')
    debug(VAR['DBG_SETTING'], 'Current dir: {}'.format(VAR['CURRENT_DIR']))
    debug(VAR['DBG_SETTING'], 'Target file: {}.{}'.format(VAR['MSX_FILE_NAME'], VAR['MSX_FILE_EXTENSION']))
    debug(VAR['DBG_SETTING'], 'Object path: {}'.format(VAR['MSX_OBJ_PATH']))
    debug(VAR['DBG_SETTING'], 'Binary path: {}'.format(VAR['MSX_BIN_PATH']))
    debug(VAR['DBG_SETTING'], 'MSX dev path: {}'.format(VAR['MSX_DEV_PATH']))
    debug(VAR['DBG_SETTING'], 'MSX lib path: {}'.format(VAR['MSX_LIB_PATH']))

    debug(VAR['DBG_STEPS'], 'Done configuring target.')
    return        


def createDirStruct():
    if not os.path.exists(VAR['MSX_OBJ_PATH']):
        debug(VAR['DBG_STEPS'], '-------------------------------------------------------------------------------')
        debug(VAR['DBG_STEPS'], 'Creating OBJ path...')
        os.makedirs(VAR['MSX_OBJ_PATH'])
        debug(VAR['DBG_STEPS'], 'Done creating OBJ path.')
        
    if not os.path.exists(VAR['MSX_BIN_PATH']):
        debug(VAR['DBG_STEPS'], '-------------------------------------------------------------------------------')
        debug(VAR['DBG_STEPS'], 'Creating BIN path...')
        os.makedirs(VAR['MSX_BIN_PATH'])
        debug(VAR['DBG_STEPS'], 'Done creating BIN path.')
    return


def clean():
    debug(VAR['DBG_STEPS'], '-------------------------------------------------------------------------------')
    debug(VAR['DBG_STEPS'], 'Cleaning...')

    filename = os.path.join(VAR['MSX_OBJ_PATH'], '*.*')
    files = os.listdir(VAR['MSX_OBJ_PATH'])
    if len(files) > 0:
        debug(VAR['DBG_EXTROVERT'], 'Cleaning "{}"...'.format(filename))
        for f in files:
            os.remove(os.path.join(VAR['MSX_OBJ_PATH'], f))

    filename = os.path.join(VAR['MSX_BIN_PATH'], '{}.{}'.format(VAR['MSX_FILE_NAME'], VAR['MSX_FILE_EXTENSION']))
    if os.path.exists(filename):
        debug(VAR['DBG_EXTROVERT'], 'Cleaning "{}"...'.format(filename))
        os.remove(filename)
        
    debug(VAR['DBG_STEPS'], 'Done cleaning.')
    return


def saveTargetHeaders():
    debug(VAR['DBG_STEPS'], '-------------------------------------------------------------------------------')
    debug(VAR['DBG_STEPS'], 'Saving target headers...')

    filename = os.path.join(VAR['MSX_OBJ_PATH'], 'targetconfig.h')
    debug(VAR['DBG_EXTROVERT'], 'Saving {}.'.format(filename))
    f1 = open(filename, 'w')
    f1.write(tc_h)
    f1.close()
    
    filename = os.path.join(VAR['MSX_OBJ_PATH'], 'targetconfig.s')
    debug(VAR['DBG_EXTROVERT'], 'Saving {}.'.format(filename))
    f1 = open(filename, 'w')
    f1.write(tc_s)
    f1.close()

    debug(VAR['DBG_STEPS'], 'Done saving target headers.')
    return


def configureBuildEvents():
    debug(VAR['DBG_STEPS'], '-------------------------------------------------------------------------------')
    debug(VAR['DBG_STEPS'], 'Configuring build events...')
    
    filename = fixPath (r'{}\BuildEvents.txt'.format(VAR['MSX_CFG_PATH']))
    debug(VAR['DBG_EXTROVERT'], 'Opening file {}.'.format(filename))
    with open(filename, 'r') as f1:
        debug(VAR['DBG_VERBOSE'], 'Opened file {}.'.format(filename))
        for line in f1:
            line1 = line.strip()
            tokens = line1.split()
            if len(tokens) > 0:
                key = tokens[0]
                if not key[0] == ';':
                    value = ''
                    for token in tokens[1:]:
                        if token[0] == ';':
                            break
                        if len(value) == 0:
                            value=token
                        else:
                            value='{} {}'.format(value, token)
                    debug(VAR['DBG_DETAIL'], 'Found action "{}" for event {}.'.format(value, key))
                    VAR[key] = fixPath(value)
    f1.close()
    resolveVariables()

    if isSet('BUILD_START_ACTION'):
        debug(VAR['DBG_SETTING'], 'Build start action: [NONE]')
    else:
        debug(VAR['DBG_SETTING'], 'Build start action: {}'.format(VAR['BUILD_START_ACTION']))
    if isSet('BEFORE_COMPILE_ACTION'):
        debug(VAR['DBG_SETTING'], 'Before compile action: [NONE]')
    else:
        debug(VAR['DBG_SETTING'], 'Before compile action: {}'.format(VAR['BEFORE_COMPILE_ACTION']))
    if isSet('AFTER_COMPILE_ACTION'):
        debug(VAR['DBG_SETTING'], 'After compile action: [NONE]')
    else:
        debug(VAR['DBG_SETTING'], 'After compile action: {}'.format(VAR['AFTER_COMPILE_ACTION']))
    if isSet('AFTER_BINARY_ACTION'):
        debug(VAR['DBG_SETTING'], 'After binary generation action: [NONE]')
    else:
        debug(VAR['DBG_SETTING'], 'After binary generation action: {}'.format(VAR['AFTER_BINARY_ACTION']))
    if isSet('BUILD_END_ACTION'):
        debug(VAR['DBG_SETTING'], 'Build end action: [NONE]')
    else:
        debug(VAR['DBG_SETTING'], 'Build end action: {}'.format(VAR['BUILD_END_ACTION']))
        
    debug(VAR['DBG_STEPS'], 'Done configuring build events...')
    return

def configureApplication():
    debug(VAR['DBG_STEPS'], '-------------------------------------------------------------------------------')
    debug(VAR['DBG_STEPS'], 'Configuring application...')

    debug(VAR['DBG_VERBOSE'], 'Building applicationsettings files\' headers.')

    global as_h                         # application settings (h)
    global as_s                         # application settings (s)
    bu_s = ''                           # bin_usercalls (s)
    rci_s = 'callStatementIndex::\n'    # rom_callexpansionindex (s)
    rch_s = ''                          # rom_callexpansionhandler (s)
    rdi_s = 'deviceIndex::\n'           # rom_deviceexpansionindex (s)
    rdh_s = ''                          # rom_deviceexpansionhandler (s)
    
    as_h = as_h + '//-------------------------------------------------\n'
    as_h = as_h + '// applicationsettings.h created automatically\n'
    as_h = as_h + '// by make.bat\n'
    as_h = as_h + '// on {}, {}\n'.format(VAR['MSX_BUILD_TIME'], VAR['MSX_BUILD_DATE'])
    as_h = as_h + '//\n'
    as_h = as_h + '// DO NOT BOTHER EDITING THIS.\n'
    as_h = as_h + '// ALL CHANGES WILL BE LOST.\n'
    as_h = as_h + '//-------------------------------------------------\n'
    as_h = as_h + '\n'
    as_h = as_h + '#ifndef  __APPLICATIONSETTINGS_H__\n'
    as_h = as_h + '#define  __APPLICATIONSETTINGS_H__\n'
    as_h = as_h + '\n'

    as_s = as_s + ';-------------------------------------------------\n'
    as_s = as_s + '; applicationsettings.h created automatically\n'
    as_s = as_s + '; by make.bat\n'
    as_s = as_s + '; on {}, {}\n'.format(VAR['MSX_BUILD_TIME'], VAR['MSX_BUILD_DATE'])
    as_s = as_s + ';\n'
    as_s = as_s + '; DO NOT BOTHER EDITING THIS.\n'
    as_s = as_s + '; ALL CHANGES WILL BE LOST.\n'
    as_s = as_s + ';-------------------------------------------------\n'
    as_s = as_s + '\n'

    filename = fixPath (r'{}\ApplicationSettings.txt'.format(VAR['MSX_CFG_PATH']))
    debug(VAR['DBG_EXTROVERT'], 'Opening file {}.'.format(filename))
    with open(filename, 'r') as f1:
        debug(VAR['DBG_VERBOSE'], 'Opened file {}.'.format(filename))
        for line in f1:
            line1 = line.strip()
            tokens = line1.split()
            if len(tokens) > 0:
                key = tokens[0]
                if not key[0] == ';':
                    value = ''
                    for token in tokens[1:]:
                        if token[0] == ';':
                            break
                        if len(value) == 0:
                            value=token
                        else:
                            value='{} {}'.format(value, token)
                    
                    debug(VAR['DBG_DETAIL'], 'Found setting {} = {}.'.format(key, value))
                    if key == 'PROJECT_TYPE':
                        setVar ('PROJECT_TYPE', value)
                        if value == 'MDO':
                            setVar ('MDO_SUPPORT', 1)
                            
                    elif key == 'FILESTART':
                        setVar ('FILE_START', value)
                        as_s = as_s + 'fileStart .equ {}\n'.format(value)
                        
                    elif key == 'SDCCCALL':
                        setVar ('SDCC_CALL', value)
                        as_s = as_s + '__SDCCCALL = {}\n'.format(value)
                
                    elif key == 'GLOBALS_INITIALIZER':
                        if value.lower() == '_off':
                            as_s = as_s + 'GLOBALS_INITIALIZER = 0\n'
                        else:
                            as_s = as_s + 'GLOBALS_INITIALIZER = 1\n'

                    elif key == 'ROM_SIZE':
                        if value.lower() == '16k':
                            setVar ('BIN_SIZE', 4000)
                        else:
                            setVar ('BIN_SIZE', 8000)

                    elif key == 'CODE_LOC':
                        setVar ('CODE_LOC', value)

                    elif key == 'DATA_LOC':
                        setVar ('DATA_LOC', value)

                    elif key == 'PARAM_HANDLING_ROUTINE':
                        as_s = as_s + 'PARAM_HANDLING_ROUTINE = {}\n'.format(value)

                    elif key == 'SYMBOL':
                        bu_s = bu_s + '.globl {}\n'.format(value)
                        bu_s = bu_s + '.dw {}\n'.format(value)

                    elif key == 'ADDRESS':
                        bu_s = bu_s + '.dw {}\n'.format(value)

                    elif key == 'CALL_STATEMENT':
                        rci_s = rci_s + '.dw		            callStatement_{}\n'.format(value)
                        rch_s = rch_s + '.globl	                _onCall{}\n'.format(value)
                        rch_s = rch_s + 'callStatement_{}::\n'.format(value)
                        rch_s = rch_s + ".asciz		        '{}'\n".format(value)
                        rch_s = rch_s + '.dw		            _onCall{}\n'.format(value)

                    elif key == 'DEVICE':
                        rdi_s = rdi_s + '.dw		            device_{}\n'.format(value)
                        rdh_s = rdh_s + '.globl		            _onDevice{}_IO\n'.format(value)
                        rdh_s = rdh_s + '.globl		            _onDevice{}_getId\n'.format(value)
                        rdh_s = rdh_s + 'device_{}::\n'.format(value)
                        rdh_s = rdh_s + ".asciz		            '{}'\n".format(value)
                        rdh_s = rdh_s + '.dw		            _onDevice{}_IO\n'.format(value)
                        rdh_s = rdh_s + '.dw		            _onDevice{}_getId\n'.format(value)
                        
                    else:
                        if value.lower() == '_off':
                            as_h = as_h + '//#define {}\n'.format(key)
                            as_s = as_s + '{} = 0\n'.format(key)
                            
                        elif value.lower() == '_on':
                            as_h = as_h + '#define {}\n'.format(key)
                            as_s = as_s + '{} = 1\n'.format(key)
                            if key == 'MDO_SUPPORT':
                                setVar ('MDO_SUPPORT', 1)

                        elif value == '':
                            as_h = as_h + '#define {}\n'.format(key)
                            as_s = as_s + '{} = 1\n'.format(key)

                        else:
                            as_h = as_h + '#define {} {}\n'.format(key, value)
                            as_s = as_s + '{} = {}\n'.format(key, value)
    f1.close()

    if VAR['PROJECT_TYPE'] == 'BIN':
        debug(VAR['DBG_DETAIL'], 'Adding specific BIN settings...')
        as_s = as_s + '\n'
        as_s = as_s + '.macro MCR_USRCALLSINDEX\n'
        if not bu_s == '':
            as_s = as_s + '\n'
            as_s = as_s + '_BASIC_USR_INDEX::\n'
            as_s = as_s + bu_s
        as_s = as_s + '.endm\n'
        
    elif VAR['PROJECT_TYPE'] == 'ROM':
        debug(VAR['DBG_DETAIL'], 'Adding specific ROM settings...')
        as_s = as_s + '\n'
        as_s = as_s + '.macro MCR_CALLEXPANSIONINDEX\n'
        if not rch_s == '':
            as_s = as_s + rci_s
            as_s = as_s + '.dw	#0\n'
            as_s = as_s + rch_s
        as_s = as_s + '.endm\n'

        as_s = as_s + '\n'
        as_s = as_s + '.macro MCR_DEVICEEXPANSIONINDEX\n'
        if not rdh_s == '':
            as_s = as_s + rdi_s
            as_s = as_s + '.dw	#0\n'
            as_s = as_s + rdh_s
        as_s = as_s + '.endm\n'
            
    debug(VAR['DBG_VERBOSE'], 'Finalizing applicationsettings.h.')
    as_h = as_h + '\n'
    as_h = as_h + '#endif	//  __APPLICATIONSETTINGS_H__\n'

    debug(VAR['DBG_VERBOSE'], 'Resolving variables.')
    resolveVariables()
    
    debug(VAR['DBG_STEPS'], 'Done configuring application.')
    return

def configureMDO():
    debug(VAR['DBG_STEPS'], '-------------------------------------------------------------------------------')
    debug(VAR['DBG_STEPS'], 'Configuring MDO support...')

    debug(VAR['DBG_VERBOSE'], 'Building MDO files\' headers.')
    global as_h                         # application settings (h)
    global as_s                         # application settings (s)
    global mi_h                         # mdointerface (h)
    global mi_s                         # mdointerface (s)
    global mim_s                        # mdoimplementation (s)

    mi_h = mi_h + '//-------------------------------------------------\n'
    mi_h = mi_h + '// mdointerface.h created automatically\n'
    mi_h = mi_h + '// by make.bat\n'
    mi_h = mi_h + '// on {}, {}\n'.format(VAR['MSX_BUILD_TIME'], VAR['MSX_BUILD_DATE'])
    mi_h = mi_h + '//\n'
    mi_h = mi_h + '// DO NOT BOTHER EDITING THIS.\n'
    mi_h = mi_h + '// ALL CHANGES WILL BE LOST.\n'
    mi_h = mi_h + '//-------------------------------------------------\n'
    mi_h = mi_h + '\n'
    mi_h = mi_h + '#ifndef  __MDOINTERFACE_H__\n'
    mi_h = mi_h + '#define  __MDOINTERFACE_H__\n'
    mi_h = mi_h + '\n'
    mi_h = mi_h + '#ifdef MDO_SUPPORT\n'
    mi_h = mi_h + '\n'
    mi_h = mi_h + '#include "mdostructures.h"\n'
    mi_h = mi_h + '\n'
    mi_h = mi_h + 'extern unsigned char mdoLoad (mdoHandler*);\n'
    mi_h = mi_h + 'extern unsigned char mdoRelease (mdoHandler*);\n'
    mi_h = mi_h + 'extern unsigned char mdoLink (mdoHandler*);\n'
    mi_h = mi_h + 'extern unsigned char mdoUnlink (mdoHandler*);\n'
    mi_h = mi_h + '\n'

    mi_s = mi_s + ';-------------------------------------------------\n'
    mi_s = mi_s + '; mdointerface.s created automatically\n'
    mi_s = mi_s + '; by make.bat\n'
    mi_s = mi_s + '; on {}, {}\n'.format(VAR['MSX_BUILD_TIME'], VAR['MSX_BUILD_DATE'])
    mi_s = mi_s + ';\n'
    mi_s = mi_s + '; DO NOT BOTHER EDITING THIS.\n'
    mi_s = mi_s + '; ALL CHANGES WILL BE LOST.\n'
    mi_s = mi_s + ';-------------------------------------------------\n'
    mi_s = mi_s + '\n'
    mi_s = mi_s + '.globl _mdoLoad\n'
    mi_s = mi_s + '.globl _mdoRelease\n'
    mi_s = mi_s + '.globl _mdoLink\n'
    mi_s = mi_s + '.globl _mdoUnlink\n'
    mi_s = mi_s + '\n'
	
    mim_s = mim_s + ';-------------------------------------------------\n'
    mim_s = mim_s + '; mdoimplementation.s created automatically\n'
    mim_s = mim_s + '; by make.bat\n'
    mim_s = mim_s + '; on {}, {}\n'.format(VAR['MSX_BUILD_TIME'], VAR['MSX_BUILD_DATE'])
    mim_s = mim_s + ';\n'
    mim_s = mim_s + '; DO NOT BOTHER EDITING THIS.\n'
    mim_s = mim_s + '; ALL CHANGES WILL BE LOST.\n'
    mim_s = mim_s + ';-------------------------------------------------\n'
    mim_s = mim_s + '.globl s__AFTERHEAP\n'
    mim_s = mim_s + '\n'

    filename = fixPath (r'{}\MDOSettings.txt'.format(VAR['MSX_CFG_PATH']))
    debug(VAR['DBG_EXTROVERT'], 'Opening file {}.'.format(filename))
    with open(filename, 'r') as f1:
        debug(VAR['DBG_VERBOSE'], 'Opened file {}.'.format(filename))
        for line in f1:
            line1 = line.strip()
            tokens = line1.split()
            if len(tokens) > 0:
                key = tokens[0]
                if not key[0] == ';':
                    value = ''
                    for token in tokens[1:]:
                        if token[0] == ';':
                            break
                        if len(value) == 0:
                            value=token
                        else:
                            value='{} {}'.format(value, token)
                    
                    debug(VAR['DBG_DETAIL'], 'Found setting {} = {}.'.format(key, value))
                    
                    if key == "MDO_APPLICATION_PROJECT_PATH":
                        setVar ('MDO_APP_PROJECT_PATH', value)
                        setVar ('MDO_APP_MDO_PATH', '{}/MSX/MSX-DOS'.format(value))
                        mim_s = mim_s + '.include "{}/mdostructures.s"\n'.format(VAR['MDO_APP_MDO_PATH'])
                    
                    elif key == 'MDO_PARENT_PROJECT_PATH':
                        setVar ('MDO_PARENT_PROJECT_PATH', value)
                        filename = fixPath ('{}/{}/objs/PARENT_AFTERHEAP'.format(value, VAR['PROFILE']))
                        debug(VAR['DBG_EXTROVERT'], 'Reading MDO_PARENT_AFTERHEAP from {}.'.format(filename))
                        with open(filename, 'r') as f2:
                            debug(VAR['DBG_VERBOSE'], 'Opened file {}.'.format(filename))
                            setVar ('MDO_PARENT_AFTERHEAP', f2.read().strip())
                            debug(VAR['DBG_VERBOSE'], 'MDO_PARENT_AFTERHEAP read.')
                        f2.close()
                        setVar ('MDO_PARENT_INTERFACE', '{}/{}/objs/parentinterface.s'.format(value, VAR['PROFILE']))
                        mim_s = mim_s + '.include "{}"\n'.format(VAR['MDO_PARENT_INTERFACE'])

                    elif key == 'FILESTART':
                        if value == 'PARENT_AFTERHEAP':
                            setVar ('FILE_START', VAR['MDO_PARENT_AFTERHEAP'])
                        else:
                            setVar ('FILE_START', value)
                        as_s = as_s + 'fileStart .equ {}\n'.format(VAR['FILE_START'])
                            
                    elif key == "MDO_HOOK":
                        mhtokens = value.split('|')
                        mim_s = mim_s + 'MDO_HOOK {}\n'.format (mhtokens[1])
                        mi_h = mi_h + 'extern {} {}_hook {};\n'.format (mhtokens[0], mhtokens[1], mhtokens[2])
                        mi_s = mi_s + '.globl _{}_hook\n'.format (mhtokens[1])

                    elif key == "MDO_CHILD":
                        mim_s = mim_s + 'MDO_CHILD {}\n'.format (line1[9::])
                        mi_h = mi_h + 'extern mdoHandler {};\n'.format (tokens[1])
                        mi_s = mi_s + '.globl _{}\n'.format (tokens[1])

                    else:
                        mim_s = mim_s + '{} {}\n'.format (key, value)

    f1.close()

    debug(VAR['DBG_VERBOSE'], 'Finalizing mdointerface.h.')
    mi_h = mi_h + '\n'
    mi_h = mi_h + '#endif	//  MDO_SUPPORT\n'
    mi_h = mi_h + '\n'
    mi_h = mi_h + '#endif	//  __MDOINTERFACE_H__\n'
    mi_h = mi_h + '\n'
    
    debug(VAR['DBG_STEPS'], 'Done building MDO support files.')
    return

def saveMDOHeaders():
    debug(VAR['DBG_STEPS'], '-------------------------------------------------------------------------------')
    debug(VAR['DBG_STEPS'], 'Saving MDO headers...')

    filename = os.path.join(VAR['MSX_OBJ_PATH'], 'mdointerface.h')
    debug(VAR['DBG_EXTROVERT'], 'Saving {}.'.format(filename))
    f1 = open(filename, 'w')
    f1.write(mi_h)
    f1.close()
    
    filename = os.path.join(VAR['MSX_OBJ_PATH'], 'mdointerface.s')
    debug(VAR['DBG_EXTROVERT'], 'Saving {}.'.format(filename))
    f1 = open(filename, 'w')
    f1.write(mi_s)
    f1.close()

    filename = os.path.join(VAR['MSX_OBJ_PATH'], 'mdoimplementation.s')
    debug(VAR['DBG_EXTROVERT'], 'Saving {}.'.format(filename))
    f1 = open(filename, 'w')
    f1.write(mim_s)
    f1.close()

    debug(VAR['DBG_STEPS'], 'Done saving MDO headers.')
    return

def saveApplicationHeaders():
    debug(VAR['DBG_STEPS'], '-------------------------------------------------------------------------------')
    debug(VAR['DBG_STEPS'], 'Saving application headers...')

    filename = os.path.join(VAR['MSX_OBJ_PATH'], 'applicationsettings.h')
    debug(VAR['DBG_EXTROVERT'], 'Saving {}.'.format(filename))
    f1 = open(filename, 'w')
    f1.write(as_h)
    f1.close()
    
    filename = os.path.join(VAR['MSX_OBJ_PATH'], 'applicationsettings.s')
    debug(VAR['DBG_EXTROVERT'], 'Saving {}.'.format(filename))
    f1 = open(filename, 'w')
    f1.write(as_s)
    f1.close()

    debug(VAR['DBG_STEPS'], 'Done saving application headers.')
    return

def collectIncludeDirs():
    debug(VAR['DBG_STEPS'], '-------------------------------------------------------------------------------')
    debug(VAR['DBG_STEPS'], 'Collecting include directories...')

    global INCDIRS
    global QUOTED_INCDIRS
    
    INCDIRS.append(VAR['MSX_OBJ_PATH'])
    
    filename = fixPath (r'{}\IncludeDirectories.txt'.format(VAR['MSX_CFG_PATH']))
    debug(VAR['DBG_EXTROVERT'], 'Opening file {}.'.format(filename))
    with open(filename, 'r') as f1:
        debug(VAR['DBG_VERBOSE'], 'Opened file {}.'.format(filename))
        for line in f1:
            line1 = line.strip()
            if len(line1) > 0:
                if not line1[0] == ';':
                    parts = line1.split(';')
                    incDir = resolveString(parts[0].strip())
                    INCDIRS.append(incDir)
                    debug(VAR['DBG_DETAIL'], 'Collected "{}".'.format(incDir))
    f1.close()

    for incDir in INCDIRS:
        QUOTED_INCDIRS.append ('-I"{}"'.format(incDir))

    debug(VAR['DBG_STEPS'], 'Done collecting include directories.')
    return


def collectCompiledLibs():
    debug(VAR['DBG_STEPS'], '-------------------------------------------------------------------------------')
    debug(VAR['DBG_STEPS'], 'Collecting compiled libraries...')

    global OBJLIST

    filename = fixPath (r'{}\Libraries.txt'.format(VAR['MSX_CFG_PATH']))
    debug(VAR['DBG_EXTROVERT'], 'Opening file {}.'.format(filename))
    with open(filename, 'r') as f1:
        debug(VAR['DBG_VERBOSE'], 'Opened file {}.'.format(filename))
        for line in f1:
            line1 = line.strip()
            if len(line1) > 0:
                if not line1[0] == ';':
                    parts = line1.split(';')
                    lib = resolveString(parts[0].strip())
                    OBJLIST.append(lib)
                    debug(VAR['DBG_DETAIL'], 'Collected "{}".'.format(lib))
    f1.close()

    debug(VAR['DBG_STEPS'], 'Done collecting compiled libraries.')
    return


def compileLibs():
    debug(VAR['DBG_STEPS'], '-------------------------------------------------------------------------------')
    debug(VAR['DBG_STEPS'], 'Compiling libraries...')

    global OBJLIST
    
    filename = fixPath (r'{}\LibrarySources.txt'.format(VAR['MSX_CFG_PATH']))
    debug(VAR['DBG_EXTROVERT'], 'Opening file {}.'.format(filename))
    with open(filename, 'r') as f1:
        debug(VAR['DBG_VERBOSE'], 'Opened file {}.'.format(filename))
        for line in f1:
            line1 = line.strip()
            if len(line1) > 0:
                if not line1[0] == ';':
                    parts = line1.split(';')
                    sourceFile = fixPath(resolveString(parts[0].strip()))
                    fName = os.path.splitext(os.path.basename(sourceFile))[0] 
                    fExt = sourceFile.split(".")[-1]
                    relFile = fixPath(os.path.join(VAR['MSX_OBJ_PATH'], '{}.rel'.format(fName)))
                    if fExt.lower() == "c":
                        debug (VAR['DBG_DETAIL'], 'Processing C file {}...'.format(sourceFile))
                        execute (VAR['DBG_CALL2'], f'sdcc --sdcccall {VAR["SDCC_CALL"]} {VAR["SDCC_DETAIL"]} {VAR["COMPILER_EXTRA_DIRECTIVES"]} -mz80 -c {" ".join(QUOTED_INCDIRS)} -o "{relFile}" "{sourceFile}"')
                    else:
                        debug (VAR['DBG_DETAIL'], 'Processing ASM file {}...'.format(sourceFile))
                        execute (VAR['DBG_CALL2'], f'sdasz80 {VAR["ASSEMBLER_EXTRA_DIRECTIVES"]} {" ".join(QUOTED_INCDIRS)} -o "{relFile}" "{sourceFile}"')
                    
                    OBJLIST.append(relFile)

    debug(VAR['DBG_STEPS'], 'Done building libraries.')
    return

def compileProject():
    debug(VAR['DBG_STEPS'], '-------------------------------------------------------------------------------')
    debug(VAR['DBG_STEPS'], 'Compiling project...')

    global OBJLIST

    filename = fixPath (r'{}\ApplicationSources.txt'.format(VAR['MSX_CFG_PATH']))
    debug(VAR['DBG_EXTROVERT'], 'Opening file {}.'.format(filename))
    with open(filename, 'r') as f1:
        debug(VAR['DBG_VERBOSE'], 'Opened file {}.'.format(filename))
        for line in f1:
            line1 = line.strip()
            if len(line1) > 0:
                if not line1[0] == ';':
                    parts = line1.split(';')
                    sourceFile = fixPath(resolveString(parts[0].strip()))
                    fName = os.path.splitext(os.path.basename(sourceFile))[0] 
                    fExt = sourceFile.split(".")[-1]
                    relFile = fixPath(os.path.join(VAR['MSX_OBJ_PATH'], '{}.rel'.format(fName)))
                    if fExt.lower() == "c":
                        debug (VAR['DBG_DETAIL'], 'Processing C file {}...'.format(sourceFile))
                        execute (VAR['DBG_CALL2'], f'sdcc --sdcccall {VAR["SDCC_CALL"]} {VAR["SDCC_DETAIL"]} {VAR["COMPILER_EXTRA_DIRECTIVES"]} -mz80 -c {" ".join(QUOTED_INCDIRS)} -o "{relFile}" "{sourceFile}"')
                    else:
                        debug (VAR['DBG_DETAIL'], 'Processing ASM file {}...'.format(sourceFile))
                        execute (VAR['DBG_CALL2'], f'sdasz80 {VAR["ASSEMBLER_EXTRA_DIRECTIVES"]} {" ".join(QUOTED_INCDIRS)} -o "{relFile}" "{sourceFile}"')
                    
                    OBJLIST.append(relFile)

    debug(VAR['DBG_STEPS'], 'Done compiling project.')
    return

def determineCodeLoc():
    debug(VAR['DBG_STEPS'], '-------------------------------------------------------------------------------')
    debug(VAR['DBG_STEPS'], 'Determining CODE-LOC...')

    DEC_HEADER_SIZE = getHeaderSize()
    HEADER_SIZE = '0x{:04x}'.format (DEC_HEADER_SIZE)
    DEC_CODE_LOC = int(VAR['FILE_START'], 16) + DEC_HEADER_SIZE
    VAR['CODE_LOC'] = '0x{:04x}'.format (DEC_CODE_LOC)
   
    debug(VAR['DBG_OUTPUT'], 'FILE_START is {}'.format(VAR['FILE_START']))
    if VAR['CODE_AFTER_MDO'] == 1:
        debug(VAR['DBG_OUTPUT'], '_HEADER and _MDO segments add up to {} ({}) bytes.'.format(HEADER_SIZE, DEC_HEADER_SIZE))
    else:                                                                       
        debug(VAR['DBG_OUTPUT'], '_HEADER contains {} ({}) bytes.'.format(HEADER_SIZE, DEC_HEADER_SIZE))
    debug(VAR['DBG_STEPS'], 'CODE-LOC determined to be {}.'.format(VAR['CODE_LOC']))
    return

def linkProject():
    debug(VAR['DBG_STEPS'], '-------------------------------------------------------------------------------')
    debug(VAR['DBG_STEPS'], 'Linking project...')

    global OBJLIST
    QUOTED_OBJLIST = []
    for obj in OBJLIST:
        QUOTED_OBJLIST.append ('"{}"'.format(obj))
 
    execute (VAR['DBG_CALL1'], f'sdcc {VAR["SDCC_DETAIL"]} {VAR["LINKER_EXTRA_DIRECTIVES"]} --code-loc {VAR["CODE_LOC"]} --data-loc {VAR["DATA_LOC"]} -mz80 --no-std-crt0 {" ".join(QUOTED_OBJLIST)} {" ".join(QUOTED_INCDIRS)} -o "{fixPath("{}/{}.ihx".format(VAR["MSX_OBJ_PATH"], VAR["MSX_FILE_NAME"]))}"')

    debug(VAR['DBG_STEPS'], 'Done linking project.')
    return

def buildBinary():
    debug(VAR['DBG_STEPS'], '-------------------------------------------------------------------------------')
    debug(VAR['DBG_STEPS'], 'Building MSX binary...')

    if VAR['BIN_SIZE'] == None:
        execute (VAR['DBG_CALL3'], f'hex2bin {VAR["HEX2BIN_DETAIL"]} {VAR["EXECGEN_EXTRA_DIRECTIVES"]} -e {VAR["MSX_FILE_EXTENSION"]} "{fixPath("{}/{}.ihx".format(VAR["MSX_OBJ_PATH"], VAR["MSX_FILE_NAME"]))}"')
    else:
        execute (VAR['DBG_CALL3'], f'hex2bin {VAR["HEX2BIN_DETAIL"]} {VAR["EXECGEN_EXTRA_DIRECTIVES"]} -e {VAR["MSX_FILE_EXTENSION"]} -l {VAR["BIN_SIZE"]} "{fixPath("{}/{}.ihx".format(VAR["MSX_OBJ_PATH"], VAR["MSX_FILE_NAME"]))}"')

    source = fixPath('{}/{}.{}'.format(VAR['MSX_OBJ_PATH'], VAR['MSX_FILE_NAME'], VAR['MSX_FILE_EXTENSION']))
    target = fixPath('{}/{}.{}'.format(VAR['MSX_BIN_PATH'], VAR['MSX_FILE_NAME'], VAR['MSX_FILE_EXTENSION']))
    debug(VAR['DBG_EXTROVERT'], 'Moving binary from "{}" to "{}"...'.format(source, target))
    os.rename(source, target)
        
    debug(VAR['DBG_STEPS'], 'Done building MSX binary.')
    return

def buildSymbolFile():
    debug(VAR['DBG_STEPS'], '-------------------------------------------------------------------------------')
    debug(VAR['DBG_STEPS'], 'Building symbol file...')
    
    exe = os.path.join("Make", "symbol.py")

    execute (VAR['DBG_CALL3'], f'python "{exe}" {VAR["PROJECT_TYPE"]} "{VAR["MSX_OBJ_PATH"]}\" "{VAR["MSX_FILE_NAME"]}" {VAR["SYMBOL_DETAIL"]}')

    debug(VAR['DBG_STEPS'], 'Done building symbol file.')
    return

def finish():
    debug(VAR['DBG_STEPS'], '-------------------------------------------------------------------------------')
    debug(VAR['DBG_STEPS'], 'All set for {} project ({}). Happy MSX\'ing!'.format(VAR['PROJECT_TYPE'], VAR['PROFILE']))
    return


# -----------------------------------------------------------------------------------
# ORCHESTRATION
# -----------------------------------------------------------------------------------
separator = None

tc_h=''
tc_s=''
as_h=''                             # application settings (h)
as_s=''                             # application settings (s)
mi_h = ''                           # mdointerface (h)
mi_s = ''                           # mdointerface (s)
mim_s = ''                          # mdoimplementation (s)

OBJLIST = []
INCDIRS = []
QUOTED_INCDIRS = []
VAR = {}


if len(sys.argv) < 2:
    print ('Missing argument.')
    exit(0)

VAR['PROFILE'] = sys.argv[1]
makeAll = False
makeClean = False
if len(sys.argv) > 2:
    VAR['ARG2'] = sys.argv[2].lower()
    if len(sys.argv) > 3:
        VAR['ARG3'] = sys.argv[3].lower()
        makeClean = (VAR['ARG2']=='clean') or (VAR['ARG3']=='clean')
        makeAll = (VAR['ARG2']=='all') or (VAR['ARG3']=='all')
    else:
        makeClean = VAR['ARG2']=='clean'
        makeAll = VAR['ARG2']=='all'

VAR['CURRENT_DIR'] = os.getcwd()
VAR['MSX_BUILD_TIME'] = datetime.now().strftime('%H:%M:%S')
VAR['MSX_BUILD_DATE'] = date.today().strftime('%Y-%m-%d')
if platform.system()=='Windows':
    VAR['SHELL_SCRIPT_EXTENSION'] = 'BAT'
    VAR['SHELL_PREFIX'] = 'CMD /C'
    VAR['POSIX'] = False
    separator = posixpath.sep
else:
    VAR['SHELL_SCRIPT_EXTENSION'] = 'sh'
    VAR['SHELL_PREFIX'] = ''
    separator = ntpath.sep
    VAR['POSIX'] = True

VAR['SDCC_CALL'] = 1
VAR['CODE_AFTER_MDO'] = 0
VAR['BIN_SIZE'] = None
VAR['FILE_START'] = '0x0100'
VAR['DEC_HEADER_SIZE'] = 0
VAR['CODE_LOC'] = None
VAR['DATA_LOC'] = 0
VAR['PARAM_HANDLING_ROUTINE'] = 0
VAR['MDO_SUPPORT'] = 0

VAR['MSX_FILE_NAME'] = 'MSXAPP'
VAR['PROJECT_TYPE'] = None
VAR['MSX_OBJ_PATH'] = r'{}\objs'.format(VAR['PROFILE'])
VAR['MSX_BIN_PATH'] = r'{}\bin'.format(VAR['PROFILE'])
VAR['MSX_DEV_PATH'] = r'..\..\..'
VAR['MSX_LIB_PATH'] = r'{}\libs'.format(VAR['MSX_DEV_PATH'])
VAR['MSX_CFG_PATH'] = r'Config'
VAR['MDO_PARENT_OBJ_PATH'] = None
VAR['MDO_PARENT_AFTERHEAP'] = None

VAR['DBG_MUTE'] = 0
VAR['DBG_ERROR'] = 10
VAR['DBG_OPENING'] = 40
VAR['DBG_STEPS'] = 50
VAR['DBG_SETTING'] = 70
VAR['DBG_OUTPUT'] = 100
VAR['DBG_DETAIL'] = 120
VAR['DBG_CALL1'] = 150
VAR['DBG_CALL2'] = 160
VAR['DBG_CALL3'] = 170
VAR['DBG_TOOLSDETAIL'] = 190
VAR['DBG_EXTROVERT'] = 200
VAR['DBG_PARAMS'] = 230
VAR['DBG_VERBOSE'] = 255
VAR['BUILD_DEBUG'] = VAR['DBG_CALL1']

err = 0

try:
    setDebugLevel()
    opening()
    
    configureTarget()
    createDirStruct()
    clean()
    
    if makeAll or not makeClean and not makeAll:
        saveTargetHeaders()

        configureBuildEvents()
        execAction('build start')

        configureApplication()
        if VAR['MDO_SUPPORT']==1:
            configureMDO()
            saveMDOHeaders()
        saveApplicationHeaders()

        collectIncludeDirs()
        collectCompiledLibs()

        execAction ('before compile')
        if makeAll:
            compileLibs()
        compileProject()
        execAction ('after compile')

        determineCodeLoc()
        linkProject()
        buildBinary()
        execAction ('after binary')
        buildSymbolFile()
    
    execAction ('build end')
    finish()
 
except Exception as e:
    err = -1
    debug (VAR['DBG_ERROR'], '****************************************')
    debug (VAR['DBG_ERROR'], 'AN ERROR OCCURRED!!!')
    debug (VAR['DBG_ERROR'], '')
    debug (VAR['DBG_ERROR'], e)
    debug (VAR['DBG_ERROR'], '****************************************')
    traceback.print_exc()
    debug (VAR['DBG_ERROR'], '')
    debug (VAR['DBG_ERROR'], '****************************************')
    debug (VAR['DBG_ERROR'], 'Build abnormally ended.')
    debug (VAR['DBG_ERROR'], 'Project: {}.{}'.format(VAR['MSX_FILE_NAME'], VAR['MSX_FILE_EXTENSION']))
    debug (VAR['DBG_ERROR'], 'Project type: {}'.format(VAR['PROJECT_TYPE']))
    debug (VAR['DBG_ERROR'], 'Profile: {}'.format(VAR['PROFILE'])) 
    debug (VAR['DBG_ERROR'], 'MSX very sad!')
    debug (VAR['DBG_ERROR'], '****************************************')
    debug (VAR['DBG_ERROR'], '')

exit(err)
