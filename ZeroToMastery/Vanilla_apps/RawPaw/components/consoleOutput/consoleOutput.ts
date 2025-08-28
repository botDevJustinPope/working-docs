// Loads external template + mirrors console.* output into it.

const TEMPLATE_URL = new URL("./consoleOutput.html", import.meta.url).href;
const CONSOLE_OUTPUT_CSS_HREF = new URL("./consoleOutput.css", import.meta.url)
  .href;
const ROOT_ID = "#console-output";
const MSGS_ID = "console-messages";
const HEADER = "#output-header";
const CLEAR_BTN_ID = "#clear-console";
const ENABLE_DELETING_LOGS = "#maximum-log";
const NUMBER_OF_LOGS = "#max-log-size";

type ConsoleMethod = "log" | "info" | "warn" | "error";

interface ConsoleMessage {
  id: string;
  level: ConsoleMethod;
  text: string;
  timestamp: Date;
  origin?: string;
}

class ConsoleOutput {
  private messages: ConsoleMessage[] = [];
  private headerContainer: HTMLElement | null = null;
  private container: HTMLElement | null = null;
  private originals: Partial<Record<ConsoleMethod, (...args: any[]) => void>> =
    {};
  private attached = false;
  private autoScroll = true;
  private bottomThreshhold = 8; //px tolerance
  private clearLogsCheckBox: HTMLInputElement | null = null;
  private clearLogs: boolean = false;
  private maxLogsInput: HTMLInputElement | null = null;
  private maxMessages = 500;
  private maxMessagesMin = 100;
  private maxMessagesMax = 10000;

  static async mount(
    options: {
      anchor?: string | HTMLElement;
      position?: InsertPosition;
      hookEarly?: boolean;
      parentSelector?: string;
    } = {}
  ) {
    const {
      anchor,
      position = "beforeend",
      hookEarly = false,
      parentSelector,
    } = options;

    ensureStyles();

    const inst = new ConsoleOutput();
    if (hookEarly) inst.hookConsole(); // early capture

    // Resolve anchor
    let anchorEl: HTMLElement | null = null;
    if (anchor instanceof HTMLElement) anchorEl = anchor;
    else if (typeof anchor === "string")
      anchorEl = document.querySelector(anchor);
    else if (parentSelector) anchorEl = document.querySelector(parentSelector);
    if (!anchorEl) anchorEl = document.body;

    if (!anchorEl.querySelector("#console-output")) {
      const html = await fetchTemplate(TEMPLATE_URL);
      anchorEl.insertAdjacentHTML("beforeend", html);
    }

    if (!document.getElementById(ROOT_ID)) {
      try {
        const html = await fetchTemplate(TEMPLATE_URL);
          anchorEl.insertAdjacentHTML(
            position,
            html.trim()
          );
      } catch (e) {
        console.warn("[ConsoleOutput] Failed to load template:", e);
        return null;
      }
    }

    inst.attach(`#${MSGS_ID}`);
    (window as any).consoleOutput = inst;
    return inst;
  }

  private attach(containerSelector: string) {
    if (this.attached) return;
    this.headerContainer = document.querySelector(HEADER);
    this.container = document.querySelector(containerSelector);
    if (!this.container) {
      console.warn(
        "[ConsoleOutput] Messages container not found:",
        containerSelector
      );
      return;
    }
    // Only hook if not already hooked (early)
    if (Object.keys(this.originals).length === 0) {
      this.hookConsole();
    }
    this.wireComponent();
    this.container.addEventListener("scroll", () => this.handleScroll());
    this.attached = true;

    if (this.messages.length > 0) {
      this.render(true);
    }
  }

  private hookConsole() {
    (["log", "info", "warn", "error"] as ConsoleMethod[]).forEach((m) => {
      if (this.originals[m]) return; // avoid double hook / recursion
      this.originals[m] = console[m].bind(console);
      (console as any)[m] = (...args: any[]) => {
        this.originals[m]?.(...args);
        const origin = this.captureOrigin();
        this.add(m, args, origin);
      };
    });
  }

  private add(level: ConsoleMethod, args: any[], origin?: string) {
    const entry: ConsoleMessage = {
      id: (crypto as any).randomUUID
        ? (crypto as any).randomUUID()
        : Date.now() + "-" + Math.random(),
      level,
      text: this.formatArgs(args),
      timestamp: new Date(),
      origin
    };
    this.messages.push(entry);
    if (this.messages.length > this.maxMessages && this.clearLogs) {
      this.messages.splice(0, this.messages.length - this.maxMessages);
      this.render(true);
    } else {
      this.renderEntry(entry);
    }
  }

  private clear() {
    this.messages = [];
    if (this.container) this.container.innerHTML = "";
    this.autoScroll = true;
  }

  private formatArgs(args: any[]) {
    return args
      .map((a) => {
        if (typeof a === "string") return a;
        try {
          if (typeof a === "object") return JSON.stringify(a, null, 2);
          return String(a);
        } catch {
          return String(a);
        }
      })
      .join(" ");
  }

