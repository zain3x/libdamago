#! /usr/bin/env python
"""
Repairs actionscript package names, since Flex Builder is too crummy to do this simple task.
"""
import os.path, string, sys, glob, re, shutil

if len(sys.argv) < 3:
    print "Usage: scriptname <fromDir> <toDir>"
    print "Copies actionscript files"

sourceDir = sys.argv[1].strip(os.path.sep)
targetDir = sys.argv[2].strip(os.path.sep)

fileSet = set() 

for root, dirs, files in os.walk(sourceDir):
    for fileName in files:
        if fileName.endswith(".as"):
            root = root.strip(os.path.sep)
            print os.path.join( root[len(sourceDir) + len(os.path.sep):], fileName )
            fileSet.add( os.path.join( root[len(sourceDir) + len(os.path.sep):], fileName ))
            
for fileName in fileSet:
    dirToCreate = os.path.join(targetDir, os.path.dirname(fileName))
    if not os.path.exists(dirToCreate):
        os.makedirs(dirToCreate)
    fileName = os.path.join(sourceDir, fileName)
    shutil.copy(fileName, dirToCreate)
        
