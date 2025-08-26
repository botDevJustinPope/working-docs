"use strict";
// Loads external template + mirrors console.* output into it.
const TEMPLATE_URL = "components/consoleOutput/consoleOutput.html";
const CONSOLE_OUTPUT_CSS_HREF = "components/consoleOutput/consoleOutput.css";
const ROOT_ID = "console-output";
const MSGS_ID = "console-messages";
const CLEAR_BTN_ID = "clear-console";
class ConsoleOutput {
    constructor() {
        this.messages = [];
        this.container = null;
        this.maxMessages = 500;
        this.originals = {};
        this.attached = false;
    }
    static async mount(options = {}) {
        const { anchor, position = "beforeend", hookEarly = false, parentSelector, } = options;
        ensureStyles();
        const inst = new ConsoleOutput();
        if (hookEarly)
            inst.hookConsole(); // early capture
        // Resolve anchor
        let anchorEl = null;
        if (anchor instanceof HTMLElement)
            anchorEl = anchor;
        else if (typeof anchor === "string")
            anchorEl = document.querySelector(anchor);
        else if (parentSelector)
            anchorEl = document.querySelector(parentSelector);
        if (!anchorEl)
            anchorEl = document.body;
        if (!document.getElementById(ROOT_ID)) {
            try {
                const html = await fetchTemplate(TEMPLATE_URL);
                const tpl = document.createElement("template");
                tpl.innerHTML = html.trim();
                if (anchorEl.childElementCount === 0) {
                    anchorEl.insertAdjacentElement("beforeend", tpl.content.firstElementChild);
                }
                else {
                    anchorEl.insertAdjacentElement(position, tpl.content.firstElementChild);
                }
            }
            catch (e) {
                console.warn("[ConsoleOutput] Failed to load template:", e);
                return null;
            }
        }
        inst.attach(`#${MSGS_ID}`);
        window.consoleOutput = inst;
        return inst;
    }
    attach(containerSelector) {
        if (this.attached)
            return;
        this.container = document.querySelector(containerSelector);
        if (!this.container) {
            console.warn("[ConsoleOutput] Messages container not found:", containerSelector);
            return;
        }
        // Only hook if not already hooked (early)
        if (Object.keys(this.originals).length === 0) {
            this.hookConsole();
        }
        this.wireClearButton();
        this.attached = true;
        if (this.messages.length > 0) {
            this.render(true);
        }
    }
    hookConsole() {
        ["log", "info", "warn", "error"].forEach((m) => {
            if (this.originals[m])
                return; // avoid double hook / recursion
            this.originals[m] = console[m].bind(console);
            console[m] = (...args) => {
                this.originals[m]?.(...args);
                this.add(m, args);
            };
        });
    }
    add(level, args) {
        const entry = {
            id: crypto.randomUUID
                ? crypto.randomUUID()
                : Date.now() + "-" + Math.random(),
            level,
            text: this.formatArgs(args),
            timestamp: new Date(),
        };
        this.messages.push(entry);
        if (this.messages.length > this.maxMessages) {
            this.messages.splice(0, this.messages.length - this.maxMessages);
            this.render(true);
        }
        else {
            this.renderEntry(entry);
        }
    }
    clear() {
        this.messages = [];
        if (this.container)
            this.container.innerHTML = "";
    }
    formatArgs(args) {
        return args
            .map((a) => {
            if (typeof a === "string")
                return a;
            try {
                if (typeof a === "object")
                    return JSON.stringify(a, null, 2);
                return String(a);
            }
            catch {
                return String(a);
            }
        })
            .join(" ");
    }
    render(full = false) {
        if (!this.container)
            return;
        if (full)
            this.container.innerHTML = "";
        const list = full
            ? this.messages
            : [this.messages[this.messages.length - 1]];
        list.forEach((m) => this.renderEntry(m));
    }
    renderEntry(m) {
        if (!this.container)
            return;
        const div = document.createElement("div");
        div.className = `console-message level-${m.level}`;
        div.textContent = `[${m.timestamp.toLocaleTimeString()}] ${m.text}`;
        this.container.appendChild(div);
        this.container.scrollTop = this.container.scrollHeight;
    }
    wireClearButton() {
        const btn = document.getElementById(CLEAR_BTN_ID);
        if (btn && !btn.hasAttribute("data-wired")) {
            btn.addEventListener("click", () => this.clear());
            btn.setAttribute("data-wired", "1");
        }
    }
}
async function fetchTemplate(url) {
    const res = await fetch(url, { cache: "no-cache" });
    if (!res.ok)
        throw new Error(res.status + " " + res.statusText);
    return res.text();
}
function ensureStyles() {
    if (!document.querySelector("link[data-console-output-css]")) {
        const link = document.createElement("link");
        link.rel = "stylesheet";
        link.href = CONSOLE_OUTPUT_CSS_HREF;
        link.setAttribute("data-console-output-css", "true");
        document.head.appendChild(link);
    }
}
window.ConsoleOutput = ConsoleOutput;