  private render(full = false) {
    if (!this.container) return;
    if (full) this.container.innerHTML = "";
    const list = full
      ? this.messages
      : [this.messages[this.messages.length - 1]];
    list.forEach((m) => this.renderEntry(m));
  }

  private renderEntry(m: ConsoleMessage) {
    if (!this.container) return;
    const div = document.createElement("div");
    div.className = `console-message level-${m.level}`;
    const timeDiv = document.createElement("div");
    timeDiv.className = "console-message-time";
    timeDiv.textContent = `[${m.timestamp.toLocaleTimeString()}]`;
    div.appendChild(timeDiv);
    const messageDiv = document.createElement("div");
    messageDiv.className = "console-message-text";
    messageDiv.textContent = m.text;
    div.appendChild(messageDiv);
    const originDiv = document.createElement("div");
    originDiv.className = "console-message-origin";
    originDiv.textContent = m.origin ? m.origin : "unknown";
    div.appendChild(originDiv);
    this.container.appendChild(div);
    if (this.autoScroll) {
      this.container.scrollTop = this.container.scrollHeight;
    }
  }

  private wireComponent() {
    this.wireClearButton();
    this.wireMaxLogsCheckbox();
    this.wireMaxLogsInput();
  }

  private wireClearButton() {
    const btn = this.headerContainer?.querySelector(CLEAR_BTN_ID);
    if (btn && !btn.hasAttribute("data-wired")) {
      btn.addEventListener("click", () => this.clear());
      btn.setAttribute("data-wired", "1");
    }
  }

  private wireMaxLogsCheckbox() {
    this.clearLogsCheckBox = this.headerContainer?.querySelector(
      ENABLE_DELETING_LOGS
    ) as HTMLInputElement;

    if (!this.clearLogsCheckBox || this.clearLogsCheckBox.hasAttribute("data-wired")) return;

    this.clearLogsCheckBox.addEventListener("input", () => {
      this.clearLogs = (this.clearLogsCheckBox as HTMLInputElement).checked;
      if (this.maxLogsInput) {
        // enable or disable maxloginput
        this.maxLogsInput.disabled = !this.clearLogs;
      }
    });
    this.clearLogsCheckBox.setAttribute("data-wired", "1");
  }

  private wireMaxLogsInput() {
    this.maxLogsInput = this.headerContainer?.querySelector(
      NUMBER_OF_LOGS
    ) as HTMLInputElement;
    if (!this.maxLogsInput || this.maxLogsInput.hasAttribute("data-wired")) return;

    this.maxLogsInput.addEventListener("change", () => {
      this.maxMessages = parseInt((this.maxLogsInput as HTMLInputElement).value);
      if (this.maxMessages < this.maxMessagesMin) {
        this.maxMessages = this.maxMessagesMin;
      } else if (this.maxMessages > this.maxMessagesMax) {
        this.maxMessages = this.maxMessagesMax;
      }
      (this.maxLogsInput as HTMLInputElement).value = String(this.maxMessages);
    });
    this.maxLogsInput.setAttribute("data-wired", "1");
  }

  private handleScroll() {
    if (!this.container) return;
    const { scrollTop, scrollHeight, clientHeight } = this.container;
    this.autoScroll =
      scrollTop + clientHeight + this.bottomThreshhold >= scrollHeight;
  }

  private captureOrigin(): string {
    const err = new Error();
    if (!err.stack) return "unknown";

    const selfHint = /consoleOutput/i;
    const lines = err.stack
      .split("\n")
      .map(l => l.trim())
      .filter(l => l && !l.startsWith("Error"));

    for (const ln of lines) {
      // Skip frames from this file / internal eval
      if (selfHint.test(ln)) continue;

      // Chrome / Edge style: at func (http://host/path/file.ts:line:col)
      let match = ln.match(/\((.*?):(\d+):(\d+)\)/);
      // Firefox style: func@http://host/path/file.ts:line:col
      if (!match) match = ln.match(/@(.*?):(\d+):(\d+)/);
      // Bare style: at http://host/path/file.ts:line:col
      if (!match) match = ln.match(/\s(at\s)?(.*?):(\d+):(\d+)/);

      if (match) {
        // match forms vary; normalize
        // Chrome/Firefox grouped: fullPath line col at indices end-2, end-1
        const parts = match.slice(1);
        // Extract last three numeric groups as line/col
        const nums = parts.filter(p => /^\d+$/.test(p));
        if (nums.length >= 2) {
          const line = nums[nums.length - 2];
            const col = nums[nums.length - 1];
          // Find the path candidate (first non-numeric part containing / or \ )
          const pathCandidate =
            parts.find(p => /[\\/]/.test(p)) ||
            parts[0];
          // Remove query/hash
          const clean = pathCandidate.split(/[?#]/)[0];
          const file = clean.split(/[\\/]/).pop() || clean;
          return `${file}:${line}:${col}`;
        }
      }
    }
    return "unknown";
  }
}

async function fetchTemplate(url: string): Promise<string> {
  const res = await fetch(url, { cache: "no-cache" });
  if (!res.ok) throw new Error(res.status + " " + res.statusText);
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

(window as any).ConsoleOutput = ConsoleOutput;
