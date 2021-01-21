## forced waiting

These benchmarks attempt to enforce a sidestep and/or a waiting phase from one of the robots to let the other robot pass.

`forced_waiting.lp` has a gap that has to be used properly in order to solve this instance. 
One of the robots has to position itself in the gap to let the other robot trough. 
`forced_waiting_v2.lp` is a variation of `forced_waiting.lp`. One of the robots has to wait (no movement at all in the best case scenario) because the gap is missing in this one.

Both try to test if robots switch places to avoid the waiting phase and if taking turns (in form of waiting) is implemented correctly.

### Horizons
forced_waiting.lp: horizon=9
forced_waiting_v2.lp: horizon=16
