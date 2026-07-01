#!/usr/bin/env node
// Generates one self-contained HTML slide per scene in scenes.json.
// No dependencies — plain Node + a shared inline stylesheet.

const fs = require("fs");
const path = require("path");

const SCENES_PATH = path.join(__dirname, "scenes.json");
const OUT_DIR = path.join(__dirname, "slides");
const scenes = JSON.parse(fs.readFileSync(SCENES_PATH, "utf8"));

fs.mkdirSync(OUT_DIR, { recursive: true });

function esc(s) {
  return String(s)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

const BASE_CSS = `
  * { box-sizing: border-box; }
  html, body {
    margin: 0; padding: 0; width: 1920px; height: 1080px;
    background: radial-gradient(circle at 20% 15%, #2a1f3d 0%, #14101f 55%, #0b0910 100%);
    font-family: 'DejaVu Sans', Arial, sans-serif;
    color: #f1ecf7;
    overflow: hidden;
  }
  .frame { width: 1920px; height: 1080px; display: flex; flex-direction: column; padding: 90px 140px; }
  .badge {
    display: inline-flex; align-items: center; gap: 16px;
    font-size: 30px; letter-spacing: 2px; color: #b79bea; text-transform: uppercase;
    margin-bottom: 30px; font-weight: 700;
  }
  .dot { width: 16px; height: 16px; border-radius: 50%; background: linear-gradient(135deg,#8b5cf6,#d97757); display: inline-block; }
  h1 { font-size: 74px; margin: 0 0 12px 0; font-weight: 800; line-height: 1.1;
       background: linear-gradient(90deg,#f1ecf7,#c9b6ef); -webkit-background-clip: text; background-clip: text; color: transparent; }
  .subtitle { font-size: 40px; color: #b79bea; margin-bottom: 50px; font-weight: 500; }
  .content { flex: 1; display: flex; flex-direction: column; justify-content: center; }
  ul.bullets { list-style: none; padding: 0; margin: 0; }
  ul.bullets li {
    font-size: 44px; padding: 22px 0 22px 70px; position: relative; border-bottom: 1px solid rgba(255,255,255,0.08);
  }
  ul.bullets li::before {
    content: ""; position: absolute; left: 0; top: 38px; width: 26px; height: 26px; border-radius: 8px;
    background: linear-gradient(135deg,#8b5cf6,#d97757);
  }
  .tree { font-family: 'DejaVu Sans Mono', monospace; font-size: 46px; line-height: 1.65; color: #e4d9f7; }
  .tree .line::before { content: "\\1F4C1  "; }
  pre.code {
    font-family: 'DejaVu Sans Mono', monospace; font-size: 34px; line-height: 1.55;
    background: #1a1424; border: 1px solid #4b3a6b; border-radius: 18px; padding: 46px 54px;
    color: #d9c9ff; white-space: pre-wrap; box-shadow: 0 20px 60px rgba(0,0,0,0.35);
  }
  .twocol { display: flex; gap: 60px; }
  .card { flex: 1; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.12);
          border-radius: 24px; padding: 50px 54px; }
  .card h2 { font-size: 42px; margin: 0 0 20px 0; color: #d97757; }
  .card p { font-size: 32px; line-height: 1.6; white-space: pre-line; color: #e4d9f7; margin: 0; }
  .prompts { display: flex; flex-direction: column; gap: 34px; }
  .prompt { font-size: 38px; background: rgba(139,92,246,0.12); border-left: 8px solid #8b5cf6;
            border-radius: 10px; padding: 26px 40px; font-style: italic; color: #f1ecf7; }
  .footer { margin-top: 40px; font-size: 28px; color: #7c6a95; }
`;

function frameOpen(scene, badge) {
  return `<div class="frame">
    <div class="badge"><span class="dot"></span>${esc(badge)}</div>
    <h1>${esc(scene.title)}</h1>`;
}

function renderScene(scene) {
  let body = "";
  switch (scene.kind) {
    case "title":
      body = `
        <div class="content" style="align-items:center; text-align:center;">
          <h1 style="font-size:92px;">${esc(scene.title)}</h1>
          <div class="subtitle">${esc(scene.subtitle)}</div>
        </div>`;
      return `<!DOCTYPE html><html><head><meta charset="utf-8"><style>${BASE_CSS}</style></head><body>
        <div class="frame" style="justify-content:center;">
          <div class="badge" style="align-self:center;"><span class="dot"></span>ClaudeTio</div>
          ${body}
        </div>
      </body></html>`;
    case "bullets":
      body = `<div class="content"><ul class="bullets">${scene.items.map(i => `<li>${esc(i)}</li>`).join("")}</ul></div>`;
      break;
    case "tree":
      body = `<div class="content"><div class="tree">${scene.tree.map(t => `<div class="line">${esc(t)}</div>`).join("")}</div></div>`;
      break;
    case "code":
      body = `<div class="content"><pre class="code">${esc(scene.code)}</pre></div>`;
      break;
    case "twocol":
      body = `<div class="content"><div class="twocol">
        <div class="card"><h2>${esc(scene.colA_title)}</h2><p>${esc(scene.colA_body)}</p></div>
        <div class="card"><h2>${esc(scene.colB_title)}</h2><p>${esc(scene.colB_body)}</p></div>
      </div></div>`;
      break;
    case "prompts":
      body = `<div class="content"><div class="prompts">${scene.items.map(i => `<div class="prompt">"${esc(i)}"</div>`).join("")}</div></div>`;
      break;
    case "outro":
      body = `<div class="content" style="align-items:center; text-align:center;">
        <div class="subtitle">${esc(scene.subtitle)}</div>
        <ul class="bullets" style="text-align:left; max-width:1100px; margin-top:30px;">${scene.items.map(i => `<li>${esc(i)}</li>`).join("")}</ul>
      </div>`;
      break;
    default:
      body = "";
  }

  return `<!DOCTYPE html><html><head><meta charset="utf-8"><style>${BASE_CSS}</style></head><body>
    ${frameOpen(scene, "ClaudeTio")}
    ${body}
    <div class="footer">Obsidian as a Second Brain for Claude — docs/video-script.md</div>
  </body></html>`;
}

for (const scene of scenes) {
  const html = renderScene(scene);
  const outPath = path.join(OUT_DIR, `${scene.id}.html`);
  fs.writeFileSync(outPath, html, "utf8");
  console.log("wrote", outPath);
}
