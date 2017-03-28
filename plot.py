import matplotlib.pyplot as plt
import re

infile = open("out.txt", "r")
values = infile.read()
infile.close()

crimes1 = []
crimes2 = []
population = []
happiness = []
target = 0
values = values[1:-1].split(", ")
for val in values:
	if target == 0:
		crimes1.append(int(val))
		target = 1
	elif target == 1:
		crimes2.append(int(val))
		target = 2
	elif target == 2:
		population.append(int(val))
		target = 3
	elif target == 3:
		happiness.append(int(val))
		target = 0

plt.plot(
	range(0, 3650),
	crimes1,
	'r-')
plt.plot(
	range(0, 3650),
	crimes2,
	'b-')
plt.plot(
	range(0, 3650),
	population,
	'g-')
plt.plot(
	range(0, 3650),
	happiness,
	'y-')
plt.xlabel("Day")
plt.ylabel("Crimes")
plt.axis([0, 3650, 0, 100])
plt.show()