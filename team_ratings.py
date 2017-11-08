from matplotlib import pyplot as plt
from scipy.stats import norm
import sys
import os
import seaborn as sns
import pandas as pd
import numpy as np
from scipy import optimize
from numpy import linalg as LA
import nflgame

'''
lreg = 20

f_nfl = open("nfl_games.csv","w")

print >> f_nfl,"home,away,hpts,apts"

for w in range(1,int(sys.argv[1])):
	games = nflgame.games(int(sys.argv[2]),week=w,kind='REG')
	for i in range(len(games)):
		print >> f_nfl, games[i].home,",",games[i].away,",",games[i].score_home,",",games[i].score_away

f_nfl.close()

os.system("cat nfl_games.csv | perl5.18 -pe \'s/JAX/JAC/g\' > nfl_games2.csv")
os.system("cat nfl_games2.csv | perl5.18 -pe \'s/ , /,/g\' > nfl_games.csv")
'''
df = pd.read_csv("nfl_games17.csv", usecols=[0,1,2,3])
#df = pd.read_csv("nfl_games.csv", usecols=[0,1,2,3])

#teams = list(set(df.home.unique()) & set(df.away.unique()))

teams = ['New Orleans Saints', 'Pittsburgh Steelers', 'New England Patriots', 'Tampa Bay Buccaneers', 'Philadelphia Eagles', 'Atlanta Falcons', 'Cleveland Browns', 'Cincinnati Bengals', 'Los Angeles Chargers', 'Oakland Raiders', 'Buffalo Bills', 'New York Giants', 'Detroit Lions', 'Chicago Bears', 'Carolina Panthers', 'San Francisco 49ers', 'Indianapolis Colts', 'Seattle Seahawks', 'Arizona Cardinals', 'Houston Texans', 'Tennessee Titans', 'Jacksonville Jaguars', 'Los Angeles Rams', 'Washington Redskins', 'Miami Dolphins', 'New York Jets', 'Baltimore Ravens', 'Kansas City Chiefs', 'Denver Broncos', 'Green Bay Packers', 'Minnesota Vikings', 'Dallas Cowboys']


'''
if (int(sys.argv[2]) == 2016):
	teams = ['MIN', 'MIA', 'CAR', 'ATL', 'DET', 'CIN', 'NYJ', 'DEN', 'BAL', 'NYG', 'OAK', 'TEN', 'LA', 'DAL', 'NE', 'SEA', 'CHI', 'BUF', 'CLE', 'TB', 'HOU', 'GB', 'WAS', 'JAC', 'KC', 'PHI', 'PIT', 'NO', 'IND', 'ARI', 'SF', 'SD']

if (int(sys.argv[2]) < 2016):
	teams = ['MIN', 'MIA', 'CAR', 'ATL', 'DET', 'CIN', 'NYJ', 'DEN', 'BAL', 'NYG', 'OAK', 'TEN', 'STL', 'DAL', 'NE', 'SEA', 'CHI', 'BUF', 'CLE', 'TB', 'HOU', 'GB', 'WAS', 'JAC', 'KC', 'PHI', 'PIT', 'NO', 'IND', 'ARI', 'SF', 'SD']
'''
#teams = [item[0] for item in nflgame.teams]
#if (int(sys.argv[2]) >= 2016):
#	teams.append("LA")

df['hidx'] = df.home.apply(lambda x: teams.index(x))
df['aidx'] = df.away.apply(lambda x: teams.index(x))
df['hidxd'] = df.home.apply(lambda x: teams.index(x)+32)
df['aidxd'] = df.away.apply(lambda x: teams.index(x)+32)

n_teams = len(teams)
ghome = (2*n_teams)+1

def rtg_constr1(x):
    return np.mean(x[0:31])

def rtg_constr2(x):
    return np.mean(x[32:63])


def obj(x):
    err1 = ((df['hpts']-(x[ghome-1]+(0.5*x[ghome]+df.hidx.apply(lambda i: x[i])+df.aidxd.apply(lambda i: x[i]))))**2).sum()
    err2 = ((df['apts']-(x[ghome-1]+(-0.5*x[ghome]+df.aidx.apply(lambda i: x[i])+df.hidxd.apply(lambda i: x[i]))))**2).sum()
    return err1+err2

x0 = np.zeros(shape=2*len(teams)+2)

res = optimize.minimize(obj,x0,constraints=[{'type':'eq', 'fun':rtg_constr1},{'type':'eq', 'fun':rtg_constr2}], method="SLSQP",
                        options={'maxiter':10000,'disp':True})


f_16 = open("nfl2016rat.txt","r")

ratingsoff = dict()
ratingsdef = dict()

for line in f_16:
	linef = line.rstrip().rsplit(",")
	ratingsoff[linef[0]] = float(linef[1])
	ratingsdef[linef[0]] = float(linef[2])

#print res.success, res.message
#print("============ Season: "+sys.argv[1]+" Week: "+sys.argv[2]+"============")
print("Home edge points: {:.3f}".format(res.x[ghome]))
print("Mean points/game: {:.3f}".format(res.x[ghome-1]))
print("                Team   OffRating   DefRating   TotRating")
for i, t in enumerate(teams):
    print("{:>20s}    {:.4f}   {:.4f}   {:.4f}".format(t, (0.7*res.x[i])+(0.3*ratingsoff[t]), (0.7*res.x[32+i])+(0.3*ratingsdef[t]),((0.7*res.x[i])+(0.3*ratingsoff[t]))-((0.7*res.x[32+i])+(0.3*ratingsdef[t]))))
