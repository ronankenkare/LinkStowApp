(() => {
  const dark = window.matchMedia("(prefers-color-scheme: dark)").matches;
  const palette = dark
    ? {
        background: "#15131a",
        surface: "#25222d",
        surfaceAlt: "#172f49",
        surfaceGood: "#17351f",
        surfaceWarn: "#452819",
        surfaceDanger: "#41201f",
        text: "#f4f1f8",
        muted: "#aaa5b7",
        line: "#68788a",
        blue: "#409eff",
        green: "#64c466",
        yellow: "#fbc02d",
        red: "#ff5a50"
      }
    : {
        background: "#ffffff",
        surface: "#f4f7fb",
        surfaceAlt: "#e5f2ff",
        surfaceGood: "#eaf7eb",
        surfaceWarn: "#fff6da",
        surfaceDanger: "#ffeceb",
        text: "#24222b",
        muted: "#667085",
        line: "#8190a2",
        blue: "#0a84ff",
        green: "#3ca34a",
        yellow: "#c89200",
        red: "#d92d25"
      };

  const showFallback = () => {
    document.querySelectorAll(".mermaid").forEach((diagram) => {
      diagram.classList.add("diagram-error");
      diagram.textContent = "The diagram renderer could not load. The surrounding explanation remains available.";
    });
  };

  const initializeDiagramViewer = () => {
    const stages = Array.from(document.querySelectorAll(".mermaid-stage"));
    if (stages.length === 0) return;

    const dialog = document.createElement("dialog");
    dialog.className = "diagram-dialog";
    dialog.setAttribute("aria-labelledby", "diagram-dialog-title");
    dialog.innerHTML = `
      <div class="diagram-dialog-shell">
        <header class="diagram-dialog-header">
          <div>
            <span class="diagram-dialog-kicker">Expanded system view</span>
            <h2 id="diagram-dialog-title">System diagram</h2>
          </div>
          <button class="diagram-button diagram-close" type="button">Close</button>
        </header>
        <div class="diagram-toolbar">
          <span>Scroll to zoom · drag to pan · arrow keys to move</span>
          <div class="diagram-toolbar-controls" aria-label="Diagram zoom controls">
            <button class="diagram-button diagram-zoom-out" type="button" aria-label="Zoom out">−</button>
            <output class="diagram-zoom-value" aria-live="polite">100%</output>
            <button class="diagram-button diagram-zoom-in" type="button" aria-label="Zoom in">+</button>
            <button class="diagram-button diagram-reset" type="button">Reset</button>
          </div>
        </div>
        <div class="diagram-dialog-content">
          <div class="diagram-viewport" role="region" aria-label="Pannable and zoomable diagram">
            <div class="diagram-canvas"></div>
          </div>
        </div>
      </div>
    `;
    document.body.append(dialog);

    const title = dialog.querySelector("#diagram-dialog-title");
    const closeButton = dialog.querySelector(".diagram-close");
    const zoomOutButton = dialog.querySelector(".diagram-zoom-out");
    const zoomInButton = dialog.querySelector(".diagram-zoom-in");
    const resetButton = dialog.querySelector(".diagram-reset");
    const zoomValue = dialog.querySelector(".diagram-zoom-value");
    const viewport = dialog.querySelector(".diagram-viewport");
    const canvas = dialog.querySelector(".diagram-canvas");

    let sourceParent = null;
    let sourceNextSibling = null;
    let activeSvg = null;
    let activeTrigger = null;
    let scale = 1;
    let offsetX = 0;
    let offsetY = 0;
    let dragging = false;
    let pointerX = 0;
    let pointerY = 0;

    const clamp = (value, minimum, maximum) => Math.min(Math.max(value, minimum), maximum);

    const applyTransform = () => {
      canvas.style.transform = `translate(${offsetX}px, ${offsetY}px) scale(${scale})`;
      zoomValue.textContent = `${Math.round(scale * 100)}%`;
    };

    const resetView = () => {
      scale = 1;
      offsetX = 0;
      offsetY = 0;
      applyTransform();
    };

    const zoomBy = (amount) => {
      scale = clamp(scale + amount, 0.5, 3);
      applyTransform();
    };

    const restoreDiagram = () => {
      if (activeSvg && sourceParent) {
        if (sourceNextSibling && sourceNextSibling.parentNode === sourceParent) {
          sourceParent.insertBefore(activeSvg, sourceNextSibling);
        } else {
          sourceParent.append(activeSvg);
        }
      }

      activeSvg = null;
      sourceParent = null;
      sourceNextSibling = null;
      canvas.replaceChildren();
      resetView();
      activeTrigger?.focus();
      activeTrigger = null;
    };

    const openDiagram = (stage, trigger) => {
      const svg = stage.querySelector("svg");
      if (!svg) return;

      const section = stage.closest("section");
      title.textContent = section?.querySelector("h2")?.textContent?.trim() || "System diagram";

      sourceParent = svg.parentNode;
      sourceNextSibling = svg.nextSibling;
      activeSvg = svg;
      activeTrigger = trigger;
      canvas.replaceChildren(svg);
      resetView();
      dialog.showModal();
    };

    stages.forEach((stage) => {
      if (!stage.querySelector("svg")) return;
      const row = document.createElement("div");
      row.className = "diagram-expand-row";
      const button = document.createElement("button");
      button.className = "diagram-button";
      button.type = "button";
      button.textContent = "Expand diagram ↗";
      button.addEventListener("click", () => openDiagram(stage, button));
      row.append(button);
      stage.prepend(row);
    });

    closeButton.addEventListener("click", () => dialog.close());
    zoomOutButton.addEventListener("click", () => zoomBy(-0.2));
    zoomInButton.addEventListener("click", () => zoomBy(0.2));
    resetButton.addEventListener("click", resetView);

    dialog.addEventListener("click", (event) => {
      if (event.target === dialog) dialog.close();
    });

    dialog.addEventListener("close", restoreDiagram);

    viewport.addEventListener("wheel", (event) => {
      event.preventDefault();
      zoomBy(event.deltaY < 0 ? 0.12 : -0.12);
    }, { passive: false });

    viewport.addEventListener("pointerdown", (event) => {
      if (event.button !== 0) return;
      dragging = true;
      pointerX = event.clientX;
      pointerY = event.clientY;
      viewport.classList.add("is-dragging");
      viewport.setPointerCapture(event.pointerId);
    });

    viewport.addEventListener("pointermove", (event) => {
      if (!dragging) return;
      offsetX += event.clientX - pointerX;
      offsetY += event.clientY - pointerY;
      pointerX = event.clientX;
      pointerY = event.clientY;
      applyTransform();
    });

    const stopDragging = (event) => {
      if (!dragging) return;
      dragging = false;
      viewport.classList.remove("is-dragging");
      if (viewport.hasPointerCapture(event.pointerId)) {
        viewport.releasePointerCapture(event.pointerId);
      }
    };

    viewport.addEventListener("pointerup", stopDragging);
    viewport.addEventListener("pointercancel", stopDragging);

    document.addEventListener("keydown", (event) => {
      if (!dialog.open) return;
      const step = event.shiftKey ? 60 : 24;
      if (event.key === "ArrowLeft") offsetX -= step;
      else if (event.key === "ArrowRight") offsetX += step;
      else if (event.key === "ArrowUp") offsetY -= step;
      else if (event.key === "ArrowDown") offsetY += step;
      else return;
      event.preventDefault();
      applyTransform();
    });
  };

  const render = async () => {
    if (typeof mermaid === "undefined") {
      showFallback();
      return;
    }

    mermaid.initialize({
      startOnLoad: false,
      securityLevel: "strict",
      theme: "base",
      themeVariables: {
        background: palette.background,
        primaryColor: palette.surfaceAlt,
        primaryTextColor: palette.text,
        primaryBorderColor: palette.blue,
        secondaryColor: palette.surface,
        secondaryTextColor: palette.text,
        secondaryBorderColor: palette.line,
        tertiaryColor: palette.surfaceGood,
        tertiaryTextColor: palette.text,
        tertiaryBorderColor: palette.green,
        lineColor: palette.line,
        textColor: palette.text,
        mainBkg: palette.surface,
        nodeBorder: palette.line,
        clusterBkg: palette.background,
        clusterBorder: palette.line,
        edgeLabelBackground: palette.background,
        actorBkg: palette.surface,
        actorBorder: palette.line,
        actorTextColor: palette.text,
        actorLineColor: palette.line,
        signalColor: palette.blue,
        signalTextColor: palette.text,
        labelBoxBkgColor: palette.surface,
        labelBoxBorderColor: palette.line,
        labelTextColor: palette.text,
        loopTextColor: palette.text,
        noteBkgColor: palette.surfaceAlt,
        noteBorderColor: palette.blue,
        noteTextColor: palette.text,
        fontFamily: '-apple-system, BlinkMacSystemFont, "SF Pro Display", system-ui, sans-serif',
        fontSize: "14px"
      },
      flowchart: {
        curve: "basis",
        htmlLabels: true,
        useMaxWidth: true,
        nodeSpacing: 34,
        rankSpacing: 44
      },
      sequence: {
        useMaxWidth: true,
        mirrorActors: false,
        messageAlign: "center",
        diagramMarginX: 12,
        diagramMarginY: 12,
        actorMargin: 28,
        width: 145,
        height: 48,
        boxMargin: 10,
        noteMargin: 12,
        messageMargin: 25
      },
      class: {
        useMaxWidth: true
      },
      state: {
        useMaxWidth: true
      }
    });

    try {
      await mermaid.run({ querySelector: ".mermaid" });
      initializeDiagramViewer();
    } catch {
      showFallback();
    }
  };

  if (document.readyState === "loading") {
    window.addEventListener("DOMContentLoaded", render, { once: true });
  } else {
    render();
  }
})();
