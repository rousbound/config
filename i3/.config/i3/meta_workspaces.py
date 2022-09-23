#!/usr/bin/python3
import os
import argparse
import subprocess
import json
import re
from subprocess import call
import builtins
import sys

#Handle flags
parser = argparse.ArgumentParser()
parser.add_argument("-m", "--meta",         help="Meta flag")
parser.add_argument("-w", "--workspace",    help="Workspace flag")
parser.add_argument("-mw","--move_window",  help="Move flag")
parser.add_argument("-r", "--rename",       help="Rename Meta Workspace")
parser.add_argument("-d", "--delete",       help="Delete current Meta Workspace")
parser.add_argument("-sm", "--switch_meta", action='store_true', help="Switch to next Meta Workspace")
#TODO add -d / --delete arg in order to nuke current workspace (if empty!)
args = parser.parse_args()

# Now populate current meta-workspace info for given $HOST$SDISPLAY
hostname    = os.environ['USER']
display     = os.environ['DISPLAY']

#Name of stored meta variable
metaVarName = "meta_workspace"

#Correct path to stored variable
dirname = os.path.dirname(__file__)
variable_name = 'variables_' + hostname + display
filename = os.path.join(dirname, variable_name)

workspace_name = 'cur_ws_' + hostname + display
cur_ws   = os.path.join(dirname, workspace_name)

ws_list = 'ws_list_' + hostname + display
wslist  = os.path.join(dirname, ws_list)

ws_str = 'ws_str_' + hostname + display
wsstr  = os.path.join(dirname, ws_str)


#MON1 = "DP-1"
#MON2 = "eDP-1"

# def print(s):
    # print(s)
    # os.system("echo "+s+" >> /home/geraldo/.config/i3/debug")

def print(*args, **kwargs):
    with open('/home/geraldo/.config/i3/log.txt', 'a+') as f:
        return builtins.print(*args, file=f, **kwargs)

print("Entered script....!")

MON1 = "HDMI-3"
MON2 = "DP-3"
# MON3 = "DVI-I-1-1"
def check_ws_empty(wsnum):
    cmd = subprocess.Popen("i3-msg -t get_workspaces", stdout=subprocess.PIPE, shell=True)

    output, err = cmd.communicate()
    returncode  = cmd.wait()

    zzz = json.loads(output)

    #No sorting required - leaving in for time being
    zzz.sort(key=lambda ws: ws["name"])
    zzz.sort(key=lambda ws: ws["output"])
    #print(*zzz, sep=" \n")

    #Find workspace names matching a regex
    for i in zzz:
        ws = i["name"]
        #print(f"{ws}")
        #Put pattern match into 2x groups
        n = re.match(r"(?P<ws_num>\d)(?P<ws_win>\d)", ws)
        #print(f"{n}")
        if n:
            #print(f"match={n.group('ws_num')} - {n.group('ws_win')} -- {wsnum}")
            if int(n.group('ws_num')) == wsnum:
                #We have found a workspace, this is a problem - cannot report as empty
                return 1

    #If we get to here we haven't found a workspace in the selected meta
    return 0

def readMeta():
    with open(filename) as fin:
        for line in fin:
            if line.startswith(metaVarName):
                return line.split(":")[-1].strip()

def readWsList(meta,overwrite,delete):
    outline = []
    found = 0
    with open(wslist) as fin:
        for line in fin:
            line = line.rstrip()
            if line.startswith(meta):
                found = 1
                #If we're renaming a workspace
                if overwrite:
                    cmd = subprocess.Popen('zenity --entry', stdout=subprocess.PIPE, shell=True)
                    output, err = cmd.communicate()
                    returncode = cmd.wait()
                    if returncode == 0:
                        name = "%s" % output.decode("utf-8").strip()
                        cur_ws_string = meta + ":" + name
                        outline.append(cur_ws_string + "")
                    else:
                        cur_ws_string = line
                        outline.append(cur_ws_string + "")
                elif delete:
                    #TODO Get current meta
                    print(f'running delete on ws={meta}')

                    if check_ws_empty(int(meta)) == 0:
                        #We have an empty ws - don't print wsname
                        #Have to put an executable line in here lest we change the conditional
                        cmd = subprocess.Popen('zenity --notification --window-icon="info" --text="Workspace deleted!"', stdout=subprocess.PIPE, shell=True)
                        output, err = cmd.communicate()
                        returncode = cmd.wait()
                    else:
                        #Alert the user that the ws is not empty
                        cmd = subprocess.Popen('zenity --notification --window-icon="error" --text="Workspace not empty - cannot delete!"', stdout=subprocess.PIPE, shell=True)
                        output, err = cmd.communicate()
                        returncode = cmd.wait()
                        outline.append(line)
                        print(f'|->cant delete on ws={meta}')
                else:
                    if line.split(":")[-1].strip() == "":
                        cmd = os.popen('zenity --entry').read()
                        cmd = cmd.split("output = ")[-1].strip()
                        cur_ws_string = meta + ":" + cmd
                        outline.append(cur_ws_string + "")
                    else:
                        outline.append(line)
                        cur_ws_string = line
            else:
                #check if format of line is correct
                if re.match('\d+:', line):
                    cur_ws_string = line
                    outline.append(line)

    if found == 0: #if we have scanned all lines and not found a match
        cmd = os.popen('zenity --entry').read()
        cur_ws_string = meta + ":" + cmd
        outline.append(cur_ws_string)
    fin.close
    with open(wslist, 'w') as out:
        for line in outline:
            out.write(line + "\n")
    if os.path.isfile(cur_ws):
        os.remove(cur_ws)
    with open(cur_ws, 'a') as out:
        out.write(cur_ws_string)

    statusline = ""
    myoutline = sorted(outline, key = lambda a: a.split(":")[0])
    for line in myoutline:
        a = line.split(":")
        disp =  " " if (a[0] == meta) else "  "
        statusline += "["+disp+a[0]+":"+a[1]+"]"

    with open(wsstr, 'w') as out:
        out.write(statusline)

