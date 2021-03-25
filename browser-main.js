customElements.define('effector-settings-panel', class extends HTMLElement {
  constructor() {
    super();
    this.code = "";

    this.render();

    this.addEventListener("input", this.onChange.bind(this));
  }

  render() {
    let uniformsLines = this.code.split("\n").filter((l) => l.indexOf("custom_uniform") > 0);
    let uniforms = uniformsLines.map((l) => JSON.parse(l.split("// custom_uniform")[1]));

    let uniformsDom = "";

    uniforms.forEach((u) => {
      let defaultValue = u.defaultValue || 0.5;
      let value_min = u.min || 0.0;
      let value_max = u.max || 1.0;
      let step = u.step || 0.01;
      let name = u.name || "-";
      let humanName = u.humanName || name;

      uniformsDom += `
         <label>${humanName}
           <input name="${name}" type="range" min="${value_min}" max="${value_max}"
                  step="${step}" value="${defaultValue}">
         </label>`;
    });

    this.innerHTML = `<div>
                         <label>Scale
                           <input name="scale" type="range" min="0.1" max="1" step="0.01" value="0.5">
                         </label>
                         ${uniformsDom}
                      </div>`;

    this.onChange();
  }

  onChange() {
    this.dispatchEvent(new CustomEvent('state-change', { detail: this.getState() } ));
  }

  getState() {
    let state = {};

    this.querySelectorAll("input").forEach(function (input) {
      let name = input.getAttribute("name");
      state[name] = input.value;
    });

    return state;
  }

  setState(state) {
    for(let i in state) {
      let foundInput = this.querySelectorAll("input[name="+i+"]");
      if (foundInput.length > 0)
        foundInput[0].value = state[i];
    }
  }

  setCode(code) {
    this.code = code;
    this.render();
  }

});

customElements.define('effector-sketch-list', class extends HTMLElement {
  constructor() {
    super();
    this.render();
  }

  getFiles () {
    // Electron
    let glob = require("glob");
    return new Promise(function (resolve, reject) {
      glob("sketches/*.glsl", function (err, files) {
        if (err != null) {
          reject(err)
        } else {
          resolve(files);
          console.log(files);
        }
      });
    });
  }

  async render() {
    let files = await this.getFiles();

    let filesDom = "";

    files.forEach(function (f) {
      filesDom += `<a href="#${f}">
                     ${f.replace(/sketches\/|\.glsl/g,"")}
                   </a>
                   <br/>`;
    });

    this.innerHTML += `<div>${filesDom}</div>`;
  }
});

customElements.define('effector-effector', class extends HTMLElement {
  constructor() {
    super();
    let player = new ShaderPlayerWebGL2();
    this.player = player;

    fetch("vertex_shader.glsl").then(
      (response) =>
        {response.text().then((text) => {
          player.set_vertex_shader(text);
        })});

    this.scale = 0.4;

    // 8x8 @ 300dpi
    this.baseWidth = 2400;
    this.baseHeight = 2400;

    this.baseWidth = 1398;
    this.baseHeight = 1920;
    // 18x24 @ 300dpi
    // this.baseWidth = 4500 * this.scale;
    // this.baseHeight = 6000 * this.scale;

    this.imageWidth = this.baseWidth * this.scale;
    this.imageHeight = this.baseHeight * this.scale;

    player.add_texture("foreground.png");
    player.add_texture("background.jpg");
    player.set_width(this.imageWidth);
    player.set_height(this.imageHeight);

    window.addEventListener("resize", this.onResizePage.bind(this));

    this.onResizePage();
    this.appendChild(player.canvas);

    this.errorContainer = document.createElement("div");
    this.errorContainer.classList.add("error-container");
    this.appendChild(this.errorContainer);

    player.set_on_error_listener(this.onError.bind(this));

    this.insertAdjacentHTML("beforeend", `
       <effector-sketch-list class="transparent-box">
       </effector-sketch-list>
       <effector-settings-panel class="transparent-box">
       </effector-settings-panel>
    `);

    this.settingsPanel = this.querySelectorAll("effector-settings-panel")[0];

    this.settingsPanel.addEventListener("state-change", function(e) {
      this.onStateChange(e.detail);
    }.bind(this));

    this.lastState = this.settingsPanel.getState();
    if (window.localStorage.lastState != undefined)
      this.lastState = JSON.parse(window.localStorage.lastState);

    this.loadCode();
    window.addEventListener("hashchange", this.loadCode.bind(this));
  }

  async loadCode() {
    let sketch = "sketch.glsl";

    if (window.location.hash != "")
      sketch = window.location.hash.replace(/^#/, "");

    let response = await fetch(sketch);
    let code = await response.text();
    this.player.set_code(code);
    this.onStateChange(this.lastState);
    this.settingsPanel.setState(this.lastState);
    this.settingsPanel.setCode(code);
  }

  onStateChange(state) {
    const player = this.player;
    if (this.scale != state.scale)
      player.set_size(this.baseWidth * state.scale, this.baseHeight * state.scale);
    this.scale = state.scale;

    for (let i in state)
      player.set_float_uniform(i, state[i]);

    window.localStorage.lastState = JSON.stringify(state);
  }

  onResizePage() {
    this.style.display = "block";
    let newHeight = window.innerHeight - 80;
    this.style.maxHeight = newHeight + "px";
    this.style.height = newHeight + "px";
    //this.player.set_height(newHeight);
    //this.player.set_width(newHeight * this.imageWidth / this.imageHeight);
  }

  onError(err) {
    this.errorContainer.innerText = err;
  }
});
