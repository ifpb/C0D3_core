import os
import sys

def find(name, path):
	for root, dirs, files in os.walk(path):
		for f in files:
			if name == f.split('.')[0]:
				if f.split('.')[-1] in ('c','java','py','cpp'):
					return f.split('.')[-1]
	return None

if __name__ == '__main__':

	name = sys.argv[1]
	path = sys.argv[2]

	f = find(name, path)
	if f:
		with open("res.txt",'w') as res:
			res.write(f)
		sys.exit(0)
	else:
		sys.exit(1)
