#! /usr/bin/env python
"""
Repairs actionscript package names, since Flex Builder is too crummy to do this simple task.
"""
import os.path, string, sys, glob, re

pattern = re.compile('^\\s*package .*')


if len(sys.argv) == 1:
    print "Usage: fixAS3PackageNames.py [src folder]"
    print "Repairs actionscript source package names"
    sys.exit(0)


path = sys.argv[1]

path = os.path.join(path, "")

def packageFromFileName (fileName):
    tokens = fileName.strip().split("/")[0:-1]
    return string.join(tokens, ".")
    
fileSet = set() 

for root, dirs, files in os.walk(path):
    for fileName in files:
        if fileName.endswith(".as"):
            fileSet.add( os.path.join( root[len(path):], fileName ))
     
for fileName in fileSet:
    correctedFileName = os.path.join(path, fileName)
    f = open(correctedFileName, 'r')
    lines = f.readlines()
    f.close()
    
    write = False
    for i in range(len(lines)):
        line = lines[i]
        if pattern.match(line):
            packageString = line.split("package")[-1].strip()
            packageString = packageString.strip("{")
            filePackage = packageFromFileName(fileName)
            
            if packageString != filePackage:
                write = True
                lines[i] = "package " + filePackage
                
                if line.find("{") >= 0:
                    lines[i] = lines[i] + " {"
                if line[-1] == "\n":
                    lines[i] = lines[i] + "\n"
                print fileName +": " + packageString + " -> " + filePackage
            break
    if write:
        f = open(correctedFileName, 'w')
        for line in lines:
            f.write(line)
        f.close()
                

