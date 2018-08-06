;; IR_II-Andre-SS2018-D3.2.v02-TargetModel.RC.nlogo
;; NetLogo version 6.0.4

;;;;;;;;;;;;;;;;;;
;; introduction ;;
;;;;;;;;;;;;;;;;;;


;; author information

;; raffael andre
;; university of vienna, mei:cogsci
;; into research ii project, summer semester 2018
;; project supervisor: dr. paolo petta (ofai)

;; summary

;; this model is a replication of the model described in [1], a social
;;   simulation that tests the circumscription theory using agent-based
;;   modelling. according to this theory, the emergence of states (autonomous
;;   political units of higher social complexity) is a predictable response to
;;   environmental circumscription, which is supposed to entail warfare of
;;   social groups over available land resources [2].
;; for the purpose of this model, social complexity is defined as political
;;   hierarchy, implicitly emerging when social groups subjugate each other
;;   through warfare. the highest level of social complexity is achieved when
;;   one of the initial social groups subjugates all the others in the
;;   simulation. using this model, environmental circumscription can be
;;   simulated by decreasing the amount of land resources (habitable land),
;;   while leaving the number of competing social groups constant.
;; the model was used to test the following hypothesis: an increase of
;;   habitable land in the modelled artificial landscape also increases the time
;;   required for one social group to subjugate all other groups in the
;;   simulation, and for social complexity to emerge.
;; a short summary of the research project, that this model is the result of,
;;   can be found in [3].
;; [1] s. scott, “environmental circumscription and the emergence of social
;;   complexity,” in computational social science society of america (csssa)
;;   annual conference 2011, washington, dc: computational social science
;;   society of america, 2011.
;; [2] r. l. carneiro, “a theory of the origin of the state,” science, new
;;   series, vol. 169, pp. 733-738, 1970.
;; [3] r. andre, "simulating the emergence of social complexity using
;;   agent-based modelling," in proceedings of the mei:cogsci conference 2018,
;;   bratislava: comenius university, p. 64, 2018


;;;;;;;;;;;;;;;;;;;;;
;; version history ;;
;;;;;;;;;;;;;;;;;;;;;


;; version 1 (2018-06-11)

;; implemented all key principles and mechanisms of the original model
;; model runs until only one ethnicity remains in the simulation
;; no errors were observed during test runs
;; groups grow, split, and migrate visibly faster than in the original model
;; primary issue that was observed is that when a group splits,
;;   both groups migrate to neighbours
;;   what should be is that only one group migrates, the other stays
;; on the 'total-ethnicities' monitor, the number occasionally jumps
;;   down to 1 or 0 for seemingly no reason for a split second

;; first test runs
;; (results collected manually)
;; changed only habitability, 10 runs each
;; init-g 10, car-cap 100, re 4%, loss 1%
;; eos = ticks at the end of the simulation (average)
;; (1) hab  5, eos  1000
;; (2) hab 10, eos  2800
;; (3) hab 15, eos  3600
;; (4) hab 20, eos  5500
;; (5) hab 25, eos  8300
;; (6) hab 30, eos 11200
;; these results do not corroborate those of the original model
;;   instead they indicate that environmental circumscription does
;;   have an effect on the time it takes for social complexity to emerge
;; (also, I did not test this extensively, but in the few samples I took
;; 'loss-severity' only had a significant effect on eos when hab was sub 20%)

;; version 2 (2018-07-06)

;; translated model from NetLogo version 4.1.1 to 6.0.4
;;   the only thing to do was setting the interface up again from scratch
;;   plotting total-population also does not work in this version
;;   however since it does not add anythig valuable I simply omitted it
;;   because total-population is not a critical parameter for the simulation
;; refactored comments, added 'whys' to 'whats'
;; impemented a mechanism to account for population losses in warfare
;; filled out the 'Info' tab


;;;;;;;;;;;;;;;;;;;;;;;;;
;; declaring variables ;;
;;;;;;;;;;;;;;;;;;;;;;;;;


;; declaring global variables

globals [
  initial-ethnicities    ;; number of initial ethnicities present at the
                         ;;   beginning of the simulation
  total-ethnicities      ;; count of all ethnicities*
  total-groups           ;; count of all groups*
                         ;; *present in the simulation at the end of
                         ;;   one time-step
;  total-population       ;; sum of all populations, omitted in version 3
                          ;;   because it is not relevant for the results
]

;; declaring own variables for turtles

turtles-own [
  ethnicity     ;; indicated by colour of squares, a number between 1 and
                ;;   the initial number of ethnicities
  population    ;; indicated by size of squares
  split-up      ;; variable indicating whether a turtle has recently hatched
]

;; declaring own variables for patches (there are none)

;patches-own [
;]


