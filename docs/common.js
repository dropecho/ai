"use strict";

// Shared by the demo pages. Expects the dropecho.ai bundle to be loaded first.

const STATUS_NAMES = ["SUCCESS", "FAILURE", "RUNNING"];

function statusName(status) {
  return STATUS_NAMES[status] ?? String(status);
}

function el(tag, attrs = {}, children = []) {
  const node = document.createElement(tag);
  for (const [key, value] of Object.entries(attrs)) {
    if (key === "text") {
      node.textContent = value;
    } else if (key === "class") {
      node.className = value;
    } else {
      node.setAttribute(key, value);
    }
  }
  for (const child of children) {
    node.append(child);
  }
  return node;
}

// Blackboard cannot list its facts, so each demo passes the keys it uses.
function renderFacts(tbody, blackboard, keys) {
  const rows = keys.map((key) =>
    el("tr", {}, [
      el("th", { scope: "row", text: key }),
      el("td", { class: "num", text: String(blackboard.get(key)) }),
    ]),
  );
  tbody.replaceChildren(...rows);
}

function appendLog(list, text, maxEntries = 50) {
  list.prepend(el("li", { text }));
  while (list.children.length > maxEntries) {
    list.lastElementChild.remove();
  }
}

function createTicker(step, playButton, intervalMs = 600) {
  let timer = null;

  function isPlaying() {
    return timer !== null;
  }

  function pause() {
    clearInterval(timer);
    timer = null;
    playButton.textContent = "Play";
    playButton.setAttribute("aria-pressed", "false");
  }

  function play() {
    timer = setInterval(step, intervalMs);
    playButton.textContent = "Pause";
    playButton.setAttribute("aria-pressed", "true");
  }

  playButton.addEventListener("click", () => {
    if (isPlaying()) {
      pause();
    } else {
      play();
    }
  });

  return { play, pause, isPlaying };
}
