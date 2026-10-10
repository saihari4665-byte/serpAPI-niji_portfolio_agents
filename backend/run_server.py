import sys
import os

_appdata = os.environ.get("APPDATA", os.path.join(os.path.expanduser("~"), "AppData", "Roaming"))
LOG_DIR = os.path.join(_appdata, "NijiLocal", "logs")
os.makedirs(LOG_DIR, exist_ok=True)
LOG_FILE = os.path.join(LOG_DIR, "backend.log")

log_file_handle = open(LOG_FILE, "a")
sys.stdout = log_file_handle
sys.stderr = log_file_handle

import traceback

try:
    import uvicorn
    import uvicorn.logging
    import uvicorn.loops
    import uvicorn.loops.auto
    import uvicorn.protocols
    import uvicorn.protocols.http
    import uvicorn.protocols.http.auto
    import uvicorn.protocols.websockets
    import uvicorn.protocols.websockets.auto
    import uvicorn.lifespan
    import uvicorn.lifespan.on
    from main import app
except Exception as e:
    with open(r"C:\Users\ASUS\backend_error.txt", "w") as f:
        f.write(traceback.format_exc())
    sys.exit(1)

if __name__ == "__main__":
    log_config = uvicorn.config.LOGGING_CONFIG
    log_config["handlers"]["default"]["class"] = "logging.FileHandler"
    log_config["handlers"]["default"]["filename"] = LOG_FILE
    if "stream" in log_config["handlers"]["default"]:
        del log_config["handlers"]["default"]["stream"]
        
    log_config["handlers"]["access"]["class"] = "logging.FileHandler"
    log_config["handlers"]["access"]["filename"] = LOG_FILE
    if "stream" in log_config["handlers"]["access"]:
        del log_config["handlers"]["access"]["stream"]
        
    uvicorn.run(app, host="127.0.0.1", port=8000, reload=False, log_config=log_config, log_level="info")
