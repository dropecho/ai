"use strict";

const ACTION_SPECS = [
  { name: "buy_weapon", cost: 10, needs: [], makes: ["has_weapon"], ticks: 3 },
  { name: "find_weapon", cost: 1, needs: [], makes: ["found_weapon"], ticks: 2 },
  { name: "get_weapon", cost: 1, needs: ["found_weapon"], makes: ["has_weapon"], ticks: 1 },
  { name: "gather_wood", cost: 2, needs: [], makes: ["found_wood"], ticks: 2 },
  { name: "carve_club", cost: 1, needs: ["found_wood"], makes: ["has_weapon"], ticks: 2 },
].map((spec) => ({ ...spec, enabled: true }));

// Each run gets fresh Actions, so their progress starts at zero.
function createAction(spec, progress) {
  const update = () => {
    progress.set(spec.name, (progress.get(spec.name) ?? 0) + 1);
  };
  const isDone = () => (progress.get(spec.name) ?? 0) >= spec.ticks;
  return new goap.Action(spec.name, update, spec.cost, spec.needs, spec.makes, null, isDone);
}

function makePlan(specs, goalConditions) {
  const progress = new Map();
  const actions = specs.filter((spec) => spec.enabled).map((spec) => createAction(spec, progress));
  const plan = new goap.Planner(new goap.State(goalConditions), actions).generatePlan();
  return { plan, progress, actions: plan === null ? [] : remainingActions(plan) };
}

// A Plan iterates with Haxe's hasNext/next, not the JS iterator protocol.
function remainingActions(plan) {
  const actions = [];
  const iterator = plan.iterator();
  while (iterator.hasNext()) {
    actions.push(iterator.next());
  }
  return actions;
}

function totalCost(actions) {
  return actions.reduce((sum, action) => sum + action.Cost, 0);
}

function cheapestOneStep(specs, goalConditions) {
  const reachesGoalDirectly = (spec) =>
    spec.enabled && spec.needs.length === 0 && goalConditions.every((c) => spec.makes.includes(c));
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

function renderPlan(container, run, oneStep) {
  if (run.plan === null) {
    container.replaceChildren(
      el("p", { class: "callout" }, [el("strong", { text: "No Plan. " }), "generatePlan() returned null."]),
      el("p", { class: "muted", text: "No sequence of the Actions in use reaches the Goal from the empty World state." }),
    );
    return;
  }
  const cost = totalCost(run.actions);
  const steps = run.actions.map((action) =>
    el("li", {}, [el("code", { text: action.ActionType }), ` (Cost ${action.Cost})`]),
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

function renderRun(list, statusEl, run) {
  if (run.plan === null) {
    list.replaceChildren();
    statusEl.textContent = "Nothing to run.";
    return;
  }
  const current = run.plan.get_currentAction();
  const items = run.actions.map((action) => {
    const done = run.progress.get(action.ActionType) ?? 0;
    const spec = ACTION_SPECS.find((s) => s.name === action.ActionType);
    const isDropped = !remainingActions(run.plan).includes(action);
    const label = isDropped ? "done" : action === current ? "current" : "pending";
    const bar = el("div", { class: "bar", role: "img", "aria-label": `${done} of ${spec.ticks} ticks` }, [
      el("span", { style: `width: ${Math.min(100, (done / spec.ticks) * 100)}%` }),
    ]);
    return el("li", {}, [
      el("span", { class: `node${action === current ? " ran" : ""}` }, [
        el("code", { text: action.ActionType }),
        el("span", { class: "kind", text: `${label} · ${Math.min(done, spec.ticks)}/${spec.ticks}` }),
      ]),
      bar,
    ]);
  });
  list.replaceChildren(...items);
  statusEl.textContent = run.plan.isCompleted() ? "Plan completed." : `${run.plan.get_length()} Action(s) left.`;
}

function setupPage() {
  const goalEl = document.getElementById("goal");
  const planEl = document.getElementById("plan");
  const runEl = document.getElementById("run");
  const runStatusEl = document.getElementById("run-status");
  let run = null;

  function goalConditions() {
    return goalEl.value.split(",");
  }

  function replan() {
    run = makePlan(ACTION_SPECS, goalConditions());
    renderPlan(planEl, run, cheapestOneStep(ACTION_SPECS, goalConditions()));
    renderRun(runEl, runStatusEl, run);
  }

  function step() {
    if (run.plan === null || run.plan.isCompleted()) {
      ticker.pause();
      return;
    }
    run.plan.update(1);
    renderRun(runEl, runStatusEl, run);
  }

  const ticker = createTicker(step, document.getElementById("play"), 700);
  document.getElementById("step").addEventListener("click", step);
  document.getElementById("restart").addEventListener("click", () => {
    ticker.pause();
    replan();
  });
  goalEl.addEventListener("change", replan);

  const rows = ACTION_SPECS.map((spec) => renderActionRow(spec, replan));
  document.getElementById("actions").replaceChildren(...rows);
  replan();
}

setupPage();
