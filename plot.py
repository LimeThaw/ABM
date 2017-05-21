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
gunPossession = []
values = map(lambda x: x.split(", "), values[2:-2].split("), ("))
for val in values:
	popCount.append(val[0])
	happiness.append(val[1])
	crimes.append(val[2])
	gunCrimes.append(val[3])
	avgConnectedness.append(val[4])
	gunPossession.append(val[5])

# Let's average!
tmpCrimes = crimes
tmpGunCrimes = gunCrimes
crimes = []
gunCrimes = []
for i in range(0, len(tmpCrimes)/30):
	avg1 = 0.0
	avg2 = 0.0
	for j in range(0, 30):
		avg1 += float(tmpCrimes[i*30+j])
		avg2 += float(tmpGunCrimes[i*30+j])
	crimes.append(avg1/30.0*10000)
	gunCrimes.append(avg2/30.0*10000)

length = len(popCount)

cmpData = json.loads(open("data.json").read())

plt.subplot(211)

# See https://matplotlib.org/api/pyplot_api.html?highlight=plot#matplotlib.pyplot.plot for
# plot styles
plt.plot(
	range(0, length),
	map(lambda n: float(n)/1000.0, popCount),
	'g-',
	label="Population count in thousands")
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
	map(lambda n: n*30, range(0, length/30)),
	crimes,
	'b-',
	label="Crime rate per million")
plt.plot(
	map(lambda n: n*30, range(0, length/30)),
	gunCrimes,
	'b:',
	label="Crime rate involving firearms per 100")
'''plt.plot(
	range(0, length),
	gunPossession,
	'c-',
	label="Gun possession rate per 100")'''
plt.xlabel("Day")
plt.legend()
plt.axis([0, length, 0, 120])

populationChange = [0] + map(lambda p, pp: (float(p)-float(pp))/float(pp)*100000, popCount[1:], popCount[:-1])
violentCrimes = map(lambda c: float(c)/10, crimes)
firearmCrimes = map(lambda c: float(c)/10, gunCrimes)

# Let's average!
tmpPop = populationChange
populationChange = []
for i in range(0, len(tmpCrimes)/30):
	avg = 0.0
	for j in range(0, 30):
		avg += float(tmpPop[i*30+j])
	populationChange.append(avg/30.0)

plt.subplot(212)

plt.plot(
	[0, length-1],
	[cmpData["populationChange"]*100000]*2,
	'g-',
	label="Population change rate in the US"
)
plt.plot(
	map(lambda n: n*30, range(0, length/30)),
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
	map(lambda n: n*30, range(0, length/30)),
	violentCrimes,
	'b:',
	label="Violent crime rate in our model"
)
plt.plot(
	[0, length-1],
	[cmpData["firearmCrimes"]]*2,
	'c-',
	label="Firearm crime rate in the US"
)
plt.plot(
	map(lambda n: n*30, range(0, length/30)),
	firearmCrimes,
	'c:',
	label="Firearm crime rate in our model"
)
plt.xlabel("Day")
plt.legend()
plt.axis([0, length, -1, 5])

plt.show()
