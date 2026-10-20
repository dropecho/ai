"use strict";

const { SUCCESS, FAILURE, RUNNING } = bt.NODE_STATUS;
const FACT_KEYS = ["hunger", "energy"];
const FULL_ENERGY = 6;

function isHungry(bb) {
  return bb.get("hunger") >= 3 ? SUCCESS : FAILURE;
}

function eat(bb) {
  return bb.decrement("hunger") > 0 ? RUNNING : SUCCESS;
}

function isTired(bb) {
  return bb.get("energy") <= 1 ? SUCCESS : FAILURE;
}

function sleep(bb) {
  bb.increment("hunger");
  return bb.increment("energy") >= FULL_ENERGY ? SUCCESS : RUNNING;
}

function wander(bb) {
  bb.increment("hunger");
  bb.decrement("energy");
  return SUCCESS;
}

TaskBank.register("is_hungry", isHungry);
TaskBank.register("eat", eat);
TaskBank.register("is_tired", isTired);
TaskBank.register("sleep", sleep);
TaskBank.register("wander", wander);

function buildTree(isReactive) {
  const eatWhenHungry = new bt.SequenceNode([new bt.TaskNode("is_hungry"), new bt.TaskNode("eat")]);
  const sleepWhenTired = new bt.SequenceNode([new bt.TaskNode("is_tired"), new bt.TaskNode("sleep")]);
  const root = new bt.SelectorNode([eatWhenHungry, sleepWhenTired, new bt.TaskNode("wander")], isReactive);

  const tree = new bt.BehaviorTree(root);
  tree.setLabel(root, "root");
  tree.setLabel(eatWhenHungry, "eat when hungry");
  tree.setLabel(sleepWhenTired, "sleep when tired");
  return tree;
}

function childrenOf(node) {
  return typeof node.children === "function" ? node.children() : [];
}

function kindOf(node) {
  if (node instanceof bt.SelectorNode) {
    return node.reactive ? "Reactive Selector" : "Selector";
  }
  if (node instanceof bt.SequenceNode) {
    return "Sequence";
  }
  if (node instanceof bt.TaskNode) {
    return "Task node";
  }
  return "Node";
}

// The tracer is a plain object: it keeps the StatusRecorder up to date for the
// tree view and dump, and lists the Tasks run and nodes halted, in order, for the log.
function createTracer(tree, recorder) {
  const events = [];
  return {
    events,
    onTick(node, status, deltaTime) {
      recorder.onTick(node, status, deltaTime);
      const isTask = node instanceof bt.TaskNode;
      if (isTask) {
        events.push(`${tree.labelOf(node)} ${statusName(status)}`);
      }
    },
    onHalt(node) {
      recorder.onHalt(node);
      events.push(`${tree.labelOf(node)} halted`);
    },
  };
}

// The child cursor is internal to a Composite; it is read here only to draw ▸.
// A reactive Composite starts from its first child every tick, so it resumes nothing.
function cursorIndex(node) {
  const cursor = node.childCursor;
  const isReactive = node.reactive === true;
  if (!cursor || isReactive) {
    return -1;
  }
  return childrenOf(node).indexOf(cursor.current());
}

function createSimulation(isReactive) {
  const blackboard = new Blackboard();
  blackboard.set("hunger", 0);
  blackboard.set("energy", FULL_ENERGY);
  const tree = buildTree(isReactive);
  const recorder = new bt.StatusRecorder();
  const tracer = createTracer(tree, recorder);
  tree.setTracer(tracer);
  tree.init(blackboard);
  return { blackboard, tree, recorder, tracer, tickCount: 0, lastStatus: null };
}

function tick(sim) {
  sim.recorder.clear();
  sim.tracer.events.length = 0;
  sim.lastStatus = sim.tree.execute(1);
  sim.tickCount += 1;
  return sim.lastStatus;
}

function renderNode(sim, node, isCursor) {
  const status = sim.recorder.statusOf(node);
  const row = el("span", { class: "node" }, [
    el("span", { text: sim.tree.labelOf(node) ?? "" }),
    el("span", { class: "kind", text: kindOf(node) }),
  ]);
  if (status != null) {
    row.classList.add("ran");
    row.append(el("span", { class: `status status-${statusName(status)}`, text: statusName(status) }));
  }
  if (sim.recorder.wasHalted(node)) {
    row.classList.add("halted");
    row.append(el("span", { class: "status", text: "halted" }));
  }
  if (isCursor) {
    row.classList.add("cursor");
    row.setAttribute("title", "The child this Composite resumes next tick");
  }
  const item = el("li", {}, [row]);
  const children = childrenOf(node);
  if (children.length > 0) {
    const cursor = cursorIndex(node);
    const list = el("ul", {}, children.map((child, i) => renderNode(sim, child, i === cursor)));
    item.append(list);
  }
  return item;
}

function setupPage() {
  const treeEl = document.getElementById("tree");
  const dumpEl = document.getElementById("dump");
  const factsEl = document.getElementById("facts");
  const logEl = document.getElementById("log");
  const statusEl = document.getElementById("tick-status");
  const reactiveEl = document.getElementById("reactive");
  let sim = createSimulation(reactiveEl.checked);

  function render() {
    const root = childrenOf(sim.tree)[0];
    treeEl.replaceChildren(renderNode(sim, root, false));
    dumpEl.textContent = sim.tree.toText(sim.recorder);
    renderFacts(factsEl, sim.blackboard, FACT_KEYS);
    statusEl.textContent =
      sim.tickCount === 0 ? "Not ticked yet" : `Tick ${sim.tickCount}: tree answered ${statusName(sim.lastStatus)}`;
  }

  function step() {
    const status = tick(sim);
    appendLog(logEl, `#${sim.tickCount} ${statusName(status)} · ran ${sim.tracer.events.join(", ")}`);
    render();
  }

  const ticker = createTicker(step, document.getElementById("play"));
  document.getElementById("step").addEventListener("click", step);
  function restart() {
    ticker.pause();
    sim = createSimulation(reactiveEl.checked);
    logEl.replaceChildren();
    render();
  }

  document.getElementById("reset").addEventListener("click", restart);
  reactiveEl.addEventListener("change", restart);
  render();
}

setupPage();
