package dropecho.ai.goap;

import dropecho.interop.AbstractFunc.Func_0;

/**
 * A game-supplied function that returns the Condition names true in the game right now.
 * The Planner plans from what it returns, and a Plan uses it to tell when an Action without its own done check is done.
 */
typedef WorldStateProvider = Func_0<Array<String>>;
