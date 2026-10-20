"use strict";

const FACT_KEYS = ["hunger", "energy", "danger"];
const RESTED_ENERGY = 5;

function createState(name, tick, log) {
  return {
    getName: () => name,
    onEnter: () => log(`enter ${name}`),
    onExit: () => log(`exit ${name}`),
    tick,
  };
}

function createSimulation(log) {
  const bb = new Blackboard();
  bb.set("hunger", 0);
  bb.set("energy", RESTED_ENERGY);
  bb.set("danger", 0);

  const wander = createState("wander", () => {
    bb.increment("hunger");
    bb.decrement("energy");
  }, log);
  const eat = createState("eat", () => bb.decrement("hunger"), log);
  const sleep = createState("sleep", () => bb.increment("energy"), log);
  const flee = createState("flee", () => bb.decrement("energy"), log);

  const machine = new fsm.FSM();

  const isHungry = () => bb.get("hunger") > 2;
  const isFull = () => bb.get("hunger") <= 0;
  const isExhausted = () => bb.get("energy") <= 0;
  const isRested = () => bb.get("energy") >= RESTED_ENERGY;
  const isSafe = () => bb.get("danger") <= 0;
  const dangerAppears = () => bb.get("danger") > 0;

  const transitions = [
    { from: wander, to: eat, condition: isHungry, text: "hunger > 2" },
    { from: wander, to: sleep, condition: isExhausted, text: "energy ≤ 0" },
    { from: eat, to: wander, condition: isFull, text: "hunger ≤ 0" },
    { from: sleep, to: wander, condition: isRested, text: `energy ≥ ${RESTED_ENERGY}` },
    { from: flee, to: wander, condition: isSafe, text: "danger is off" },
    { from: null, to: flee, condition: dangerAppears, text: "danger is on" },
  ];

  for (const t of transitions) {
    if (t.from === null) {
      machine.addAnyTransition(t.to, t.condition);
    } else {
      machine.addTransition(t.from, t.to, t.condition);
    }
  }
  machine.changeToState(wander);

  return { bb, machine, transitions, tickCount: 0 };
}

function tick(sim) {
  const before = sim.machine.getCurrentState().getName();
  sim.machine.tick();
  sim.tickCount += 1;
  return before;
}

function renderTransitions(tbody, transitions) {
  const rows = transitions.map((t) =>
    el("tr", {}, [
      el("td", { text: t.from === null ? "any" : t.from.getName() }),
      el("td", { text: t.to.getName() }),
      el("td", { text: t.text }),
    ]),
  );
  tbody.replaceChildren(...rows);
}

function setupGraph(container) {
  return d3.select(container).graphviz().zoom(false).fade(false).tweenShapes(false);
}

function setupPage() {
  const graphEl = document.getElementById("graph");
  const factsEl = document.getElementById("facts");
  const logEl = document.getElementById("log");
  const statusEl = document.getElementById("tick-status");
  const dangerButton = document.getElementById("danger");
  const graph = setupGraph(graphEl);
  // onEnter/onExit fire inside tick(), so their events are gathered into that tick's log line.
  let events = [];
  const log = (text) => events.push(text);
  let sim = createSimulation(log);

  function flushLog(prefix) {
    const suffix = events.length > 0 ? ` · ${events.join(", ")}` : "";
    appendLog(logEl, `${prefix}${suffix}`);
    events = [];
  }

  function render() {
    const current = sim.machine.getCurrentState().getName();
    renderFacts(factsEl, sim.bb, FACT_KEYS);
    statusEl.textContent = `Tick ${sim.tickCount}: current State is ${current}`;
    graph.renderDot(sim.machine.toDot());
    const dangerOn = sim.bb.get("danger") > 0;
    dangerButton.textContent = `Danger: ${dangerOn ? "on" : "off"}`;
    dangerButton.setAttribute("aria-pressed", String(dangerOn));
  }

  function step() {
    const before = tick(sim);
    flushLog(`#${sim.tickCount} ${before} ticked`);
    render();
  }

  const ticker = createTicker(step, document.getElementById("play"), 800);
  document.getElementById("step").addEventListener("click", step);
  document.getElementById("reset").addEventListener("click", () => {
    ticker.pause();
    logEl.replaceChildren();
    events = [];
    sim = createSimulation(log);
    flushLog("#0 start");
    render();
  });
  dangerButton.addEventListener("click", () => {
    sim.bb.set("danger", sim.bb.get("danger") > 0 ? 0 : 1);
    render();
  });

  renderTransitions(document.getElementById("transitions"), sim.transitions);
  flushLog("#0 start");
  render();
}

setupPage();
