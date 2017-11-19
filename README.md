# nfl_rest
Does fatigue influence defensive performance in the NFL? 

Fatigue likely plays a significant role in defensive performance across the NFL. Maintaining a fresh defense helps players give a higher level of effort on quarterback rushes along with rush and pass prevention. 

It makes sense that defenses are more susceptible to fatigue. The offense controls the play selection and pace of the game meaning that the defense is forced to use energy while waiting for the snap and anticipating the play call. 

One key advantage for the offense is that they know the snap count. The quarterback runs through dummy calls and signals as the defense burns energy. The offense also knows the play call that allows some offensive players to “take it easy” for the play depending on their role. For example, on a running play, the wide receiver can often run his route at less than maximum effort but the cornerback is forced him at full effort. Further, the offense has the option to rest a tired running back or receiver after consecutive plays. It is harder for the defense to make player substitutions in the middle of the drive.  

Based on these built in fatigue factors on defense, we hypothesize that the amount of rest that a defense gets between drives significantly impacts performance. To test our hypothesis, we built a multinomial logistic regression model with play-by-play data from the 2009 through 2016 NFL seasons (including the postseason) using the drive outcome as the response and teams’ offensive rating, defensive rating, defensive rest, the time when the drive started (to control for cumulative fatigue effects), and offensive home field advantage as the predictors. 

As a response, a categorical score variable was assigned depending on whether the offense punted the ball (0 points), kicked a field goal (3 points), scored a touchdown (6 points), lost an interception or fumble (-6 points), suffered a safety (-2 points). Any other outcome was also assigned an outcome of zero points.  


Read the entire article here: https://beyondtheaverage.wordpress.com/2017/11/19/how-fatigue-impacts-nfl-defenses/