;;;;;;;;;;;;;;;;;;;;;;;
;; setting things up ;;
;;;;;;;;;;;;;;;;;;;;;;;

;; variables

;; how to set up turtles and the artificial landscape

to setup
  clear-all

  ;; setting up patches

  ;; artificial landscape consists of patches only
  ;; patches can be green = habitable, or blue = unhabitable
  ;; first all patches are set to blue
  ;; then the set percentage of habitable patches is set to green

  let max-percentage 100    ;; the maximum amout of patches that can be green
                            ;;   is also the maximum possible, namely 100%

  ask patches [ set pcolor blue ]
  let total-patches (count patches)
  let habitable-patches round(total-patches * (habitability / max-percentage))
  ask n-of habitable-patches patches [
    set pcolor green ]

;; original draft, that gave each individual patch a chance to be green
;  ask patches [
;    let chance-of-habitability random-float 100
;        ;; create a chance for patches to be habitable based on habitability
;    if chance-of-habitability <= habitability [ set pcolor green ]
;        ;; colour patches that are habitable green
;    if chance-of-habitability > habitability [set pcolor blue ]
;        ;; colour patches that are habitable blue
;  ]

  ;; setting up turtles

  ;; turtles are sprouted instead of created
  ;; because this was the first solution that came to mind and worked

  ask n-of initial-groups patches with [ pcolor = green ] [ sprout 1 ]

  ;; turtles set their ethnicity by counting how many of them
  ;;   there are with the help of the global variable 'initial-ethnicities'
  ;; however this solution does not seem very elegant to me
  ;; each turtle sets their population to a random number between 10 and 75
  ;; their shape is set to 'square' and their colour to shades of grey
  ;; contemplated setting the shape to 'person' and the colour to pink
  ;;   but it simply did not look good
  ;; their size positively corresponds to their population
  ;; however at this point there are visibility issues with small populations
  ;; lastly a variable is defined that later keeps track of
  ;;   whether a turtle recently 'split-up'

  let pop-upper-limit 65    ;; set variables for calculating initial sizes of
  let pop-lower-limit 10    ;;   of populations, limits were chosen arbitrarily
  let turtle-size-limiter 100    ;; variable used to make sure the size of
                                 ;;   of turtles stays below 1

  ask turtles [
    set initial-ethnicities (initial-ethnicities + 1)
    set ethnicity initial-ethnicities
    set population (random pop-upper-limit + pop-lower-limit)
;    set population random 100    ;; changed, unrealistic
;    set shape "person"    ;; changed this due to visibility issues
    set shape "square"
;    set color (139.9 - ((ethnicity) * 0.4))  ;; pink suits shape "person"
    set color scale-color gray ethnicity 0 initial-groups
    set size ((population / turtle-size-limiter))
    set split-up 0
  ]

  ;; the number of total ethnicities is set for the interface monitor only
  ;; same goes for the turtle count representing groups in the simulation

  set total-ethnicities initial-ethnicities
  set total-groups (count turtles)
  reset-ticks
end


;;;;;;;;;;;;;;;;;;;;;;;;;
;; defining what to do ;;
;;;;;;;;;;;;;;;;;;;;;;;;;


;; how populations grow

;; populations grow by a predefined logistics model (see documentation)
;; it also takes care of making sure turtle size does not scale past
;;   the 'carrying-capacity' because once it is reached groups
;;   split up anyway, so having a huge turtle serves no purpose

to grow
  let turtle-size-limiter 100    ;; variable used to make sure the size of
                                 ;;   of turtles stays below 1

  set population (population * exp((reproduction / 100)
      * (1.0 - (population / carrying-capacity))))

;  set population (round population)    ;; stops growth, INVESTIGATE

  ;; option A: turtles that exceeds the carrying-capacity are as big
  ;;   as those that match it
  ifelse population <= carrying-capacity [
    set size ((population / turtle-size-limiter)) ] [ set size 1 ]

  ;; option B: turtles that exceed the carrying-capacity still grow bigger
  ;;   this was useful to find out how many groups surpass the
  ;;   carrying-capacity of their land area, and to adjust for realism
  ;set size ((population / 100))
end

;; how populations are split up

;; populations split once they almost reach the set 'carrying-capacity'
;;   minus 1 because population growth otherwise stops before they reach it
;; they do not split evenly 50:50 but anywhere between 30:70 and 70:30
;; this was arbitrarily set, because the original model had no
;;   documentation of this process
;; a new turtle hatches, with the rest-population of the split
;; its ethnicity matches that of the turtle it hatched from
;; the hatched turtle is also marked as such with 'split-up'
;; lastly the original population is adjusted according to the split

