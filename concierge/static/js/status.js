document.addEventListener("DOMContentLoaded", function () {
  let isProcessingLogs = false;
  const logs = {};

  const refreshLogs = async () => {
    if (isProcessingLogs) return;

    isProcessingLogs = true;
    const rawLogs = await (await fetch("/logs")).json();

    for (const appName in rawLogs) {
      if (!logs[appName]) {
        logs[appName] = { app: "", deploy: "" };
      }

      for (const logType of ["app", "deploy"]) {
        if (logs[appName][logType] !== rawLogs[appName][logType]) {
          logs[appName][logType] = rawLogs[appName][logType];

          const logTextarea = document.querySelector(
            `#${appName}-${logType}-log`
          );
          logTextarea.innerHTML = logs[appName][logType];
          logTextarea.scrollTop = logTextarea.scrollHeight;
        }
      }
    }

    isProcessingLogs = false;
  };

  // Add onClicks to Restart/Rebuild
  for (const action of ["restart", "rebuild", "powerdown"]) {
    const actionButtons = document.querySelectorAll(`.${action}-button`);

    for (const actionButton of actionButtons) {
      actionButton.addEventListener("click", (e) => {
        const button = e.target;
        const appType = button.dataset.apptype;
        const appName = button.dataset.appname;

        fetch(`/hook/${action}/${appType}/${appName}/`);
      });
    }
  }

  refreshLogs();
  setInterval(refreshLogs, 2000);
});
