import matplotlib.pyplot as plt
import re

infile = open("out.txt", "r")
values = infile.read()
values = values[1:-1].split(", ")
for val in values:
	print val
infile.close()
values = [int(stringval) for stringval in values]

plt.plot(
	range(0, 3650),
	values,
	'r-')
plt.xlabel("Day")
plt.ylabel("Crimes")
plt.axis([0, 3650, 0, 100])
plt.show()