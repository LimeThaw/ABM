import matplotlib.pyplot as plt # The plotting library
import re # Used for splitting the raw simulation output
import json # Used for loading the empirical comparison data

# The grouping interval over which data is averaged for smoother output
AVG_INTERVAL = 120

# Read the simulation output data
infile = open("out.txt", "r")
values = infile.read()
infile.close()

# Read empirical data for comparison
cmpData = json.loads(open("data.json").read())

# Initialize data arrays to plot
popCount = []
happiness = []
crimes = []
gunCrimes = []
avgConnectedness = []
gunPossession = []

# Populate arrays with output data
values = map(lambda x: x.split(", "), values[2:-2].split("), ("))
for val in values:
	popCount.append(val[0])
	happiness.append(val[1])
	crimes.append(val[2])
	gunCrimes.append(val[3])
	avgConnectedness.append(val[4])
	gunPossession.append(val[5])

# The length or the data arrays
length = len(popCount)

# Calculate cha population chage rates from raw output data
populationChange = [0] + map(lambda p, pp: (float(p)-float(pp))/float(pp)*100000, popCount[1:], popCount[:-1])

# Compute average over grouping interval for nicer output
tmpCrimes = crimes
tmpGunCrimes = gunCrimes
tmpPop = populationChange
crimes = []
gunCrimes = []
populationChange = []
for i in range(0, len(tmpCrimes)/AVG_INTERVAL):
	avg1 = 0.0
	avg2 = 0.0
	avg3 = 0.0
	for j in range(0, AVG_INTERVAL):
		avg1 += float(tmpCrimes[i*AVG_INTERVAL+j])
		avg2 += float(tmpGunCrimes[i*AVG_INTERVAL+j])
		avg3 += float(tmpPop[i*AVG_INTERVAL+j])
	crimes.append(avg1/AVG_INTERVAL*10000)
	gunCrimes.append(avg2/AVG_INTERVAL*10000)
	populationChange.append(avg3/AVG_INTERVAL)

# Compute crime rates for comparison from simulation output data
violentCrimes = map(lambda c: float(c)/10, crimes)
firearmCrimes = map(lambda c: float(c)/10, gunCrimes)

# Create first subplot of direct simulation output
plt.subplot(211)
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
	map(lambda n: n*AVG_INTERVAL, range(0, length/AVG_INTERVAL)),
	crimes,
	'b-',
	label="Crime rate per million")
plt.plot(
	map(lambda n: n*AVG_INTERVAL, range(0, length/AVG_INTERVAL)),
	gunCrimes,
	'b:',
	label="Crime rate involving firearms per 100")
plt.xlabel("Day")
plt.legend()
plt.axis([0, length, 0, 120])

# Create second subplot for normalized rates and comparison to empirical data
plt.subplot(212)
plt.plot(
	[0, length-1],
	[cmpData["populationChange"]*100000]*2,
	'g-',
	label="Population change rate in the US"
)
plt.plot(
	map(lambda n: n*AVG_INTERVAL, range(0, length/AVG_INTERVAL)),
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
	map(lambda n: n*AVG_INTERVAL, range(0, length/AVG_INTERVAL)),
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
	map(lambda n: n*AVG_INTERVAL, range(0, length/AVG_INTERVAL)),
	firearmCrimes,
	'c:',
	label="Firearm crime rate in our model"
)
plt.xlabel("Day")
plt.legend()
plt.axis([0, length, -1, 5])

# Render the plots
plt.show()

# See https://matplotlib.org/api/pyplot_api.html?highlight=plot#matplotlib.pyplot.plot for
# plot styles