package dropecho.ai.bt.node;

import dropecho.interop.AbstractFunc.Func_1;
import dropecho.ai.Blackboard;

/** A game-defined yes/no question about the Blackboard, asked by Condition and Guard nodes. It should only read state. */
typedef Check = Func_1<Blackboard, Bool>;
