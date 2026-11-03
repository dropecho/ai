"use strict";

const CONDITION_NAMES = ["found_weapon", "found_wood", "has_weapon"];

const ACTION_SPECS = [
  { name: "buy_weapon", cost: 10, needs: [], makes: ["has_weapon"], ticks: 3 },
  { name: "find_weapon", cost: 1, needs: [], makes: ["found_weapon"], ticks: 2 },
  { name: "get_weapon", cost: 1, needs: ["found_weapon"], makes: ["has_weapon"], ticks: 1 },
  { name: "gather_wood", cost: 2, needs: [], makes: ["found_wood"], ticks: 2 },
  { name: "carve_club", cost: 1, needs: ["found_wood"], makes: ["has_weapon"], ticks: 2 },
].map((spec) => ({ ...spec, enabled: true }));

// The game's world: an Action makes its postconditions true here once it has run its ticks.
// No Action has a done check of its own, so the Plan drops each one once its postconditions are true.
function createAction(spec, progress, world) {
  const onUpdate = () => {
    const ticksRun = (progress.get(spec.name) ?? 0) + 1;
    progress.set(spec.name, ticksRun);
    if (ticksRun >= spec.ticks) {
      spec.makes.forEach((condition) => world.add(condition));
    }
  };
  return new goap.Action(spec.name, onUpdate, spec.cost, spec.needs, spec.makes);
}

function makePlan(specs, goalConditions, startConditions) {
  const progress = new Map();
  const world = new Set(startConditions);
  const worldState = () => [...world];
  const actions = specs.filter((spec) => spec.enabled).map((spec) => createAction(spec, progress, world));
  const plan = new goap.Planner(new goap.Goal(goalConditions), actions, worldState).generatePlan();
  return { plan, progress, world, actions: plan === null ? [] : plan.remainingActions() };
}

function totalCost(actions) {
  return actions.reduce((sum, action) => sum + action.cost, 0);
}

function cheapestOneStep(specs, goalConditions, startConditions) {
  const missing = goalConditions.filter((c) => !startConditions.includes(c));
  const reachesGoalDirectly = (spec) =>
    spec.enabled &&
    missing.length > 0 &&
    spec.needs.every((c) => startConditions.includes(c)) &&
    missing.every((c) => spec.makes.includes(c));
  const candidates = specs.filter(reachesGoalDirectly);
  candidates.sort((a, b) => a.cost - b.cost);
  return candidates[0] ?? null;
}

function renderActionRow(spec, onChange) {
  const use = el("input", { type: "checkbox", "aria-label": `Use ${spec.name}` });
  use.checked = spec.enabled;
  use.addEventListener("change", () => {
    spec.enabled = use.checked;
    onChange();
  });

  const cost = el("input", { type: "number", min: "0", step: "1", value: String(spec.cost), "aria-label": `Cost of ${spec.name}` });
  cost.addEventListener("input", () => {
    const value = Number(cost.value);
    if (Number.isFinite(value) && value >= 0) {
      spec.cost = value;
      onChange();
    }
  });

  return el("tr", {}, [
    el("td", {}, [use]),
    el("th", { scope: "row" }, [el("code", { text: spec.name })]),
    el("td", {}, [cost]),
    el("td", { text: spec.needs.join(", ") || "—" }),
    el("td", { text: spec.makes.join(", ") }),
    el("td", { class: "num", text: String(spec.ticks) }),
  ]);
}

function renderStartConditions(container, startConditions, onChange) {
  const boxes = CONDITION_NAMES.map((condition) => {
    const box = el("input", { type: "checkbox" });
    box.checked = startConditions.has(condition);
    box.addEventListener("change", () => {
      if (box.checked) {
        startConditions.add(condition);
      } else {
        startConditions.delete(condition);
      }
      onChange();
    });
    return el("label", {}, [box, " ", el("code", { text: condition })]);
  });
  container.replaceChildren(el("span", { text: "True at the start:" }), ...boxes);
}

