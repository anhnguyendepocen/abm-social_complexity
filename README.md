## WHAT IS IT?

This model is a replication of the model described in [1], a social simulation that tests the _Circumscription Theory_ using agent-based modelling. According to this theory, the emergence of states (autonomous political units of higher social complexity) is a predictable response to environmental circumscription, which is supposed to entail warfare of social groups over available land resources [2].

For the purpose of this model, social complexity is defined as political hierarchy, implicitly emerging when social groups subjugate each other through warfare. The highest level of social complexity is achieved when one of the initial social groups subjugates all the others in the simulation.

Using this model, environmental circumscription can be simulated by decreasing the amount of land resources (habitable land), while leaving the number of competing social groups constant.

The model was used to test the following hypothesis: an increase of habitable land in the modelled artificial landscape also increases the time (measured in time-steps) required for one social group to subjugate all other groups in the simulation, and for social complexity to emerge.

A short summary of the research project, that this model is the result of, can be found in [3].

## HOW IT WORKS

The model has the following key parameters:

 1. Habitable land patches in the artificial landscape in percent
 2. Number of different social groups present in the simulation
 3. Carrying capacity of land patches
 4. Population growth of social groups

Social groups are differentiated by their _ethnicity_, a unique variable assigned to each of the initial groups. When the population variable of a social group reaches the carrying capacity of the land patch it is located on (by the means of a logistic population growth model), it splits up into two smaller groups of the same ethnicity. One of them moves to a new land patch. If that patch is already inhabited by another group of the same ethnicity, both groups merge. If it is inhabited by a different group, warfare occurs.

Warfare is a comparison of population sizes. The social group with the larger population subjugates the other group by changing its ethnicity to its own. Then both groups merge after suffering population losses. Social groups of one ethnicity having subjugated all the other groups in the simulation represents the emergence of social complexity, for example the formation of political hierarchies, such as chiefdoms.

Environmental stress represents natural disasters (such as droughts) that may affect social groups. It occurs randomly at a fixed chance at any given time-step (corresponding to ticks) and eliminates a set percentage of groups from the simulation.


## HOW TO USE IT

**_setup_** creates a number of habitable (green) and inhabitable (blue) patches according to the _habitability_ percentage, and randomly locates a number of turtles (representing social groups with a fixed population range) corresponding to _initial-groups_ on habitable patches.

**_go_** starts the simulation (going through the processes described in HOW IT WORKS at each tick) and keeps it going until the number of **total-ethnicities** is 1.

_habitability_ sets the percentage of habitable land patches in the artificial landscape (the lower the percentage, the more circumscribed the environment, other things being equal).

_initial-groups_ sets the number of initial social groups in the simulation (each being assigned their own ethnicity, represented by the colour of the turtle).

_carrying-capacity_ sets the population growth limit at which social groups split up.

_reproduction_ sets the rate of population growth.

_loss-severity_ sets the percentage of social groups that are affected by environmental stress (with randomly chosen groups being eliminated from the simulation).

**total-ethnicities** tracks the number of different social groups (contrasted by their ethnicity) that remain in the simulation at a given tick (corresponds to _initial-groups_ and **total-groups** after setup).

**total-groups** tracks the total number of social groups that remain in the simulation at a given tick (independently from their ethnicity).

## THINGS TO TRY

The suggested and intended use of this model is to test, whether an increase of _habitability_ also increases the number of time-steps (measured in ticks) the simulation goes through before the number of **total-ethnicities** is 1.

## RELATED MODELS

The original model described in [1] was not made public.

## CREDITS AND REFERENCES

[1] S. Scott, “Environmental Circumscription and the Emergence of Social Complexity,” in _Computational Social Science Society of America (CSSSA) Annual Conference 2011_, Washington, DC: Computational Social Science Society of America, 2011.

[2] R. L. Carneiro, “A Theory of the Origin of the State,” _Science, New Series_, vol. 169, pp. 733-738, 1970.

[3] R. Andre, "Simulating the Emergence of Social Complexity Using Agent-Based Modelling," in _Proceedings of the MEi:CogSci Conference 2018_, Bratislava: Comenius University, p. 64, 2018
