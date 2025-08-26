// Loads external template + mirrors console.* output into it.

const TEMPLATE_URL = new URL("./consoleOutput.html", import.meta.url).href;
const CONSOLE_OUTPUT_CSS_HREF = new URL("./consoleOutput.css", import.meta.url)
  .href;
const ROOT_ID = "console-output";
const MSGS_ID = "console-messages";
const CLEAR_BTN_ID = "clear-console";
const ENABLE_DELETING_LOGS = "maximum-log";
const NUBMER_OF_LOGS = "max-log-size";

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
        const tpl = document.createElement("template");
        tpl.innerHTML = html.trim();
        if (anchorEl.childElementCount === 0) {
          anchorEl.insertAdjacentElement(
            "beforeend",
            tpl.content.firstElementChild as HTMLElement
          );
        } else {
          anchorEl.insertAdjacentElement(
            position,
            tpl.content.firstElementChild as HTMLElement
          );
        }
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
    originDiv.textContent = m.origin;
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
    const btn = document.getElementById(CLEAR_BTN_ID);
    if (btn && !btn.hasAttribute("data-wired")) {
      btn.addEventListener("click", () => this.clear());
      btn.setAttribute("data-wired", "1");
    }
  }

  private wireMaxLogsCheckbox() {
    this.clearLogsCheckBox = this.container?.querySelector(
      ENABLE_DELETING_LOGS
    ) as HTMLInputElement;
    if (!this.clearLogsCheckBox) return;

    this.clearLogsCheckBox.addEventListener("change", () => {
      this.clearLogs = (this.clearLogsCheckBox as HTMLInputElement)
        .checked as boolean;
      if (this.maxLogsInput) {
        // enable or disable maxloginput
        this.maxLogsInput.disabled = !this.clearLogs;
      }
    });
  }

  private wireMaxLogsInput() {
    this.maxLogsInput = this.container?.querySelector(
      NUBMER_OF_LOGS
    ) as HTMLInputElement;
    if (!this.maxLogsInput) return;

    this.maxLogsInput.addEventListener("change", () => {
      this.maxMessages = parseInt((this.maxLogsInput as HTMLInputElement).value);
    })
  }

  private handleScroll() {
    if (!this.container) return;
    const messagesContainer = this.container.querySelector("console-messages");
    if (!messagesContainer) return;
    const { scrollTop, scrollHeight, clientHeight } = messagesContainer;
    this.autoScroll =
      scrollTop + clientHeight + this.bottomThreshhold >= scrollHeight;
  }

  private captureOrigin(): string {
    const err = new Error();
    if (!err.stack) return "unknown";
    const stackLines = err.stack.split("\n").map((l) => l.trim());
    const originLine = stackLines[stackLines.length - 1];
    const match = originLine.match(/\(([^)]+)\)/);
    return match ? match[1] : "unknown";
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
