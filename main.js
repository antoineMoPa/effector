
customElements.define('effector-effector', class extends HTMLElement {
  constructor() {
    super();
    let player = new ShaderPlayerWebGL2();

    player.set_container(document.body);

    fetch("vertex_shader.glsl").then(
      (response) =>
        {response.text().then((text) => {
          player.set_vertex_shader(text);
        })});

    fetch("sketch.glsl").then(
      (response) =>
        {response.text().then((text) => {
          player.set_code(text);
        })});

    player.add_texture("foreground.png");
    player.add_texture("background.jpg");
    player.set_width(1398);
    player.set_height(1920);

    window.addEventListener("resize", this.onResizePage.bind(this));
    this.onResizePage();
    this.appendChild(player.canvas);
  }

  onResizePage(){
    this.style.display = "block";
    this.style.maxHeight = this.style.height = (window.innerHeight - 80) + "px";
  }
});
