import * as readline from "readline";

console.log("Informix local app started. Press any key to exit...");

// Enable raw mode so we detect a single keypress
if (process.stdin.isTTY) {
  process.stdin.setRawMode(true);
}

process.stdin.resume();
process.stdin.setEncoding("utf8");

let running = true;

process.stdin.on("data", () => {
  running = false;
  console.log("\nKey pressed. Exiting...");
  process.exit(0);
});

// Simple loop that keeps the process alive
function loop(): void {
  if (!running) return;
  // Heartbeat so you can see it is running
  process.stdout.write(".");
  setTimeout(loop, 1000);
}

loop();
