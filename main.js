customElements.define('effector-settings-panel', class extends HTMLElement {
  constructor() {
    super();

    this.innerHTML = `
      <div>
         <label>Scale
           <input name="scale" type="range" min="0.1" max="1" step="0.01" value="0.5">
         </label>
         <label>Vignette
           <input name="vignette" type="range" min="0.1" max="1" step="0.01" value="0.5">
         </label>
         <label>Distort
           <input name="distort" type="range" min="0.1" max="1" step="0.01" value="0.5">
         </label>
         <label>Noise
           <input name="noise" type="range" min="0.1" max="1" step="0.01" value="0.5">
         </label>
         <label>Noise Frequency
           <input name="noise_frequency" type="range" min="0.1" max="1" step="0.01" value="0.5">
         </label>
         <label>Fade
           <input name="fade" type="range" min="0.1" max="1" step="0.01" value="0.1">
         </label>
      </div>`;

    this.addStyle();

    let scaleInput = this.querySelectorAll("input[name=scale]")[0];
    this.addEventListener("input", this.onChange.bind(this));
  }

  onChange() {
    this.dispatchEvent(new CustomEvent('state-change', { detail: this.getState() } ));
  }

  getState() {
    let state = {};

    this.querySelectorAll("input").forEach(function (input) {
      state[input.getAttribute("name")] = input.value;
    });

    return state;
  }

  setState(state) {
    for (let i in state)
      this.querySelectorAll("input[name="+i+"]")[0].value = state[i];
  }

  addStyle() {
    let style = document.createElement("style");
    style.innerHTML = `
      effector-settings-panel {
        position: absolute;
        top: 40px;
        right: 40px;
        background: #fff;
        border-radius: 3px;
        width: 400px;
        height: calc(100% - 160px);
        padding: 40px;
        opacity: 0;
        transition: all 0.3s;
      }

      effector-settings-panel:hover {
        opacity: 1;
      }

      input {
        width: 100%;
      }

      effector-settings-panel label {
        font-weight: 300;
      }
    `;
    document.head.appendChild(style);
  }
});


customElements.define('effector-effector', class extends HTMLElement {
  constructor() {
    super();
    let player = new ShaderPlayerWebGL2();

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

    this.player = player;

    window.addEventListener("resize", this.onResizePage.bind(this));

    this.onResizePage();
    this.appendChild(player.canvas);

    this.errorContainer = document.createElement("div");
    this.errorContainer.classList.add("error-container");
    this.appendChild(this.errorContainer);

    player.set_on_error_listener(this.onError.bind(this));

    this.insertAdjacentHTML("beforeend", "<effector-settings-panel></effector-settings-panel>");

    let settingsPanel = this.querySelectorAll("effector-settings-panel")[0];

    settingsPanel.addEventListener("state-change", function(e) {
      this.onStateChange(e.detail);
    }.bind(this));


    let lastState = settingsPanel.getState();
    if (window.localStorage.lastState != undefined)
      lastState = JSON.parse(window.localStorage.lastState);

    settingsPanel.setState(lastState);

    let sketch = "sketch.glsl";
    if (window.location.hash != "")
      sketch = window.location.hash.replace(/^#/, "");

    (async function () {
      let response = await fetch(sketch);
      let text = await response.text();
      player.set_code(text);
      this.onStateChange(lastState);
    }.bind(this))();

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