function renderPlan(container, run, oneStep) {
  if (run.plan === null) {
    container.replaceChildren(
      el("p", { class: "callout" }, [el("strong", { text: "No Plan. " }), "generatePlan() returned null."]),
      el("p", { class: "muted", text: "No sequence of the Actions in use reaches the Goal from the starting World state." }),
    );
    return;
  }
  const cost = totalCost(run.actions);
  const steps = run.actions.map((action) =>
    el("li", {}, [el("code", { text: action.name }), ` (Cost ${action.cost})`]),
  );
  const parts = [
    el("p", { class: "callout", text: `Total Cost ${cost}` }),
    run.actions.length === 0 ? el("p", { text: "The Goal is already true: the Plan is empty." }) : el("ol", {}, steps),
  ];
  const greedyDiffers = oneStep !== null && oneStep.cost > cost;
  if (greedyDiffers) {
    parts.push(
      el("p", {
        class: "muted",
        text: `A greedy choice of the one Action that reaches the Goal directly would be ${oneStep.name} at Cost ${oneStep.cost}.`,
      }),
    );
  }
  container.replaceChildren(...parts);
}

function renderRun(list, statusEl, worldEl, run) {
  const conditions = [...run.world];
  worldEl.textContent = conditions.length === 0 ? "World state: (empty)" : `World state: ${conditions.join(", ")}`;
  if (run.plan === null) {
    list.replaceChildren();
    statusEl.textContent = "Nothing to run.";
    return;
  }
  const current = run.plan.currentAction();
  const remaining = run.plan.remainingActions();
  const items = run.actions.map((action) => {
    const ticksRun = run.progress.get(action.name) ?? 0;
    const spec = ACTION_SPECS.find((s) => s.name === action.name);
    const isDropped = !remaining.includes(action);
    const label = isDropped ? "done" : action === current ? "current" : "pending";
    const bar = el("div", { class: "bar", role: "img", "aria-label": `${ticksRun} of ${spec.ticks} ticks` }, [
      el("span", { style: `width: ${Math.min(100, (ticksRun / spec.ticks) * 100)}%` }),
    ]);
    return el("li", {}, [
      el("span", { class: `node${action === current ? " ran" : ""}` }, [
        el("code", { text: action.name }),
        el("span", { class: "kind", text: `${label} · ${Math.min(ticksRun, spec.ticks)}/${spec.ticks}` }),
      ]),
      bar,
    ]);
  });
  list.replaceChildren(...items);
  statusEl.textContent = run.plan.isCompleted() ? "Plan completed." : `${run.plan.length()} Action(s) left.`;
}

function setupPage() {
  const goalEl = document.getElementById("goal");
  const planEl = document.getElementById("plan");
  const runEl = document.getElementById("run");
  const runStatusEl = document.getElementById("run-status");
  const worldEl = document.getElementById("world");
  const startConditions = new Set();
  let run = null;

  function goalConditions() {
    return goalEl.value.split(",");
  }

  function replan() {
    ticker.pause();
    const start = [...startConditions];
    run = makePlan(ACTION_SPECS, goalConditions(), start);
    renderPlan(planEl, run, cheapestOneStep(ACTION_SPECS, goalConditions(), start));
    renderRun(runEl, runStatusEl, worldEl, run);
  }

  function step() {
    if (run.plan === null || run.plan.isCompleted()) {
      ticker.pause();
      return;
    }
    run.plan.update(1);
    renderRun(runEl, runStatusEl, worldEl, run);
  }

  const ticker = createTicker(step, document.getElementById("play"), 700);
  document.getElementById("step").addEventListener("click", step);
  document.getElementById("restart").addEventListener("click", replan);
  goalEl.addEventListener("change", replan);

  renderStartConditions(document.getElementById("start-conditions"), startConditions, replan);
  const rows = ACTION_SPECS.map((spec) => renderActionRow(spec, replan));
  document.getElementById("actions").replaceChildren(...rows);
  replan();
}

setupPage();
