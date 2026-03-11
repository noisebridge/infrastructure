// Click on "Connect New Device"
document.querySelectorAll('button')[1].click();

// Wait for dialog (dumb)
var existCondition = setInterval(function () {
  if (document.querySelectorAll('button')[7] != null) {
    // Clear the timer
    clearInterval(existCondition);

    // Enter the IP address
    document.querySelectorAll('input')[0].value = "10.21.0.123";

    // Click on "Connect"
    console.log("Automatically connecting...");
    document.querySelectorAll('button')[7].click();
  }
}, 100); // Check every 100ms

