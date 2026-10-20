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

// A view pairs a library node with what the page shows about it. The library calls
// the wrapper, which passes straight through and records the Status for this tick.
function makeView(label, kind, node, children = []) {
  const view = { label, kind, node, children, ran: false, status: null };
  view.wrapper = {
    init(context) {
      node.init(context);
    },
    execute() {
      const status = node.execute();
      view.ran = true;
      view.status = status;
      return status;
    },
  };
  return view;
}

function task(name) {
  return makeView(name, "Task node", new bt.TaskNode(name));
}

function selector(label, children) {
  return makeView(label, "Selector", new bt.SelectorNode(children.map((c) => c.wrapper)), children);
}

function reactiveSelector(label, children) {
  return makeView(label, "Reactive Selector", new bt.SelectorNode(children.map((c) => c.wrapper), true), children);
}

function sequence(label, children) {
  return makeView(label, "Sequence", new bt.SequenceNode(children.map((c) => c.wrapper)), children);
}

function buildRootView(isReactive) {
  const rootSelector = isReactive ? reactiveSelector : selector;
  return rootSelector("root", [
    sequence("eat when hungry", [task("is_hungry"), task("eat")]),
    sequence("sleep when tired", [task("is_tired"), task("sleep")]),
    task("wander"),
  ]);
}

function forEachView(view, visit) {
  visit(view);
  for (const child of view.children) {
    forEachView(child, visit);
  }
}

// The child cursor is internal to a Composite; it is read here only to draw ▸.
// A reactive Composite starts from its first child every tick, so it resumes nothing.
function cursorIndex(view) {
  const cursor = view.node.childCursor;
  const isReactive = view.node.reactive === true;
  if (!cursor || isReactive) {
    return -1;
  }
  const current = cursor.current();
  return view.children.findIndex((child) => child.wrapper === current);
}

function createSimulation(isReactive) {
  const blackboard = new Blackboard();
  blackboard.set("hunger", 0);
  blackboard.set("energy", FULL_ENERGY);
  const rootView = buildRootView(isReactive);
  const tree = new bt.BehaviorTree(rootView.wrapper);
  tree.init(blackboard);
  return { blackboard, rootView, tree, tickCount: 0, lastStatus: null };
}

function tick(sim) {
  forEachView(sim.rootView, (view) => {
    view.ran = false;
  });
  sim.lastStatus = sim.tree.execute();
  sim.tickCount += 1;
  return sim.lastStatus;
}

function ranTasks(rootView) {
  const ran = [];
  forEachView(rootView, (view) => {
    const isRanTask = view.ran && view.children.length === 0;
    if (isRanTask) {
      ran.push(`${view.label} ${statusName(view.status)}`);
    }
  });
  return ran;
}

function renderNode(view, isCursor) {
  const row = el("span", { class: "node" }, [
    el("span", { text: view.label }),
    el("span", { class: "kind", text: view.kind }),
  ]);
  if (view.ran) {
    row.classList.add("ran");
    row.append(el("span", { class: `status status-${statusName(view.status)}`, text: statusName(view.status) }));
  }
  if (isCursor) {
    row.classList.add("cursor");
    row.setAttribute("title", "The child this Composite resumes next tick");
  }
  const item = el("li", {}, [row]);
  if (view.children.length > 0) {
    const cursor = cursorIndex(view);
    const list = el("ul", {}, view.children.map((child, i) => renderNode(child, i === cursor)));
    item.append(list);
  }
  return item;
}

function setupPage() {
  const treeEl = document.getElementById("tree");
  const factsEl = document.getElementById("facts");
  const logEl = document.getElementById("log");
  const statusEl = document.getElementById("tick-status");
  const reactiveEl = document.getElementById("reactive");
  let sim = createSimulation(reactiveEl.checked);

  function render() {
    treeEl.replaceChildren(renderNode(sim.rootView, false));
    renderFacts(factsEl, sim.blackboard, FACT_KEYS);
    statusEl.textContent =
      sim.tickCount === 0 ? "Not ticked yet" : `Tick ${sim.tickCount}: tree answered ${statusName(sim.lastStatus)}`;
  }

  function step() {
    const status = tick(sim);
    appendLog(logEl, `#${sim.tickCount} ${statusName(status)} · ran ${ranTasks(sim.rootView).join(", ")}`);
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
