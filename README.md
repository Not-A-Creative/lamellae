# Lamellae
![A screenshot of the script in norns](./assets/lamellae_cover.png)

A music box inspired generative instrument for Norns.
Create randomised patterns of controllable length and density, which can be played by turning an encoder. Alternatively set the pattern playing at a constant controllable rate.

### Requirements
- Norns

### Install

Via Maiden REPL with
```
;install https://github.com/Not-A-Creative/Lamellae
```

### Controls

- KEY2: Start/Stop automatic playing
- KEY3: Regenerate the pattern
- ENC2: Play Speed
- ENC3: Turn Clockwise to play

Other functions controllable from the params menu:

- Number of possible notes, and scale
- Total length of the pattern (in screen widths)
- Number of events in the pattern
- Engine controls (PolyPerc)

### Interface

The screen will display a number of rectangles to the left, representing the 'lamella' or 'tongues' (or 'keys' as referenced in the code for brevity) of a music box. Each corresponds to an individual note in the assigned scale. The number of which can be changed from the params menu.

The bulk of the screen will be taken up with the pattern of note, each dot triggering a note when it passes a tongue. Movement of the pattern from left to right is controlled by turning ENC3 or can be set running at a constant rate with KEY2.

The pattern loops back to the starting point at the tongues after reaching a specified distance, measured in widths of the display area (which can be changed in the params menu). At a Pattern Length of 1 the pattern loops directly from the right side of the screen. And greater and positions continue being calculated past the border of the screen until the appropriate loop point.

The pattern is generated completely randomly, with a total number of events that can again be set in the params. NOTE: There is not protection against multiple events holding the same coordinates. This is an intentional oversight for code simplicity and as it adds some extra variation in the way patterns may generate.

The pattern is regenerated if any of the key or pattern params are altered.

### Engine

The script uses Poly Perc with the associated engine options accessable in the params.

By default the settings are; Amp = 0.8, Cutoff = 500 Hz, Pan = 0, Pulse Width = 0.5, Release = 1.5 s
