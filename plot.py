import matplotlib.pyplot as plt
import re
import json

infile = open("out.txt", "r")
values = infile.read()
infile.close()

popCount = []
happiness = []
crimes = []
gunCrimes = []
avgConnectedness = []
values = map(lambda x: x.split(", "), values[2:-2].split("), ("))
for val in values:
	popCount.append(val[0])
	happiness.append(val[1])
	crimes.append(val[2])
	gunCrimes.append(val[3])
	avgConnectedness.append(val[4])

length = len(popCount)

cmpData = json.loads(open("data.json").read())

plt.subplot(121)

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
	crimes,
	'b-',
	label="Crime rate per 100")
plt.plot(
	range(0, length),
	gunCrimes,
	'b:',
	label="Crime rate involving firearms per 100")
plt.xlabel("Day")
plt.legend()
plt.axis([0, length, 0, 120])

populationChange = [0] + map(lambda p, pp: (float(p)-float(pp))/float(p)*100000, popCount[1:], popCount[:-1])
violentCrimes = map(lambda c, p: float(c)/float(p)*100000, crimes, popCount)
firearmCrimes = map(lambda c, p: float(c)/float(p)*100000, gunCrimes, popCount)

plt.subplot(122)

plt.plot(
	[0, length-1],
	[cmpData["populationChange"]]*2,
	'g-',
	label="Population change rate in the US"
)
plt.plot(
	range(0, length),
	populationChange,
	'g:',
	label="Population change in our model"
)
plt.plot(
	[0, length-1],
	[cmpData["violentCrimes"]]*2,
	'b-',
	label="Violent crime rate in the US"
)
plt.plot(
	range(0, length),
	violentCrimes,
	'b:',
	label="Violent crime rate in our model"
)
plt.plot(
	[0, length-1],
	[cmpData["firearmCrimes"]]*2,
	'c-',
	label="Firearm crimes in the US"
)
plt.plot(
	range(0, length),
	firearmCrimes,
	'c:',
	label="Firearm crime rate in our model"
)
plt.xlabel("Day")
plt.legend()
plt.axis([0, length, 0, 10])

fail = 0.0
for i in range(0, length):
	fail += (cmpData["violentCrimes"] - violentCrimes[i])**2
	fail += (cmpData["firearmCrimes"] - firearmCrimes[i])**2

for i in range(1, length): # Start from one because on day 0 change is always 0
	fail += (cmpData["populationChange"] - populationChange[i])**2

print("Square sum error: " + str(fail))

plt.show()