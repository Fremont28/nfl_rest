# nfl_rest
Does rest influence defensive performance in the NFL? 

Fatigue likely plays a significant role in defensive performance across the NFL. Maintaining a fresh defense helps players give a higher level of effort on quarterback rushes along with rush and pass prevention. 

It makes sense that defenses are more susceptible to fatigue. The offense controls the play selection and pace of the game meaning that the defense is forced to use energy while waiting for the snap and anticipating the play call. 

One key advantage for the offense it that they know the snap count. The quarterback runs through dummy calls and signals as the defense burns energy. The offense also knows the play call, which allows specific offensive players to “take it easy” for the play. For example, if a running a play is called, the wide receiver is able to run his route at less than max effort but the cornerback is forced to defend him at full effort. Further, the offense has the option to rest a tired running back after consecutive rushes and throw the ball. 

Based on these built in fatigue factors on defense, we hypothesize that the amount of rest that a defense gets between drives significantly impacts performance. To test our hypothesis, we built a multinomial logistic regression model with play-by-play data from the 2009 through 2016 NFL seasons (including the postseason) using the drive outcome as the response and teams’ offensive rating, defensive rating, defensive rest, the time when the drive started (to control for cumulative fatigue effects), and offensive home field advantage as the predictors. 

