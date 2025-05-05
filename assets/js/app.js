// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Define hooks
const Hooks = {}

// Hook to handle redirection to cookie setting endpoint
Hooks.AnonymousCookie = {
  mounted() {
    this.handleEvent("set-anonymous-cookie", (data) => {
      if (data.set_anonymous_cookie && data.anonymous_uuid) {
        // Store the UUID in localStorage as a fallback
        localStorage.setItem('anonymous_uuid', data.anonymous_uuid);

        // Redirect to the cookie-setting endpoint which will set the signed cookie
        // and then redirect back to the current page
        const currentPath = window.location.pathname;
        window.location.href = `/set-anonymous-cookie?uuid=${data.anonymous_uuid}&return_to=${encodeURIComponent(currentPath)}`;
      }
    });
  }
}

Hooks.LocalTime = {
  mounted() {
    this.updated()
  },
  updated() {
    const dateString = this.el.textContent.trim();
    console.log("🚀 ~ updated ~ dateString:", dateString)
    const date = new Date(dateString);
    this.el.textContent =
      date.toLocaleString() +
      " " +
      Intl.DateTimeFormat().resolvedOptions().timeZone;
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken }
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Theme toggle functionality
const initializeTheme = () => {
  // Check for saved theme preference or respect OS preference
  const savedTheme = localStorage.getItem("theme");
  const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
  const html = document.documentElement;

  // Set initial theme
  if (savedTheme === "dark" || (!savedTheme && prefersDark)) {
    html.classList.add("dark");
  } else {
    html.classList.remove("dark");
  }
};

// Initialize theme on page load
initializeTheme();

// Add click event to theme toggle button and handle theme changes
window.addEventListener("phx:page-loading-stop", () => {
  const themeToggleBtn = document.getElementById("theme-toggle");
  if (themeToggleBtn) {
    themeToggleBtn.addEventListener("click", () => {
      // Toggle dark class on html element
      const html = document.documentElement;
      html.classList.toggle("dark");

      // Save preference to localStorage
      const isDark = html.classList.contains("dark");
      localStorage.setItem("theme", isDark ? "dark" : "light");
    });
  }
});

// Listen for OS theme changes
window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", (e) => {
  if (!localStorage.getItem("theme")) {
    const html = document.documentElement;
    if (e.matches) {
      html.classList.add("dark");
    } else {
      html.classList.remove("dark");
    }
  }
});

