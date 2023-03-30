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

  refreshLogs();
  setInterval(refreshLogs, 2000);
});
