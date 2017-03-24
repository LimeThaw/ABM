import matplotlib.pyplot as plt
import re

infile = open("out.txt", "r")
values = infile.read()
infile.close()

vals1 = []
vals2 = []
target = 0
values = values[1:-1].split(", ")
for tup in values:
	if target == 0:
		vals1.append(int(tup))
		target = 1
	elif target == 1:
		vals2.append(int(tup))
		target = 0

plt.plot(
	range(0, 3650),
	vals1,
	'r-')
plt.plot(
range(0, 3650),
vals2,
'b-')
plt.xlabel("Day")
plt.ylabel("Crimes")
plt.axis([0, 3650, 0, 100])
plt.show()