def writeMeta(value):
    if os.path.isfile(filename):
        os.remove(filename)
    with open(filename, 'a') as out:
        out.write(metaVarName + ":" + value + '\n')

# def readMeta():
    # # if os.path.isfile(filename):
        # # os.remove(filename)
    # with open(filename, 'r') as out:
        # return out.read()

#Create file if it does not exist
if not os.path.isfile(filename):
    writeMeta("1")

#Create file if it does not exist
if not os.path.isfile(cur_ws):
    writeMeta("1")

if not os.path.isfile(wslist):
    with open(wslist, 'a') as out:
        out.write("\n")
        out.close()

if not os.path.isfile(wsstr):
    with open(wsstr, 'a') as out:
        out.write("\n")
        out.close()

def fWorkspace(meta, workspace):
    metaDict = {"1": "Main", "2": "Job"}
    if workspace == "1":
        workspaceLabel = "Home 1st"
    elif workspace == "11":
        workspaceLabel = "Home 2st"
    # elif workspace == "21":
        # workspaceLabel = "Home 3st"
    else:
        workspaceLabel = metaDict[meta]+": "+workspace

    base = f"{meta}{workspace}:{workspaceLabel}"
    return base

def i3msg(cmds):
    exe_cmd = "i3-msg \""
    for cmd in cmds:
        exe_cmd += cmd + "; "
    exe_cmd += "\""
    print(exe_cmd)
    os.system(exe_cmd)


def switch_expanded_workspace(meta, workspace):

    workspace_main = fWorkspace(meta, workspace)
    workspace_secondary = fWorkspace(meta, str(1)+workspace)
    cmd_switch = "workspace {}".format(workspace_main)
    cmd_switch2 = "workspace {}".format(workspace_secondary)
    print(cmd_switch)
    # cmd_focus_other_monitor = "focus output {}, workspace {}".format(MON2, workspace_secondary)
    # cmd_focus_main_monitor = "focus output {}, workspace {}".format(MON1, workspace_main)

    i3msg([cmd_switch, cmd_switch2, cmd_switch])
    # i3msg([cmd_focus_other_monitor])
    # i3msg([cmd_focus_main_monitor])
    # i3msg([cmd_switch])

if args.switch_meta == True:
    print("Method: Switch Meta")
    meta = readMeta()
    print("Original meta:", meta)
    print("Original meta type:", type(meta))
    if meta == "2":
        meta = "1"
    elif meta == "1":
        meta = "2"
    print("New meta:", meta)
    readWsList(meta,0,0)
    writeMeta(meta)
    switch_expanded_workspace(meta, "2")
    sys.exit()

#Change meta workspace
if args.meta is not None:
    print("Method: meta")
    meta = args.meta
    #Now check to see if the meta ws has a name - if not, add one
    print("Meta type:", type(meta))
    readWsList(meta,0,0)
    #Now write this out to cur_ws, then write meta
    writeMeta(meta)
    switch_expanded_workspace(meta, "1")

#Change workspace within meta workspace
if args.workspace is not None:
    print("Method: workspace")
    meta = readMeta()
    workspace = args.workspace
    if workspace == "1":
        switch_expanded_workspace("1", "1")
    else:
        switch_expanded_workspace(meta, workspace)

#Move window in between workspaces within meta workspace
if args.move_window is not None:
    print("Method: move_window")
    meta = readMeta()
    print("move window between workspaces in current meta: " + meta)
    workspace = args.move_window
    cmd = "i3-msg 'move container to workspace {}'".format(fWorkspace(meta, workspace))
    print(cmd)
    os.system(cmd)

#Change meta workspace
if args.rename is not None:
    print("Method: rename")
    #get meta value from cur_ws
    meta = readMeta()
    #update ws_list dictionary
    #write out cur_ws
    readWsList(meta,1,0)

#Delete current workspace provided it is empty
if args.delete is not None:
    print("Method: delete")
    #get meta value from cur_ws
    meta = readMeta()
    #update ws_list dictionary
    #write out cur_ws
    readWsList(meta,0,1)
    #TODO must set meta workspace to an existing workspace for safety reasons!

