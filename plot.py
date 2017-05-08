import matplotlib.pyplot as plt
import re

infile = open("out.txt", "r")
values = infile.read()
infile.close()

crimes1 = []
crimes2 = []
population = []
happiness = []
crimeRate = []
values = map(lambda x: x.split(", "), values[2:-2].split("), ("))
for val in values:
	crimes1.append(int(val[0]))
	crimes2.append(int(val[1]))
	population.append(int(val[2]))
	happiness.append(int(val[3]))
	crimeRate.append(int(val[4]))

length = len(crimes1)

plt.plot(
	range(0, length),
	crimes1,
	'r-',
	label="Category 1 crimes")
plt.plot(
	range(0, length),
	crimes2,
	'b-',
	label="Category 2 crimes")
plt.plot(
	range(0, length),
	population,
	'g-',
	label="Total population")
plt.plot(
	range(0, length),
	happiness,
	'y-',
	label="Average happiness level")
plt.plot(
	range(0, length),
	crimeRate,
	'm:', linewidth=1,
	label="Crime rate (per 100 people)")
plt.xlabel("Day")
plt.legend()
plt.axis([0, length, 0, 120])
plt.show()
