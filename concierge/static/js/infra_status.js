document.addEventListener("DOMContentLoaded", function () {
  let isProcessingLogs = false;

  const logs = {
    concierge: "",
    "reverse-proxy": "",
  };

  const refreshLogs = async () => {
    if (isProcessingLogs) return;

    isProcessingLogs = true;
    const rawLogs = await (await fetch("/infra_logs")).json();

    for (const appName of ["concierge", "reverse-proxy"]) {
      if (logs[appName] !== rawLogs[appName]) {
        logs[appName] = rawLogs[appName];

        console.log(rawLogs);

        const logTextarea = document.querySelector(`#${appName}-app-log`);
        logTextarea.innerHTML = logs[appName];
        logTextarea.scrollTop = logTextarea.scrollHeight;
      }
    }

    isProcessingLogs = false;
  };

  refreshLogs();
  setInterval(refreshLogs, 2000);
});
