const expressionEl = document.querySelector("#expression");
const resultEl = document.querySelector("#result");
const keys = document.querySelector(".keys");

let expression = "";
let justEvaluated = false;

const operators = new Set(["+", "-", "*", "/", "%"]);

function toDisplayValue(value) {
  return value
    .replaceAll("*", "×")
    .replaceAll("/", "÷")
    .replaceAll("-", "−");
}

function updateDisplay(result = null) {
  expressionEl.textContent = expression ? toDisplayValue(expression) : "0";
  resultEl.textContent = result ?? (expression ? toDisplayValue(expression) : "0");
}

function getCurrentNumber() {
  const parts = expression.split(/[+\-*/%]/);
  return parts.at(-1) ?? "";
}

function appendValue(value) {
  if (justEvaluated && !operators.has(value)) {
    expression = "";
  }

  justEvaluated = false;

  if (value === ".") {
    const currentNumber = getCurrentNumber();
    if (currentNumber.includes(".")) return;
    expression += currentNumber ? "." : "0.";
    updateDisplay();
    return;
  }

  if (operators.has(value)) {
    if (!expression && value !== "-") return;

    const last = expression.at(-1);
    if (operators.has(last)) {
      expression = expression.slice(0, -1) + value;
    } else {
      expression += value;
    }

    updateDisplay();
    return;
  }

  expression += value;
  updateDisplay();
}

function calculate() {
  if (!expression) return;

  let normalized = expression;
  while (operators.has(normalized.at(-1))) {
    normalized = normalized.slice(0, -1);
  }

  if (!normalized) return;

  try {
    const value = Function(`"use strict"; return (${normalized})`)();
    if (!Number.isFinite(value)) {
      throw new Error("Invalid result");
    }

    const formatted = Number.parseFloat(value.toFixed(10)).toString();
    expression = formatted;
    justEvaluated = true;
    updateDisplay(formatted);
  } catch {
    resultEl.textContent = "错误";
    justEvaluated = true;
  }
}

function clearAll() {
  expression = "";
  justEvaluated = false;
  updateDisplay();
}

function deleteLast() {
  if (justEvaluated) {
    clearAll();
    return;
  }

  expression = expression.slice(0, -1);
  updateDisplay();
}

keys.addEventListener("click", (event) => {
  const button = event.target.closest("button");
  if (!button) return;

  const { value, action } = button.dataset;

  if (action === "clear") clearAll();
  if (action === "delete") deleteLast();
  if (action === "equals") calculate();
  if (value) appendValue(value);
});

window.addEventListener("keydown", (event) => {
  const keyMap = {
    Enter: "equals",
    "=": "equals",
    Backspace: "delete",
    Escape: "clear",
  };

  if (/^[0-9+\-*/%.]$/.test(event.key)) {
    event.preventDefault();
    appendValue(event.key);
    return;
  }

  const action = keyMap[event.key];
  if (!action) return;

  event.preventDefault();
  if (action === "equals") calculate();
  if (action === "delete") deleteLast();
  if (action === "clear") clearAll();
});

updateDisplay();
