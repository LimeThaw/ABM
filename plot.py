import matplotlib.pyplot as plt
import re

infile = open("out.txt", "r")
values = infile.read()
infile.close()

popCount = []
happiness = []
murders = []
others = []
gunMurders = []
gunOthers = []
avgConnectedness = []
values = map(lambda x: x.split(", "), values[2:-2].split("), ("))
for val in values:
	popCount.append(val[0])
	happiness.append(val[1])
	murders.append(val[2])
	others.append(val[3])
	gunMurders.append(val[4])
	gunOthers.append(val[5])
	avgConnectedness.append(val[6])

length = len(popCount)

# See https://matplotlib.org/api/pyplot_api.html?highlight=plot#matplotlib.pyplot.plot for
# plot styles
plt.plot(
	range(0, length),
	popCount,
	'g-',
	label="Population count")
plt.plot(
	range(0, length),
	happiness,
	'y-',
	label="Average happiness level")
plt.plot(
	range(0, length),
	avgConnectedness,
	'y:',
	label="Average Connectedness value")
plt.plot(
	range(0, length),
	murders,
	'r-',
	label="Murders per 100")
plt.plot(
	range(0, length),
	gunMurders,
	'r:',
	label="Murders involving firearms per 100")
plt.plot(
	range(0, length),
	others,
	'b-',
	label="Other crimes per 100")
plt.plot(
	range(0, length),
	gunOthers,
	'b:',
	label="Other crimes involving firearms per 100")
plt.xlabel("Day")
plt.legend()
plt.axis([0, length, 0, 120])
plt.show()