to split
  let pop-split-random 40  ;; used to randomly pick a number between
                                 ;;   0 and 40 and add it to the minimum
  let pop-split-minimum 30 ;; the minimum size of a split population
  ;; both together create a population split anywhere between 30:70 and 70:30

  if population >= (carrying-capacity - 1) [
    let population-split (population *
      ((random pop-split-random + pop-split-minimum) / 100))
    let hatch-ethnicity ethnicity
    let hatch-population (population - population-split)
    hatch 1 [
      set population hatch-population
      set split-up 1
;      set ethnicity hatch-ethnicity    ;; this is already a given with the
                                        ;;   hatch function
    ]
    set population population-split
  ]
end

;; how turtles migrate to new patches

;; CAREFUL the following part should only affect recently hatched turtles
;;   indicated by the 'split-up' variable being set to '1' during 'to split'
;;   but it affects all of them, with all turtles migrating after a split

;; if the turtle just hatched (or rather, if split-up is 1), it sets a
;;   preference for a neighbour patch that is green and without any
;;   other turtles on it
;; if there is such a patch, it becomes the target and it moves there
;; else any green patch is selected as target at random
;; finally the turtles move to its target and are marked as no longer hatched
;; the exact mechanism by wich migration in the original model worked was not
;;   detailled in its documentation, other than there being a preference for
;;   neighbouring patches, hence I kept it as minimalistic as I could

to migrate
  if split-up = 1 [
    let migration-preference neighbors with [
      (pcolor = green) and (not any? turtles-here) ]

    ifelse any? migration-preference [
      let migration-target one-of migration-preference
      move-to migration-target ] [

      let migration-target one-of patches with [
        (pcolor = green) ]
      move-to migration-target ]
    set split-up 0
  ]
end

;; how turtles conduct warfare

;; turtles compare their own ethnicity and population to that of others on
;;   on the same patch, in order to find out who has the bigger population
;; the turtle with the bigger population is considered superior and on the
;;   winning side of warfare
;; population losses occur on both sides, namely 5-25% on the winning side,
;;   and 25-45% on the losing sides, chosen arbitrarily
;; a superior enemy is detected when there is another turle
;;   with a different ethnicity and a higer population than the own
;; if the turtle detects a superior enemy, it dies, because it no longer
;;   serves a function in the simulation, with its population being
;;   incorporated in another turtle and hence no longer representing a group
;; the dead turtles population minus warfare losses is added to the
;;   population of its enemy turtle

;; version 1 also included the following mechanism, but it was omitted
;;   because it turned out to be useless when the previous one already
;;   accounted for the same things
;; likewise an inferior enemy is detected when there is another turtle
;;   with a different ethnicity but a lower population than the own
;; if the turtle detects an inferior enemy, it adds the reduced enemy
;;   population to its own, and the enemy turtle dies

to warfare
  let own-ethnicity ethnicity
  let own-population population
  let superior-enemy other turtles-here with [
    (ethnicity != own-ethnicity) and (population > own-population) ]
;  let inferior-enemy other turtles-here with [    ;; omitted in version 3
;    (ethnicity != own-ethnicity) and (population <= own-population) ]

;; option A: no population losses during warfare
;   if any? superior-enemy [
;     let enemy one-of superior-enemy
;     ask enemy [ set population (population + own-population) ]
;;     set population 0    ;; leftover code, does not seem necessary
;     die
;   ]
;
;   if any? inferior-enemy [
;     let enemy one-of inferior-enemy
;     set population (population + ([ population ] of enemy))
;;     ask enemy [ set population 0    ;; leftover code, does not seem necessary
;;       die ]
;     ask enemy [ die ]
;   ]

;; option B: working with population losses here
;;   however this results in "snowballing" of winning ethnicities
;;   and one ethnicity quickly defeating all the others after a certain time
;;   nonetheless it is the realistic option corresponding to the original model
  let loss-random 20
  let loss-sup-minimum 5
  let loss-inf-minimum 25
  let superior-loss ((random loss-random + loss-sup-minimum) / 100)
  let inferior-loss ((random loss-random + loss-inf-minimum) / 100)

   if any? superior-enemy [
     let enemy one-of superior-enemy
     let enemy-population [ population ] of enemy
     ask enemy [
       set population ((population - (population * superior-loss))
         + (own-population - (own-population * inferior-loss))) ]
;     set population 0    ;; leftover code, does not seem necessary
                          ;;   because it does not matter how big the
                          ;;   polulation of a group is before it dies
     die
   ]

;; omitted mechanism, see comments above
;   if any? inferior-enemy [    ;; leftover code, does not seem necessary
                                ;;   because the section directly above already
                                ;;   accounts for the same process
;     let enemy one-of inferior-enemy
;     let enemy-population [ population ] of enemy
;     set population ((population - (population * superior-loss))
;       + (enemy-population - (enemy-population * inferior-loss)))
;;     ask enemy [ set population 0    ;; leftover code, does not seem necessary
;;       die ]
;     ask enemy [ die ]
;   ]
end

