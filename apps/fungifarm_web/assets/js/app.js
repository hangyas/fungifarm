// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"


import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

window.LiveScripts = {};

let Hooks = {}

/**
 * when the element has beend updated with a script tag
 * execute it -> show the chart
 * and mark the element phx-update=ignore -> don't break it with future updates
 *    (it probably could be updated if the script is re-run but now it's unnecessary)
 */
Hooks.Chart = {
  updated() {
    if (!window.LiveScripts[this.el.id]) {
      let script = this.el.querySelector('script')
      if (script) {
        this.el.setAttribute('phx-update', 'ignore')
        script = script.innerHTML
        window.LiveScripts[this.el.id] = script
        eval(script)
      }
    }
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks});
liveSocket.connect()
