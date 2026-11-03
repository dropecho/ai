"use strict";

const MOTIVE_SPECS = [
  { name: "hunger", start: 0.8, decay: 0.04 },
  { name: "thirst", start: 0.6, decay: 0.06 },
  { name: "energy", start: 0.9, decay: 0.02 },
  { name: "fun", start: 0.7, decay: 0.03 },
];
const TOP_UP = 0.3;

function clamp01(value) {
  return Math.min(1, Math.max(0, value));
}

function createAgent() {
  const agent = new utility.UtilityAgent();
  for (const spec of MOTIVE_SPECS) {
    agent.motives.push(new utility.Motive(spec.name, spec.start));
  }
  return agent;
}

function decayOf(motive) {
  return MOTIVE_SPECS.find((spec) => spec.name === motive.name).decay;
}

function tick(agent, shouldAct) {
  for (const motive of agent.motives) {
    motive.value = clamp01(motive.value - decayOf(motive));
  }
  const picked = agent.getMostImportantMotive();
  if (shouldAct) {
    picked.value = clamp01(picked.value + TOP_UP);
  }
  return picked;
}

function renderMotive(motive, isMostImportant, onInput) {
  const id = `motive-${motive.name}`;
  const slider = el("input", { id, type: "range", min: "0", max: "1", step: "0.01" });
  slider.value = String(motive.value);
  slider.addEventListener("input", () => onInput(motive, Number(slider.value)));
  return el("div", { class: `motive${isMostImportant ? " most-important" : ""}` }, [
    el("label", { for: id }, [
      el("span", { text: motive.name }),
      el("span", { class: "status", text: motive.value.toFixed(2) }),
    ]),
    slider,
    el("span", { class: "kind", text: `decays ${decayOf(motive)} per tick` }),
  ]);
}

function setupPage() {
  const motivesEl = document.getElementById("motives");
  const pickEl = document.getElementById("pick");
  const logEl = document.getElementById("log");
  const actEl = document.getElementById("act");
  let agent = createAgent();
  let tickCount = 0;

  function updateValues() {
    const picked = agent.getMostImportantMotive();
    pickEl.textContent = `${picked.name} (${picked.value.toFixed(2)})`;
    agent.motives.forEach((motive, i) => {
      const row = motivesEl.children[i];
      row.classList.toggle("most-important", motive === picked);
      row.querySelector(".status").textContent = motive.value.toFixed(2);
      const slider = row.querySelector("input");
      if (document.activeElement !== slider) {
        slider.value = String(motive.value);
      }
    });
  }

  function setValue(motive, value) {
    motive.value = value;
    updateValues();
  }

  function renderAll() {
    const picked = agent.getMostImportantMotive();
    motivesEl.replaceChildren(...agent.motives.map((m) => renderMotive(m, m === picked, setValue)));
    updateValues();
  }

  function step() {
    const picked = tick(agent, actEl.checked);
    tickCount += 1;
    const action = actEl.checked ? `, topped up to ${picked.value.toFixed(2)}` : "";
    appendLog(logEl, `#${tickCount} picked ${picked.name}${action}`);
    updateValues();
  }

  const ticker = createTicker(step, document.getElementById("play"), 600);
  document.getElementById("step").addEventListener("click", step);
  document.getElementById("reset").addEventListener("click", () => {
    ticker.pause();
    agent = createAgent();
    tickCount = 0;
    logEl.replaceChildren();
    renderAll();
  });
  renderAll();
}

setupPage();