;; how turtles merge

;; turtles compare their ethnicity to that of other turtles
;;   on the same patch
;; the turtle adds its population to one of the same ethnicity
;;   and then it simply dies, because it loses its function when its
;;   population is incorporated into another one and does not
;;   represent a group anymore

to merge
  let own-ethnicity ethnicity
  let own-population population
  let friends other turtles-here with [ ethnicity = own-ethnicity ]

  if any? friends [
    ask one-of friends [ set population (population + own-population) ]
    die
  ]
end

;; how stress affects turtles

;; this checks if stress occurs with a chance of 0.5 percent
;; if it does, the set number of turtles die, chosen randomly

to stress
  let stress-chance 0.5
  let stress-occurence random 100  ;; changed from random-float to random (v02)
  set total-groups (count turtles)
  if stress-occurence <= stress-chance [
    ask n-of round(total-groups * (loss-severity / 100)) turtles [ die ]
  ]
end

;; how to collect statistics

;; only interesting statistics at this point are total number of ethnicities
;;   present in the simulation, partially in order to know when to end it
;;   or how long it may still run for and the total-population, which I found
;;   helpful to compare population growth to the original model
;;   (total-population was omitted in v02)
;; at first it checks if there are turtles with a set ethnicity
;; if there are, the total number of ethnicities raises for 1
;; next iteration of the loop it checks for a different ethnicity
;; after the check a counter is set to +1 and compared to the maximum
;;   possible number of ethnicites in the simulation, so the loop ends once
;;   it checked for the maximum number of ethnicities present

to statistics
  set total-ethnicities 0
;  set total-population 0    ;; omitted in v02

  let n 1
  while [ n <= initial-groups ] [
    if any? turtles with [ ethnicity = n ] [
      set total-ethnicities (total-ethnicities + 1)
    ]
    set n (n + 1)
  ]
;  ask turtles [ set total-population (total-population + population) ]
;  set total-population round(total-population)    ;; omitted in v02

;; the following was removed in version 3 because it does not add
;;   any significant information to the simulation and it did not
;;   work without adjustments in the newer NetLogo version
;  set-current-plot "total-population"    ;; omitted in v02
;  set-current-plot-pen "total-population"
;  plot total-population
end


;;;;;;;;;;;
;; going ;;
;;;;;;;;;;;


;; what happens when the simulation is started

;; the simulation stops once the total number of ethnicities present is 1

to go
  ask turtles [
    grow
    split
    migrate
    warfare
    merge
  ]
  stress
  statistics
  if total-ethnicities = 1 [ stop ]
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
38
10
102
43
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
112
11
175
44
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
18
54
190
87
habitability
habitability
5
100
30.0
5
1
NIL
HORIZONTAL

SLIDER
19
97
191
130
initial-groups
initial-groups
1
20
10.0
1
1
NIL
HORIZONTAL

SLIDER
20
140
192
173
carrying-capacity
carrying-capacity
10
150
100.0
1
1
NIL
HORIZONTAL

SLIDER
21
184
193
217
reproduction
reproduction
0
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
21
229
193
262
loss-severity
loss-severity
0
25
1.0
1
1
NIL
HORIZONTAL

MONITOR
12
274
108
319
total-ethnicites
total-ethnicities
17
1
11

MONITOR
117
274
198
319
total-groups
total-groups
17
1
11

@#$#@#$#@
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
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="hab30_group10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab40_group10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab50_group10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab60_group10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab20_group10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab10_group10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab70_group10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab80_group10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab90_group10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab00_group10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab05_group10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab15_group10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab25_group10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab35_group10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab45_group10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab55_group10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab65_group10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab75_group10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab85_group10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab95_group10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="loss01_hab10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="loss05_hab10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="loss15_hab10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="loss20_hab10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="loss25_hab10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="loss01_hab50" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="loss05_hab50" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="loss15_hab50" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="loss20_hab50" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="loss25_hab50" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="loss01_hab90" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="loss05_hab90" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="loss15_hab90" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="loss20_hab90" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="loss25_hab90" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="loss10_hab10" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="loss10_hab50" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="loss10_hab90" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab30_group20" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab40_group20" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab50_group20" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab60_group20" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab20_group20" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab10_group20" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab70_group20" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="70"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab80_group20" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab90_group20" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab00_group20" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab05_group20" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab15_group20" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab25_group20" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab35_group20" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab45_group20" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab55_group20" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab65_group20" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab75_group20" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab85_group20" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="85"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="hab95_group20" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <enumeratedValueSet variable="reproduction">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="habitability">
      <value value="95"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="carrying-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="loss-severity">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-groups">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
